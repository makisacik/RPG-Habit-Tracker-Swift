//
//  TimerView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI
import Combine

class FocusTimerViewModel: ObservableObject {
    @Published var session: FocusTimerSession
    @Published var isRunning: Bool = false
    @Published var timeString: String = "25:00"
    @Published var progress: Double = 0.0
    @Published var currentPhase: String = "Work"
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    let userManager: UserManager
    let damageHandler: DamageHandler
    let backgroundTimerManager = BackgroundTimerManager.shared
    
    init(userManager: UserManager, damageHandler: DamageHandler) {
        self.session = FocusTimerSession()
        self.userManager = userManager
        self.damageHandler = damageHandler
        setupTimer()
        setupNotifications()
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
        
        // Start background timer
        backgroundTimerManager.startTimer(duration: session.timeRemaining, phase: currentPhase)
        
        // Start local timer for UI updates
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        
        // Listen for background timer updates
        backgroundTimerManager.$timeRemaining
            .sink { [weak self] timeRemaining in
                self?.session.timeRemaining = timeRemaining
                self?.updateDisplay()
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
            
            // Show healing effect
            let position = CGPoint(x: 200, y: 300)
            damageHandler.showDamageNumber(damage: healAmount, position: position, isHealing: true)
        }
        
        // Reset timer but keep the monster
        session.currentState = .idle
        session.timeRemaining = session.settings.workDuration
        session.completedPomodoros = 0
        session.totalWorkTime = 0
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
        
        let battleSession = BattleLogic.startBattle(
            player: user,
            enemyType: enemyType,
            targetPomodoros: session.settings.pomodorosUntilLongBreak
        )
        
        session.battleSession = battleSession
        session.currentState = .idle
    }
    
    func completePomodoro() {
        session.completedPomodoros += 1
        session.totalWorkTime += session.settings.workDuration
        
        // Process battle logic if in battle mode
        if var battleSession = session.battleSession {
            // Deal damage to enemy for completing a pomodoro
            let damageAmount = 25
            battleSession.enemy.currentHealth = max(0, battleSession.enemy.currentHealth - damageAmount)
            
            // Show damage effect
            let position = CGPoint(x: 200, y: 300)
            damageHandler.showDamageNumber(damage: damageAmount, position: position, isCritical: false)
            
            // Process additional battle logic
            let actions = BattleLogic.processPomodoroCompletion(session: &battleSession)
            session.battleSession = battleSession
            
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
            
            // Complete the current phase
            self.completePhase()
        }
    }
    
    private func updateTimer() {
        guard session.timeRemaining > 0 else {
            completePhase()
            return
        }
        
        session.timeRemaining -= 1
        updateDisplay()
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
                    // Selected monster image
                    Image(systemName: "person.fill")
                        .font(.system(size: 60))
                        .foregroundColor(theme.textColor)
                } else {
                    // Placeholder for unselected monster
                    VStack(spacing: 8) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(theme.textColor.opacity(0.5))
                        
                        Text("Select Monster")
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
                    
                    Text("Level \(battleSession.enemy.level)")
                        .font(.appFont(size: 12))
                        .foregroundColor(theme.textColor.opacity(0.7))
                    
                    Text("\(battleSession.enemy.currentHealth)/\(battleSession.enemy.maxHealth) HP")
                        .font(.appFont(size: 12, weight: .bold))
                        .foregroundColor(.red)
                } else {
                    Text("No Monster Selected")
                        .font(.appFont(size: 16, weight: .bold))
                        .foregroundColor(theme.textColor.opacity(0.5))
                    
                    Text("Choose your enemy")
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
                Text("Pomodoros: \(battleSession.completedPomodoros)/\(battleSession.targetPomodoros)")
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
                Text("Select Monster")
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
            .navigationTitle("Choose Your Enemy")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}

struct EnemyCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let enemyType: EnemyType
    let onSelect: () -> Void
    
    var body: some View {
        let theme = themeManager.activeTheme
        let entity = enemyType.entity
        
        Button(action: onSelect) {
            VStack(spacing: 12) {
                // Placeholder for enemy image
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.primaryColor)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(theme.textColor)
                    )
                
                VStack(spacing: 4) {
                    Text(entity.name)
                        .font(.appFont(size: 14, weight: .bold))
                        .foregroundColor(theme.textColor)
                        .multilineTextAlignment(.center)
                    
                    Text("Level \(entity.level)")
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
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let showMonsterSelection = Notification.Name("showMonsterSelection")
}
