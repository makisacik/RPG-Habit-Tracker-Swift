//
//  TimerView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI
import Combine
import Lottie

class FocusTimerViewModel: ObservableObject {
    @Published var session: FocusTimerSession
    @Published var isRunning: Bool = false
    @Published var timeString: String = "25:00"
    @Published var progress: Double = 0.0
    @Published var currentPhase: String = "Work"
    @Published var showMonsterDefeated: Bool = false
    @Published var isMonsterShaking: Bool = false
    
    private var timer: Timer?
    private var lastDamageTime = Date()
    private var initialDamageApplied: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    let userManager: UserManager
    let damageHandler: DamageHandler
    let backgroundTimerManager = BackgroundTimerManager.shared
    private let persistenceService = MonsterHPPersistenceService.shared
    
    init(userManager: UserManager, damageHandler: DamageHandler) {
        self.session = FocusTimerSession()
        self.userManager = userManager
        self.damageHandler = damageHandler
        setupTimer()
        setupNotifications()
        loadPersistedData()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Timer Control
    
    func startTimer() {
        guard !isRunning else { return }
        
        // Check if monster is selected
        guard session.battleSession != nil else {
            // No monster selected, trigger monster selection
            NotificationCenter.default.post(name: .showMonsterSelection, object: nil)
            return
        }
        
        isRunning = true
        session.currentState = .working
        updatePhaseDisplay()
        
        // Apply initial damage only once per session
        if var battleSession = session.battleSession, !initialDamageApplied {
            let initialDamage = 5
            battleSession.enemy.currentHealth = max(0, battleSession.enemy.currentHealth - initialDamage)
            session.battleSession = battleSession
            
            // Save the updated HP
            saveMonsterHP(enemyType: battleSession.enemyType, currentHealth: battleSession.enemy.currentHealth)
            savePersistedData()
            
            // Show damage effect with dramatic animation
            let position = CGPoint(x: 200, y: 300)
            damageHandler.showDamageNumber(damage: initialDamage, position: position, isCritical: false)
            damageHandler.triggerScreenShake(intensity: .medium)
            triggerMonsterShake()
            
            // Mark initial damage as applied
            initialDamageApplied = true
            
            // Check if monster is defeated
            if battleSession.enemy.currentHealth <= 0 {
                showMonsterDefeated = true
                pauseTimer()
            }
        }
        
        // Start background timer
        backgroundTimerManager.startTimer(duration: session.timeRemaining, phase: currentPhase)
        
        // Listen for background timer updates - this is the single source of truth
        backgroundTimerManager.$timeRemaining
            .receive(on: DispatchQueue.main)
            .sink { [weak self] timeRemaining in
                self?.session.timeRemaining = timeRemaining
                self?.updateDisplay()
                // Apply automatic damage every minute based on background timer
                self?.applyAutomaticDamage()
            }
            .store(in: &cancellables)
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        
        // Pause background timer
        backgroundTimerManager.pauseTimer()
    }
    
    func resetTimer() {
        pauseTimer()
        
        // Heal enemy when timer is reset (user gives up)
        if var battleSession = session.battleSession {
            let healAmount = 20
            battleSession.enemy.currentHealth = min(battleSession.enemy.maxHealth, battleSession.enemy.currentHealth + healAmount)
            session.battleSession = battleSession
            
            // Save the updated HP
            saveMonsterHP(enemyType: battleSession.enemyType, currentHealth: battleSession.enemy.currentHealth)
            savePersistedData()
            
            // Show healing effect
            let position = CGPoint(x: 200, y: 300)
            damageHandler.showDamageNumber(damage: healAmount, position: position, isHealing: true)
        }
        
        // Reset timer but keep the monster
        session.currentState = .idle
        session.timeRemaining = session.settings.workDuration
        session.completedPomodoros = 0
        session.totalWorkTime = 0
        initialDamageApplied = false // Reset initial damage flag when timer is reset
        updateDisplay()
    }
    
    func skipPhase() {
        pauseTimer()
        
        // Heal enemy when phase is skipped (user avoids work)
        if var battleSession = session.battleSession {
            let healAmount = 15
            battleSession.enemy.currentHealth = min(battleSession.enemy.maxHealth, battleSession.enemy.currentHealth + healAmount)
            session.battleSession = battleSession
            
            // Show healing effect
            let position = CGPoint(x: 200, y: 300)
            damageHandler.showDamageNumber(damage: healAmount, position: position, isHealing: true)
        }
        
        transitionToNextPhase()
    }
    
    // MARK: - Battle Mode
    
    func startBattleMode(enemyType: EnemyType) {
        guard let user = createPlayerFromUser() else { return }
        
        var battleSession = BattleLogic.startBattle(
            player: user,
            enemyType: enemyType,
            targetPomodoros: session.settings.pomodorosUntilLongBreak
        )
        
        // Load persisted HP if available
        if let savedHP = loadMonsterHP(enemyType: enemyType) {
            battleSession.enemy.currentHealth = savedHP
        }
        
        session.battleSession = battleSession
        session.currentState = .idle
        lastDamageTime = Date() // Reset the damage timer for new monster
        initialDamageApplied = false // Reset initial damage flag for new monster
        
        // Save the battle session
        savePersistedData()
    }
    
    func completePomodoro() {
        session.completedPomodoros += 1
        session.totalWorkTime += session.settings.workDuration
        
        // Process battle logic if in battle mode
        if var battleSession = session.battleSession {
            // Deal damage to enemy for completing a pomodoro
            let damageAmount = 25
            battleSession.enemy.currentHealth = max(0, battleSession.enemy.currentHealth - damageAmount)
            
            // Show damage effect with dramatic animation
            let position = CGPoint(x: 200, y: 300)
            damageHandler.showDamageNumber(damage: damageAmount, position: position, isCritical: false)
            damageHandler.triggerScreenShake(intensity: .medium)
            triggerMonsterShake()
            
            // Process additional battle logic
            let actions = BattleLogic.processPomodoroCompletion(session: &battleSession)
            session.battleSession = battleSession
            
            // Save the updated HP
            saveMonsterHP(enemyType: battleSession.enemyType, currentHealth: battleSession.enemy.currentHealth)
            savePersistedData()
            
            // Process visual effects
            for action in actions {
                damageHandler.processBattleAction(action, entityPosition: position)
            }
            
            // Check if battle is complete
            if battleSession.isCompleted {
                handleBattleCompletion(battleSession)
            }
        }
        
        transitionToNextPhase()
    }
    
    func handleDistraction() {
        // Process distraction in battle mode
        if var battleSession = session.battleSession {
            let action = BattleLogic.processDistraction(session: &battleSession)
            session.battleSession = battleSession
            
            // Process visual effects
            let position = CGPoint(x: 200, y: 300) // This would be dynamic based on UI
            damageHandler.processBattleAction(action, entityPosition: position)
            
            // Check if battle is complete
            if battleSession.isCompleted {
                handleBattleCompletion(battleSession)
            }
        }
    }
    
    private func handleBattleCompletion(_ battleSession: BattleSession) {
        if battleSession.isVictory {
            session.currentState = .victory
            let rewards = BattleLogic.calculateRewards(session: battleSession)
            awardRewards(rewards)
        } else {
            session.currentState = .defeat
        }
        
        pauseTimer()
    }
    
    private func awardRewards(_ rewards: BattleReward) {
        // Award experience to user
        userManager.updateUserExperience(additionalExp: Int16(rewards.experience)) { [weak self] leveledUp, newLevel, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to award experience: \(error)")
                } else if leveledUp {
                    // Handle level up
                    print("Leveled up to \(newLevel ?? 0)!")
                }
            }
        }
        
        // TODO: Award gold and items
        print("Awarded \(rewards.experience) XP and \(rewards.gold) gold")
    }
    
    // MARK: - Private Methods
    
    private func setupTimer() {
        updateDisplay()
    }
    
    private func setupNotifications() {
        // Listen for timer completion from background manager
        NotificationCenter.default.publisher(for: .timerCompleted)
            .sink { [weak self] _ in
                self?.handleTimerCompletion()
            }
            .store(in: &cancellables)
    }
    
    private func handleTimerCompletion() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Ensure timer is stopped
            self.isRunning = false
            
            // Complete the current phase
            self.completePhase()
        }
    }
    
    
    private func applyAutomaticDamage() {
        guard let battleSession = session.battleSession,
              isRunning,
              session.currentState == .working else { return }
        
        let currentTime = Date()
        let timeSinceLastDamage = currentTime.timeIntervalSince(lastDamageTime)
        
        // Apply damage every 60 seconds (1 minute)
        if timeSinceLastDamage >= 60 {
            let damageAmount = 2
            var updatedBattleSession = battleSession
            updatedBattleSession.enemy.currentHealth = max(0, updatedBattleSession.enemy.currentHealth - damageAmount)
            
            // Show damage effect with dramatic animation
            let position = CGPoint(x: 200, y: 300)
            damageHandler.showDamageNumber(damage: damageAmount, position: position, isCritical: false)
            damageHandler.triggerScreenShake(intensity: .light)
            triggerMonsterShake()
            
            session.battleSession = updatedBattleSession
            lastDamageTime = currentTime
            
            // Save the updated HP
            saveMonsterHP(enemyType: updatedBattleSession.enemyType, currentHealth: updatedBattleSession.enemy.currentHealth)
            savePersistedData()
            
            // Check if monster is defeated
            if updatedBattleSession.enemy.currentHealth <= 0 {
                showMonsterDefeated = true
                pauseTimer()
            }
        }
    }
    
    private func updateDisplay() {
        let minutes = Int(session.timeRemaining) / 60
        let seconds = Int(session.timeRemaining) % 60
        timeString = String(format: "%02d:%02d", minutes, seconds)
        
        let totalDuration = getCurrentPhaseDuration()
        progress = 1.0 - (session.timeRemaining / totalDuration)
    }
    
    private func updatePhaseDisplay() {
        switch session.currentState {
        case .working:
            currentPhase = "Work"
        case .shortBreak:
            currentPhase = "Short Break"
        case .longBreak:
            currentPhase = "Long Break"
        case .battle:
            currentPhase = "Battle"
        case .victory:
            currentPhase = "Victory!"
        case .defeat:
            currentPhase = "Defeat"
        default:
            currentPhase = "Idle"
        }
    }
    
    private func completePhase() {
        switch session.currentState {
        case .working:
            completePomodoro()
        case .shortBreak, .longBreak:
            transitionToNextPhase()
        default:
            break
        }
    }
    
    private func transitionToNextPhase() {
        if session.currentState == .working {
            if session.shouldStartLongBreak {
                session.currentState = .longBreak
                session.timeRemaining = session.settings.longBreakDuration
            } else {
                session.currentState = .shortBreak
                session.timeRemaining = session.settings.shortBreakDuration
            }
        } else {
            session.currentState = .working
            session.timeRemaining = session.settings.workDuration
        }
        
        updatePhaseDisplay()
        startTimer()
    }
    
    private func getCurrentPhaseDuration() -> TimeInterval {
        switch session.currentState {
        case .working:
            return session.settings.workDuration
        case .shortBreak:
            return session.settings.shortBreakDuration
        case .longBreak:
            return session.settings.longBreakDuration
        default:
            return session.settings.workDuration
        }
    }
    
    private func createPlayerFromUser() -> BattleEntity? {
        // This would fetch the current user and create a BattleEntity
        // For now, returning a placeholder
        return BattleEntity(
            name: "Adventurer",
            maxHealth: 100,
            attackPower: 20,
            defense: 10,
            level: 1,
            imageName: "player_character",
            isPlayer: true
        )
    }
    
    // MARK: - Persistence Methods
    
    private func loadPersistedData() {
        // Load last damage time
        if let savedLastDamageTime = persistenceService.loadLastDamageTime() {
            lastDamageTime = savedLastDamageTime
        }
        
        // Load battle session if exists
        if let battleSession = session.battleSession {
            if let savedBattleSession = persistenceService.loadBattleSession(id: battleSession.id) {
                session.battleSession = savedBattleSession
            }
        }
    }
    
    private func savePersistedData() {
        // Save last damage time
        persistenceService.saveLastDamageTime(lastDamageTime)
        
        // Save battle session if exists
        if let battleSession = session.battleSession {
            persistenceService.saveBattleSession(battleSession)
            
            // Save monster HP
            persistenceService.saveMonsterHP(enemyType: battleSession.enemyType, currentHealth: battleSession.enemy.currentHealth)
        }
    }
    
    private func loadMonsterHP(enemyType: EnemyType) -> Int? {
        return persistenceService.loadMonsterHP(enemyType: enemyType)
    }
    
    private func saveMonsterHP(enemyType: EnemyType, currentHealth: Int) {
        persistenceService.saveMonsterHP(enemyType: enemyType, currentHealth: currentHealth)
    }
    
    func clearDefeatedMonsterData(battleSession: BattleSession) {
        persistenceService.clearMonsterHP(enemyType: battleSession.enemyType)
        persistenceService.clearBattleSession(id: battleSession.id)
        // Increment defeat count for this monster
        persistenceService.incrementMonsterDefeats(enemyType: battleSession.enemyType)
    }
    
    // MARK: - Animation Methods
    
    func triggerMonsterShake() {
        isMonsterShaking = true
        
        // Stop shaking after animation duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.isMonsterShaking = false
        }
    }
    
    // MARK: - Session Management
    
    func resetInitialDamageFlag() {
        initialDamageApplied = false
    }
}

// MARK: - TimerView

struct TimerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject var viewModel: FocusTimerViewModel
    @State private var showingEnemySelection = false
    
    init(userManager: UserManager, damageHandler: DamageHandler) {
        self._viewModel = StateObject(wrappedValue: FocusTimerViewModel(userManager: userManager, damageHandler: damageHandler))
    }
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Timer Display
                timerDisplay(theme: theme)
                
                // Progress Bar
                progressBar(theme: theme)
                
                // Controls
                controlButtons(theme: theme)
                
                // Monster Selection Button (if no monster is selected)
                if viewModel.session.battleSession == nil {
                    monsterSelectionButton(theme: theme)
                }
                
                
                Spacer()
            }
            .padding()
            
            // Damage Numbers Overlay
            ZStack {
                ForEach(viewModel.damageHandler.damageNumbers) { damageNumber in
                    DamageNumberView(damageNumber: damageNumber)
                        .position(damageNumber.position)
                }
            }
            
            // Battle Effects Overlay
            ZStack {
                ForEach(viewModel.damageHandler.battleEffects) { effect in
                    BattleEffectView(effect: effect)
                }
            }
            
            // Monster Defeated Overlay
            if viewModel.showMonsterDefeated {
                MonsterDefeatedOverlay(theme: theme) {
                    viewModel.showMonsterDefeated = false
                    // Clear persisted data for defeated monster
                    if let battleSession = viewModel.session.battleSession {
                        viewModel.clearDefeatedMonsterData(battleSession: battleSession)
                    }
                    // Reset the monster or allow selection of a new one
                    viewModel.session.battleSession = nil
                    viewModel.resetInitialDamageFlag() // Reset initial damage flag when monster is defeated
                }
            }
        }
        .screenShake(isShaking: viewModel.damageHandler.screenShake)
        .overlay(
            Rectangle()
                .fill(viewModel.damageHandler.flashEffect ? Color.red.opacity(0.3) : Color.clear)
                .allowsHitTesting(false)
        )
        .sheet(isPresented: $showingEnemySelection) {
            EnemySelectionView { enemyType in
                viewModel.startBattleMode(enemyType: enemyType)
                showingEnemySelection = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showMonsterSelection)) { _ in
            showingEnemySelection = true
        }
    }
    
    private func timerDisplay(theme: Theme) -> some View {
        VStack(spacing: 20) {
            // Timer Display
            VStack(spacing: 10) {
                Text(viewModel.timeString)
                    .font(.system(size: 72, weight: .bold, design: .monospaced))
                    .foregroundColor(theme.textColor)
                    .shadow(color: .black.opacity(0.3), radius: 2)
                
                Text(viewModel.currentPhase)
                    .font(.appFont(size: 18, weight: .medium))
                    .foregroundColor(theme.textColor.opacity(0.8))
            }
            
            // Monster Display (always show)
            monsterDisplay(theme: theme)
        }
    }
    
    private func monsterDisplay(theme: Theme) -> some View {
        VStack(spacing: 15) {
            // Monster Image
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.primaryColor.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.2), radius: 8)
                
                if let battleSession = viewModel.session.battleSession {
                    // Selected monster Lottie animation with shaking effect (reduced frequency for main page)
                    LottieView(animation: .named(battleSession.enemyType.animationName))
                        .playbackMode(.playing(.toProgress(1, loopMode: .loop)))
                        .frame(width: battleSession.enemyType == .flyingDragon ? 120 : 100, height: battleSession.enemyType == .flyingDragon ? 120 : 100)
                        .modifier(MonsterShakeModifier(isShaking: viewModel.isMonsterShaking))
                        .scaleEffect(battleSession.enemyType == .flyingDragon ? 1.2 : 1.0)
                        .opacity(0.8) // Slightly reduce opacity to make it less prominent
                } else {
                    // Placeholder for unselected monster
                    VStack(spacing: 8) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(theme.textColor.opacity(0.5))
                        
                        Text(String.selectMonster.localized)
                            .font(.appFont(size: 12, weight: .medium))
                            .foregroundColor(theme.textColor.opacity(0.7))
                    }
                }
            }
            
            // Monster Name, Level, and Health
            VStack(spacing: 4) {
                if let battleSession = viewModel.session.battleSession {
                    Text(battleSession.enemy.name)
                        .font(.appFont(size: 16, weight: .bold))
                        .foregroundColor(theme.textColor)
                    
                    Text("\(String.level.localized) \(battleSession.enemy.level)")
                        .font(.appFont(size: 12))
                        .foregroundColor(theme.textColor.opacity(0.7))
                    
                    Text("\(battleSession.enemy.currentHealth)/\(battleSession.enemy.maxHealth) \(String.healthPoints.localized)")
                        .font(.appFont(size: 12, weight: .bold))
                        .foregroundColor(.red)
                } else {
                    Text(String.noMonsterSelected.localized)
                        .font(.appFont(size: 16, weight: .bold))
                        .foregroundColor(theme.textColor.opacity(0.5))
                    
                    Text(String.chooseYourEnemy.localized)
                        .font(.appFont(size: 12))
                        .foregroundColor(theme.textColor.opacity(0.5))
                }
            }
            
            // Health Bar
            VStack(spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.red.opacity(0.3))
                            .frame(height: 12)
                        
                        if let battleSession = viewModel.session.battleSession {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.red)
                                .frame(width: geometry.size.width * battleSession.enemy.healthPercentage, height: 12)
                                .animation(.easeInOut(duration: 0.5), value: battleSession.enemy.healthPercentage)
                        } else {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: geometry.size.width * 0.0, height: 12)
                        }
                    }
                }
                .frame(height: 12)
                .frame(maxWidth: 200)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor.opacity(0.5))
                .shadow(color: .black.opacity(0.1), radius: 4)
        )
        .overlay(
            // Change Monster Button
            VStack {
                HStack {
                    Spacer()
                    if viewModel.session.battleSession != nil {
                        Button(action: {
                            NotificationCenter.default.post(name: .showMonsterSelection, object: nil)
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(theme.textColor)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(theme.primaryColor.opacity(0.8))
                                        .shadow(color: .black.opacity(0.2), radius: 2)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                Spacer()
            }
            .padding(.top, 8)
            .padding(.trailing, 8)
        )
    }
    
    private func progressBar(theme: Theme) -> some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(theme.backgroundColor.opacity(0.3))
                        .frame(height: 20)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(progressColor(theme: theme))
                        .frame(width: geometry.size.width * viewModel.progress, height: 20)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.progress)
                }
            }
            .frame(height: 20)
            
            if viewModel.session.isInBattle, let battleSession = viewModel.session.battleSession {
                Text("\(String.pomodoros.localized): \(battleSession.completedPomodoros)/\(battleSession.targetPomodoros)")
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
        }
    }
    
    private func progressColor(theme: Theme) -> Color {
        switch viewModel.session.currentState {
        case .working:
            return .green
        case .shortBreak, .longBreak:
            return .blue
        case .battle:
            return .red
        case .victory:
            return .yellow
        case .defeat:
            return .gray
        default:
            return theme.primaryColor
        }
    }
    
    private func controlButtons(theme: Theme) -> some View {
        HStack(spacing: 20) {
            Button(action: {
                if viewModel.isRunning {
                    viewModel.pauseTimer()
                } else {
                    viewModel.startTimer()
                }
            }) {
                Image(systemName: viewModel.isRunning ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(theme.textColor)
            }
            
            Button(action: {
                viewModel.resetTimer()
            }) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
            
            Button(action: {
                viewModel.skipPhase()
            }) {
                Image(systemName: "forward.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
        }
    }
    
    
    private func monsterSelectionButton(theme: Theme) -> some View {
        Button(action: {
            showingEnemySelection = true
        }) {
            HStack {
                Image(systemName: "person.fill")
                Text(String.selectMonster.localized)
            }
            .font(.appFont(size: 16, weight: .medium))
            .foregroundColor(theme.textColor)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.primaryColor)
                    .shadow(color: .black.opacity(0.2), radius: 4)
            )
        }
    }
}

// MARK: - Enemy Selection View

struct EnemySelectionView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    let onEnemySelected: (EnemyType) -> Void
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        NavigationView {
            ZStack {
                theme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(EnemyType.allCases, id: \.self) { enemyType in
                            EnemyCard(enemyType: enemyType) {
                                onEnemySelected(enemyType)
                            }
                        }
                    }
                    .padding()
                }
            }
                            .navigationTitle(String.chooseYourEnemy.localized)
            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarItems(trailing: Button(String.cancelButton.localized) {
                dismiss()
                            })
        }
    }
}

struct EnemyCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let enemyType: EnemyType
    let onSelect: () -> Void
    
    private var defeatCount: Int {
        MonsterHPPersistenceService.shared.getMonsterDefeats(enemyType: enemyType)
    }
    
    var body: some View {
        let theme = themeManager.activeTheme
        let entity = enemyType.entity
        
        Button(action: onSelect) {
            ZStack {
                VStack(spacing: 12) {
                    // Enemy Lottie animation
                    LottieView(animation: .named(enemyType.animationName))
                        .playbackMode(.playing(.toProgress(1, loopMode: .loop)))
                        .frame(width: enemyType == .flyingDragon ? 100 : 80, height: enemyType == .flyingDragon ? 100 : 80)
                    
                    VStack(spacing: 4) {
                        Text(entity.name)
                            .font(.appFont(size: 14, weight: .bold))
                            .foregroundColor(theme.textColor)
                            .multilineTextAlignment(.center)
                        
                        Text("\(String.level.localized) \(entity.level)")
                            .font(.appFont(size: 12))
                            .foregroundColor(theme.textColor.opacity(0.7))
                        
                        Text(enemyType.description)
                            .font(.appFont(size: 10))
                            .foregroundColor(theme.textColor.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.primaryColor.opacity(0.5))
                        .shadow(color: .black.opacity(0.1), radius: 4)
                )
                
                // Skull icon with defeat count (top right)
                if defeatCount > 0 {
                    VStack {
                        HStack {
                            Spacer()
                            ZStack {
                                Image("icon_skull")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .opacity(0.6)
                                
                                Text("\(defeatCount)")
                                    .font(.appFont(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(
                                        Circle()
                                            .fill(Color.red.opacity(0.8))
                                            .shadow(color: .black.opacity(0.2), radius: 1)
                                    )
                                    .offset(x: 8, y: -8)
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 8)
                    .padding(.trailing, 8)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Monster Shake Modifier

struct MonsterShakeModifier: ViewModifier {
    let isShaking: Bool
    
    func body(content: Content) -> some View {
        content
            .offset(x: isShaking ? CGFloat.random(in: -12...12) : 0,
                   y: isShaking ? CGFloat.random(in: -12...12) : 0)
            .rotationEffect(.degrees(isShaking ? Double.random(in: -8...8) : 0))
            .animation(isShaking ? .easeInOut(duration: 0.08).repeatCount(8) : .default, value: isShaking)
    }
}

// MARK: - Monster Defeated Overlay

struct MonsterDefeatedOverlay: View {
    let theme: Theme
    let onDismiss: () -> Void
    @State private var showContent = false
    @State private var isDismissing = false
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissWithAnimation()
                }
            
            // Content
            VStack(spacing: 20) {
                // Victory icon
                Image(systemName: "trophy.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                    .scaleEffect(showContent ? 1.0 : 0.5)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2), value: showContent)
                
                // Title
                Text(String.monsterDefeated.localized)
                    .font(.appFont(size: 28, weight: .black))
                    .foregroundColor(.white)
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
                
                // Description
                Text(String.youHaveSuccessfullyDefeatedMonster.localized)
                    .font(.appFont(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.6), value: showContent)
                
                // Continue button
                Button(action: {
                    dismissWithAnimation()
                }) {
                    Text(String.continueButton.localized)
                        .font(.appFont(size: 18, weight: .bold))
                        .foregroundColor(theme.textColor)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.yellow)
                                .shadow(color: .black.opacity(0.3), radius: 4)
                        )
                }
                .opacity(showContent ? 1.0 : 0.0)
                .scaleEffect(showContent ? 1.0 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.8), value: showContent)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.primaryColor.opacity(0.9))
                    .shadow(color: .black.opacity(0.3), radius: 10)
            )
            .scaleEffect(showContent && !isDismissing ? 1.0 : 0.8)
            .opacity(showContent && !isDismissing ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showContent)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                showContent = true
            }
        }
    }
    
    private func dismissWithAnimation() {
        isDismissing = true
        showContent = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let showMonsterSelection = Notification.Name("showMonsterSelection")
}
