import SwiftUI

/// List of task types; add, edit (tap row or pencil), or swipe to delete.
struct TaskTypeManagerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var showingAddType = false
    @State private var typeToEdit: TaskType?

    var body: some View {
        NavigationStack {
            List {
                ForEach(appState.taskTypes) { type in
                    HStack {
                        Circle()
                            .fill(type.color)
                            .frame(width: 12, height: 12)
                        Text(type.name)
                        Spacer()
                        Button {
                            typeToEdit = type
                        } label: {
                            Image(systemName: "pencil")
                        }
                        .buttonStyle(.borderless)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        typeToEdit = type
                    }
                }
                .onDelete(perform: deleteTypes)
            }
            .navigationTitle("Task Types")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Done")
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddType = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityLabel("Add new task type")
                }
            }
            .sheet(isPresented: $showingAddType) {
                AddEditTaskTypeView(mode: .add)
            }
            .sheet(item: $typeToEdit) { type in
                AddEditTaskTypeView(mode: .edit(type))
            }
        }
    }

    private func deleteTypes(at offsets: IndexSet) {
        for index in offsets {
            let type = appState.taskTypes[index]
            appState.deleteTaskType(type)
        }
    }
}

/// Sheet to add or edit a task type: name and color (from presets).
struct AddEditTaskTypeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    enum Mode {
        case add
        case edit(TaskType)
    }
    let mode: Mode

    @State private var name = ""
    @State private var colorHex = "007AFF"

    private let presetColors = ["007AFF", "34C759", "FF9500", "FF3B30", "AF52DE", "5856D6"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Type name", text: $name)
                }
                Section("Color") {
                    HStack(spacing: 12) {
                        ForEach(presetColors, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .stroke(colorHex == hex ? Color.primary : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture { colorHex = hex }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(isEditing ? "Edit Type" : "New Type")
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
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                if case .edit(let type) = mode {
                    name = type.name
                    colorHex = type.colorHex
                }
            }
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func save() {
        switch mode {
        case .add:
            appState.addTaskType(TaskType(name: name, colorHex: colorHex))
        case .edit(let existing):
            var updated = existing
            updated.name = name
            updated.colorHex = colorHex
            appState.updateTaskType(updated)
        }
    }
}

#Preview {
    TaskTypeManagerView().environmentObject(AppState())
}
