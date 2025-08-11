import SwiftUI

struct EditQuestView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: EditQuestViewModel

    @State private var isButtonPressed: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var isTaskPopupVisible = false
    @State private var showDeleteConfirmation = false

    /// Called when a save/delete succeeds (used by parent to refresh)
    var onSaveSuccess: (() -> Void)?
    var onCancel: (() -> Void)?

    private var theme: Theme { themeManager.activeTheme }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        EditQuestHeaderSection(viewModel: viewModel, theme: theme)
                        EditQuestBasicInfoSection(viewModel: viewModel, theme: theme)
                        EditQuestSettingsSection(viewModel: viewModel, theme: theme)

                        EditQuestTasksSection(
                            viewModel: viewModel,
                            theme: theme
                        ) { isTaskPopupVisible = true }

                        EditQuestActionButtonsSection(
                            viewModel: viewModel,
                            theme: theme,
                            isButtonPressed: isButtonPressed,
                            onSave: saveQuest
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Edit Quest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel?()
                        dismiss()
                    }
                    .foregroundColor(theme.textColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Delete Quest", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(theme.textColor)
                    }
                }
            }
            .sheet(isPresented: $isTaskPopupVisible) {
                EditQuestTaskEditorSheet(
                    viewModel: viewModel,
                    theme: theme,
                    isPresented: $isTaskPopupVisible
                )
            }
            .alert("Delete Quest", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteQuest() // 🔧 implement
                }
            } message: {
                Text("Are you sure you want to delete this quest? This action cannot be undone.")
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            // Optional: if your VM toggles this flag internally after update
            .onChange(of: viewModel.didUpdateQuest) { updated in
                if updated {
                    onSaveSuccess?()
                    dismiss()
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func saveQuest() {
        // small press animation
        isButtonPressed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { isButtonPressed = false }

        if viewModel.validateInputs() {
            viewModel.updateQuest { success in
                if success {
                    onSaveSuccess?()     // 🔧 let parent refresh
                    dismiss()            // close sheet
                } else {
                    showAlert(title: "Error", message: viewModel.errorMessage ?? "Failed to update quest.")
                }
            }
        } else {
            showAlert(title: "Warning", message: viewModel.errorMessage ?? "Please check your input.")
        }
    }

    private func deleteQuest() {
        // 🔧 Implement delete through your VM/data service
        viewModel.deleteQuest { success in
            if success {
                onSaveSuccess?()   // tell parent to refresh
                dismiss()
            } else {
                showAlert(title: "Error", message: viewModel.errorMessage ?? "Failed to delete quest.")
            }
        }
    }

    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}
