import CoreData
import SwiftUI

struct NecessaryFunctions {
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        return formatter
    }
    
    static func fetchNotebook(with notebookID: UUID, in context: NSManagedObjectContext) -> Notebook? {
        let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "notebookID == %@", notebookID as CVarArg)
        
        do {
            let notebooks = try context.fetch(fetchRequest)
            return notebooks.first
        } catch {
            print("Failed to fetch notebook: \(error)")
            return nil
        }
    }
    static func isPasswordRequired(notebook: Notebook) -> Bool {
        return notebook.password != nil && !notebook.password!.isEmpty
    }
    
    static func backButton(selectedNotebookID: Binding<UUID?>, isPasswordEntered: Binding<Bool>) -> some View {
            Button(action: {
                selectedNotebookID.wrappedValue = nil
                isPasswordEntered.wrappedValue = false
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .foregroundColor(.blue)
                        .padding(.trailing, 5)
                    Text("Notebooks")
                        .foregroundColor(.blue)
                }
            }
        }
    }
