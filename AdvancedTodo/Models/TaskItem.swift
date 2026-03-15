import Foundation

/// A single task: title, notes, type, due date, and whether it’s done.
struct TaskItem: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var notes: String
    var taskTypeId: UUID
    var dueDate: Date
    var isCompleted: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        taskTypeId: UUID,
        dueDate: Date,
        isCompleted: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.taskTypeId = taskTypeId
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }

    
}
