//
//  ContentView.swift
//  TodoListApp
//
//  Created by Peter G Hayes on 22/02/2023.
//

import SwiftUI
import CoreData

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dateHolder: DateHolder
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskItem.dueDate, ascending: true)],
        animation: .default)
    
    private var items: FetchedResults<TaskItem>
    
    @State private var points: Int = 0
    
    var body: some View {
        NavigationView {
            VStack (alignment: HorizontalAlignment.leading) {
//                Text("XP: \(points)").frame(alignment: Alignment.leading).padding(16)
                
                
                ZStack{
                    
                    ScrollView {
                        LazyVStack.init(spacing: 0, pinnedViews: [.sectionHeaders], content: {
                            ForEach(items, id: \.self) { taskItem in
                                NavigationLink(destination: TaskEditView(passedTaskItem: taskItem, initialDate: Date())
                                    .environmentObject(dateHolder))
                                {
                                    ContentCell(data: taskItem.name ?? "")
                                        
                                        .addRiveSwipeAction(onSwipeLeft: {
                                            print("swipe left")
                                            points -= 10
                                        }, onSwipeRight: {
                                            points += 10
                                            print("swipe right")
                                        })
                                }
                                
                            }
                        })
                    }.navigationTitle("Daily To Do")
                    
                    ZStack(alignment: .bottom) {
                        Color.clear
                        FloatingButton().environmentObject(dateHolder)
                    }
                    
                }
            }
        }
    }
    
    private func deleteItem(item: TaskItem) {
        withAnimation {
            viewContext.delete(item)
            
            dateHolder.saveContext(viewContext)
        }
    }
    
    
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            dateHolder.saveContext(viewContext)
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
