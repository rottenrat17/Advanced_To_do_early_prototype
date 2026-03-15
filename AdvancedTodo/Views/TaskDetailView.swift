import SwiftUI

/// Full task info and actions: mark complete, edit, delete.
struct TaskDetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let task: TaskItem
    @State private var showDeleteAlert = false

    /// Always from AppState so the screen updates when we mark complete.
    private var currentTask: TaskItem {
        appState.tasks.first { $0.id == task.id } ?? task
    }

    private var taskType: TaskType? {
        appState.taskType(for: currentTask.taskTypeId)
    }

    var body: some View {
        List {
            Section("Title") {
                Text(currentTask.title)
                    .font(.headline)
            }

            if !currentTask.notes.isEmpty {
                Section("Notes") {
                    Text(currentTask.notes)
                }
            }

            Section("Details") {
                if let type = taskType {
                    Label(type.name, systemImage: "folder.fill")
                        .foregroundStyle(type.color)
                }
                Label(currentTask.dueDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                HStack {
                    Text("Status")
                    Spacer()
                    Text(currentTask.isCompleted ? "Completed" : "Pending")
                        .foregroundStyle(currentTask.isCompleted ? .green : .orange)
                }
            }

            Section {
                if !currentTask.isCompleted {
                    Button {
                        appState.toggleComplete(currentTask)
                    } label: {
                        Label("Mark as Completed", systemImage: "checkmark.circle")
                    }
                    .accessibilityLabel("Mark as Completed")
                }
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Label("Delete Task", systemImage: "trash")
                }
                .accessibilityLabel("Delete Task")
            }
        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Task?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                appState.deleteTask(task)
                dismiss()
            }
        } message: {
            Text("This cannot be undone.")
        }
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(task: TaskItem(
            title: "Sample Task",
            notes: "Some notes",
            taskTypeId: UUID(),
            dueDate: Date()
        ))
        .environmentObject(AppState())
    }
}
