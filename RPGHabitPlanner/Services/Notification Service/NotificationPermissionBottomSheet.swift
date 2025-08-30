import SwiftUI

struct NotificationPermissionBottomSheet: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    let onPermissionGranted: () -> Void
    let onPermissionDenied: () -> Void
    let quest: Quest? // Optional quest to schedule notification for
    
    @State private var showSystemPrompt = false
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        VStack(spacing: 24) {
            // Header with cute icon
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.yellow)
                }
                
                Text("notification_permission_title".localized)
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 20)
            
            // Cute message
            VStack(spacing: 12) {
                Text("notification_permission_message".localized)
                    .font(.appFont(size: 16))
                    .foregroundColor(theme.textColor.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Text("notification_permission_subtitle".localized)
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                Button(action: {
                    showSystemPrompt = true
                }) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 16, weight: .medium))
                        
                        Text("notification_permission_allow".localized)
                            .font(.appFont(size: 16, weight: .black))
                    }
                    .foregroundColor(theme.textColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Image(theme.buttonPrimary)
                            .resizable(
                                capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                                resizingMode: .stretch
                            )
                    )
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    onPermissionDenied()
                    dismiss()
                }) {
                    Text("notification_permission_not_now".localized)
                        .font(.appFont(size: 16, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(theme.backgroundColor)
                .shadow(color: theme.shadowColor.opacity(0.2), radius: 20, x: 0, y: -10)
        )
        .onChange(of: showSystemPrompt) { show in
            if show {
                NotificationManager.shared.requestPermission { granted in
                    DispatchQueue.main.async {
                        if granted {
                            // Schedule notification for the quest if provided
                            if let quest = quest {
                                NotificationManager.shared.handleNotificationForQuest(quest, enabled: true)
                            }
                            onPermissionGranted()
                        } else {
                            onPermissionDenied()
                        }
                        dismiss()
                    }
                }
            }
        }
        .onDisappear {
            // If the sheet is dismissed without making a choice, treat it as denied
            if !showSystemPrompt {
                onPermissionDenied()
            }
        }
    }
}

#Preview {
    NotificationPermissionBottomSheet(
        onPermissionGranted: {},
        onPermissionDenied: {},
        quest: nil
    )
    .environmentObject(ThemeManager.shared)
}
