//
//  EditQuestView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 18.11.2024.
//

import SwiftUI

struct EditQuestView: View {
    @Binding var quest: Quest

    @State private var localQuest: Quest

    var onSave: (Quest) -> Void
    var onCancel: () -> Void

    init(quest: Binding<Quest>, onSave: @escaping (Quest) -> Void, onCancel: @escaping () -> Void) {
        self._quest = quest
        self._localQuest = State(initialValue: quest.wrappedValue)
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Quest Details")) {
                    TextField("Title", text: $localQuest.title)
                    TextField("Description", text: $localQuest.info)
                    Picker("Difficulty", selection: $localQuest.difficulty) {
                        ForEach(1...5, id: \.self) {
                            Text("\($0)").tag($0)
                        }
                    }
                    
                    DatePicker("Due Date", selection: $localQuest.dueDate, displayedComponents: .date)
                    Toggle("Main Quest", isOn: $localQuest.isMainQuest)
                        .tint(Color(.appYellow))
                    Toggle("Active", isOn: $localQuest.isActive)
                        .tint(Color(.appYellow))
                }
            }
            .navigationTitle("Edit Quest")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        quest = localQuest
                        onSave(localQuest)
                    }
                }
            }
        }
    }
}
