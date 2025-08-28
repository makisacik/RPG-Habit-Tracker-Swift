import SwiftUI

struct EditQuestView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @ObservedObject var viewModel: EditQuestViewModel

    @State private var isButtonPressed: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var isTaskPopupVisible = false
    @State private var showDeleteConfirmation = false

    var onSaveSuccess: (() -> Void)?
    var onCancel: (() -> Void)?
    var onDeleteSuccess: (() -> Void)?

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
                            .navigationTitle("edit_quest".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized) {
                        onCancel?()
                        dismiss()
                    }
                    .foregroundColor(theme.textColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("delete_quest".localized, role: .destructive) {
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
                            .alert("delete_quest_confirmation".localized, isPresented: $showDeleteConfirmation) {
                    Button("cancel".localized, role: .cancel) { }
                    Button("delete".localized, role: .destructive) {
                    deleteQuest() // 🔧 implement
                    }
                            } message: {
                    Text("delete_quest_warning".localized)
                            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("ok".localized))
                )
            }
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
                    showAlert(title: "error".localized, message: viewModel.errorMessage ?? "failed_to_update_quest".localized)
                }
            }
        } else {
            showAlert(title: "warning".localized, message: viewModel.errorMessage ?? "please_check_your_input".localized)
        }
    }

    private func deleteQuest() {
        // 🔧 Implement delete through your VM/data service
        viewModel.deleteQuest { success in
            if success {
                onDeleteSuccess?()  // tell parent to refresh
                dismiss()
            } else {
                showAlert(title: "error".localized, message: viewModel.errorMessage ?? "failed_to_delete_quest".localized)
            }
        }
    }

    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}
