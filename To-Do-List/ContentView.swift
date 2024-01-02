//
//  ContentView.swift
//  To-Do-List
//
//  Created by Rafael Meha on 02/01/2024.
//

import SwiftUI

// TodoItem Struct
struct TodoItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
}

// TodoManager Class
class TodoManager: ObservableObject {
    @Published var todos: [TodoItem] = [] {
        didSet {
            saveTodos()
        }
    }

    init() {
        loadTodos()
    }

    private func saveTodos() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(todos) {
            UserDefaults.standard.set(encoded, forKey: "TodoList")
        }
    }

    private func loadTodos() {
        if let savedItems = UserDefaults.standard.data(forKey: "TodoList") {
            let decoder = JSONDecoder()
            if let decodedItems = try? decoder.decode([TodoItem].self, from: savedItems) {
                todos = decodedItems
                return
            }
        }
        todos = []
    }
}

// EditTodoView
struct EditTodoView: View {
    @Binding var todoItem: TodoItem

    var body: some View {
        Form {
            TextField("Todo", text: $todoItem.title)
            // Additional UI components for editing
        }
    }
}


// ContentView
struct ContentView: View {
    @StateObject private var todoManager = TodoManager()
    @State private var newTodoTitle = ""
    @State private var editingItem: TodoItem?

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(todoManager.todos.indices, id: \.self) { index in
                        Text(todoManager.todos[index].title)
                            .onTapGesture {
                                editingItem = todoManager.todos[index]
                            }
                    }
                    .onDelete(perform: deleteTodo)
                }

                HStack {
                    TextField("New todo", text: $newTodoTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
                        .frame(height: 40)

                    Button("Add") {
                        let newTodo = TodoItem(title: newTodoTitle)
                        todoManager.todos.append(newTodo)
                        newTodoTitle = ""
                    }
                    .frame(height: 35)
                    .padding(.horizontal, 10)
                    .background(Color.purple)
                    .foregroundColor(Color.white)
                    .cornerRadius(5)
                }
                .padding()
            }
            .navigationBarTitle("To-Do List")
        }
        .sheet(item: $editingItem, onDismiss: saveEdits) { item in
            EditTodoView(todoItem: Binding(get: {
                self.editingItem ?? TodoItem(title: "")
            }, set: { newValue in
                self.editingItem = newValue
            }))
        }
    }

    func deleteTodo(at offsets: IndexSet) {
        todoManager.todos.remove(atOffsets: offsets)
    }

    func saveEdits() {
        if let editingItem = editingItem,
           let index = todoManager.todos.firstIndex(where: { $0.id == editingItem.id }) {
            todoManager.todos[index] = editingItem
        }
        self.editingItem = nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
