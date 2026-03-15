// All tasks and task types live here. We save to UserDefaults so they’re still there after you close the app.

import SwiftUI

final class AppState: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var taskTypes: [TaskType] = []

    private let tasksKey = "savedTasks"
    private let taskTypesKey = "savedTaskTypes"

    /// The three types you get when the app is first installed.
    private static var defaultTaskTypes: [TaskType] {
        [
            TaskType(name: "Important", colorHex: "FF3B30"),
            TaskType(name: "General", colorHex: "007AFF"),
            TaskType(name: "Overdue", colorHex: "FF9500")
        ]
    }

    init() {
        loadFromStorage()
    }

    /// Load tasks and types from UserDefaults (or use defaults if nothing saved yet).
    private func loadFromStorage() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        if let data = UserDefaults.standard.data(forKey: taskTypesKey),
           let decoded = try? decoder.decode([TaskType].self, from: data),
           !decoded.isEmpty {
            taskTypes = decoded
        } else {
            taskTypes = Self.defaultTaskTypes
        }

        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? decoder.decode([TaskItem].self, from: data) {
            tasks = decoded
        } else {
            tasks = []
        }
    }

    /// Save current tasks and types to UserDefaults.
    private func saveToStorage() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        if let data = try? encoder.encode(tasks) {
            UserDefaults.standard.set(data, forKey: tasksKey)
        }
        if let data = try? encoder.encode(taskTypes) {
            UserDefaults.standard.set(data, forKey: taskTypesKey)
        }
    }

    func taskType(for id: UUID) -> TaskType? {
        taskTypes.first { $0.id == id }
    }

    func addTask(_ task: TaskItem) {
        tasks.append(task)
        saveToStorage()
    }

    func updateTask(_ task: TaskItem) {
        if let i = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[i] = task
            saveToStorage()
        }
    }

    func deleteTask(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
        saveToStorage()
    }

    func toggleComplete(_ task: TaskItem) {
        if let i = tasks.firstIndex(where: { $0.id == task.id }) {
            var updated = tasks[i]
            updated.isCompleted.toggle()
            tasks[i] = updated
            saveToStorage()
        }
    }

    func addTaskType(_ type: TaskType) {
        taskTypes.append(type)
        saveToStorage()
    }

    func updateTaskType(_ type: TaskType) {
        if let i = taskTypes.firstIndex(where: { $0.id == type.id }) {
            taskTypes[i] = type
            saveToStorage()
        }
    }

    func deleteTaskType(_ type: TaskType) {
        taskTypes.removeAll { $0.id == type.id }
        saveToStorage()
    }
}
