//
//  ActiveQuestWidgetBundle.swift
//  ActiveQuestWidget
//
//  Created by Mehmet Ali Kısacık on 19.11.2024.
//

import WidgetKit
import SwiftUI

@main
struct ActiveQuestWidgetBundle: WidgetBundle {
    var body: some Widget {
        ActiveQuestWidget()
        FocusTimerLiveActivity()
    }
}
