import SwiftUI

/// Filter the task list: everything, only pending, or only completed.
enum TaskFilter: String, CaseIterable {
    case all = "All"
    case pending = "Pending"
    case completed = "Completed"
}

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedFilter: TaskFilter = .all
    @State private var showingAddTask = false
    @State private var showingTaskTypes = false
    @State private var selectedTask: TaskItem?

    /// Tasks to show in the list based on the current filter.
    var filteredTasks: [TaskItem] {
        switch selectedFilter {
        case .all: return appState.tasks
        case .pending: return appState.tasks.filter { !$0.isCompleted }
        case .completed: return appState.tasks.filter { $0.isCompleted }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(TaskFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                List {
                    ForEach(filteredTasks) { task in
                        TaskRowView(
                            task: task,
                            taskType: appState.taskType(for: task.taskTypeId),
                            onTapCircle: { appState.toggleComplete(task) }
                        )
                        .contentShape(Rectangle())
                        .onTapGesture { selectedTask = task }
                        .listRowBackground(rowBackground(for: task))
                    }
                    .onDelete(perform: deleteTasks)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingTaskTypes = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Open Task Type Manager")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityLabel("Add new task")
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddEditTaskView(mode: .add)
            }
            .sheet(isPresented: $showingTaskTypes) {
                TaskTypeManagerView()
            }
            .navigationDestination(item: $selectedTask) { task in
                TaskDetailView(task: task)
            }
        }
    }

    private func rowBackground(for task: TaskItem) -> Color {
        if task.isOverdue { return Color.red.opacity(0.15) }
        if task.isDueSoon { return Color.orange.opacity(0.15) }
        return Color.clear
    }

    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            let task = filteredTasks[index]
            appState.deleteTask(task)
        }
    }
}

/// One row in the task list: title, type chip, due date, and completion circle.
struct TaskRowView: View {
    let task: TaskItem
    let taskType: TaskType?
    var onTapCircle: (() -> Void)? = nil

    private var rowAccessibilityLabel: String {
        let typeName = taskType?.name ?? "Unknown"
        let due = task.dueDate.formatted(date: .abbreviated, time: .shortened)
        let status = task.isCompleted ? "Completed" : "Pending"
        return "\(task.title), \(typeName), due \(due), \(status)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(task.title)
                    .font(.headline)
                Spacer()
                Button {
                    onTapCircle?()
                } label: {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(task.isCompleted ? .green : .gray)
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
            HStack {
                if let type = taskType {
                    Text(type.name)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(type.color.opacity(0.3))
                        .clipShape(Capsule())
                }
                Text(task.dueDate, style: .date)
                Text(task.dueDate, style: .time)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(rowAccessibilityLabel)
        .accessibilityHint("Double tap to open details. Swipe left to delete.")
    }
}

#Preview {
    HomeView().environmentObject(AppState())
}
