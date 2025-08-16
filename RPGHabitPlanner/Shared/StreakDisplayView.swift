import SwiftUI

struct StreakDisplayView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var streakManager: StreakManager
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        HStack(spacing: 12) {
            // Fire icon with animation
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.3), Color.red.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: .orange.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(
                        streakManager.currentStreak > 0 ?
                        Color.orange : Color.gray.opacity(0.5)
                    )
                    .scaleEffect(streakManager.wasActiveToday() ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: streakManager.wasActiveToday())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Current streak
                HStack(spacing: 4) {
                    Text("\(streakManager.currentStreak)")
                        .font(.appFont(size: 24, weight: .black))
                        .foregroundColor(theme.textColor)
                    
                    Text(streakManager.currentStreak == 1 ? String.streakDay.localized : String.streakDays.localized)
                        .font(.appFont(size: 16, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.8))
                }
                
                // Streak label
                Text(String.streak.localized)
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(theme.textColor.opacity(0.7))
                
                // Longest streak (smaller text)
                if streakManager.longestStreak > 0 {
                    Text("\(String.bestStreak.localized): \(streakManager.longestStreak) \(streakManager.longestStreak == 1 ? String.streakDay.localized : String.streakDays.localized)")
                        .font(.appFont(size: 12, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.6))
                }
            }
            
            Spacer()
            
            // Today's status indicator
            VStack(spacing: 4) {
                Circle()
                    .fill(streakManager.wasActiveToday() ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                Text(String.todayStatus.localized)
                    .font(.appFont(size: 10, weight: .medium))
                    .foregroundColor(theme.textColor.opacity(0.6))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            theme.primaryColor.opacity(0.9),
                            theme.primaryColor.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.3), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}
