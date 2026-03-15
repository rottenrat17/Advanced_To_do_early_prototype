import SwiftUI

/// Are we creating a new task or editing an existing one?
enum AddEditMode {
    case add
    case edit(TaskItem)
}

/// Same form for adding and editing a task: title, notes, type, due date.
struct AddEditTaskView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let mode: AddEditMode

    @State private var title = ""
    @State private var notes = ""
    @State private var selectedTypeId: UUID?
    @State private var dueDate = Date()

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Title", text: $title)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Type") {
                    Picker("Task Type", selection: $selectedTypeId) {
                        Text("Select type").tag(nil as UUID?)
                        ForEach(appState.taskTypes) { type in
                            Text(type.name).tag(type.id as UUID?)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Due") {
                    DatePicker("Date & Time", selection: $dueDate)
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .disabled(title.isEmpty || selectedTypeId == nil)
                }
            }
            .onAppear(perform: loadIfEditing)
        }
    }

    private func loadIfEditing() {
        if case .edit(let task) = mode {
            title = task.title
            notes = task.notes
            selectedTypeId = task.taskTypeId
            dueDate = task.dueDate
        } else {
            selectedTypeId = appState.taskTypes.first?.id
        }
    }

    private func save() {
        guard let typeId = selectedTypeId else { return }

        switch mode {
        case .add:
            let task = TaskItem(
                title: title,
                notes: notes,
                taskTypeId: typeId,
                dueDate: dueDate
            )
            appState.addTask(task)
        case .edit(let existing):
            var updated = existing
            updated.title = title
            updated.notes = notes
            updated.taskTypeId = typeId
            updated.dueDate = dueDate
            appState.updateTask(updated)
        }
    }
}

#Preview {
    AddEditTaskView(mode: .add).environmentObject(AppState())
}
