//
//  FocusTimerLiveActivity.swift
//  ActiveQuestWidget
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI
import UIKit

struct FocusTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusTimerAttributes.self) { context in
            // Lock screen/banner UI goes here
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(formatTime(context.state.timeRemaining))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text(LocalizationHelper.localized(LocalizationHelper.remaining))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(context.attributes.timerName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Text(LocalizationHelper.localized(LocalizationHelper.focusTimer))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        Text(LocalizationHelper.localized(LocalizationHelper.focusTimer))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal)
                }
            } compactLeading: {
                // Compact leading
                Image(systemName: "timer")
                    .foregroundColor(.white)
                    .font(.title3)
            } compactTrailing: {
                // Compact trailing
                Text("\(formatTime(context.state.timeRemaining))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            } minimal: {
                // Minimal
                Image(systemName: "timer")
                    .foregroundColor(.white)
                    .font(.title3)
            }
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<FocusTimerAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.attributes.timerName)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(LocalizationHelper.localized(LocalizationHelper.focusTimer))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatTime(context.state.timeRemaining))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text(LocalizationHelper.localized(LocalizationHelper.remaining))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
