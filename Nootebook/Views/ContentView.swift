import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Notebook.creationDate, ascending: true)], animation: .default)
    private var notebooks: FetchedResults<Notebook>

    @State private var selectedNotebookID: UUID?
    @State private var isShowingPasswordEntry = false
    @State private var isShowingAddView = false
    @State private var isPasswordEntered = false
    
    var body: some View {
        NavigationView {
            if isPasswordEntered {
                // User has entered the password
                if let notebook = NecessaryFunctions.fetchNotebook(with: selectedNotebookID!, in: viewContext) {
                    NotebookDetailView(notebook: notebook)
                        .navigationBarBackButtonHidden(true)
                        .navigationBarItems(leading: NecessaryFunctions.backButton(selectedNotebookID: $selectedNotebookID, isPasswordEntered: $isPasswordEntered))
                }
            } else {
                // User has not entered the password
                List {
                    ForEach(notebooks) { notebook in
                        NavigationLink(
                            destination: getDestinationView(notebook: notebook),
                            label: {
                                HStack {
                                    if let imageData = notebook.image,
                                       let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(8)
                                    } else {
                                        Color.gray
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(8)
                                    }
                                    VStack(alignment: .leading) {
                                        Text(notebook.name ?? "")
                                            .font(.headline)
                                        Text(notebook.creationDate ?? Date(), style: .date)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        )
                    }
                    .onDelete(perform: deleteNotebooks)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isShowingAddView = true
                        }) {
                            Label("Add Notebook", systemImage: "plus")
                        }
                    }
                }
                .navigationTitle("Notebooks")
            }
        }
        .sheet(isPresented: $isShowingAddView) {
            AddNotebookView().environment(\.managedObjectContext, viewContext)
        }
    }

    private func getDestinationView(notebook: Notebook) -> AnyView {
        if NecessaryFunctions.isPasswordRequired(notebook: notebook) && !isPasswordEntered {
            return AnyView(NotebookPasswordEntryView(
                notebook: notebook,
                isShowingPasswordEntry: $isShowingPasswordEntry,
                passwordEnteredCallback: { enteredNotebookID in
                    isShowingPasswordEntry = false
                    selectedNotebookID = enteredNotebookID
                    isPasswordEntered = true
                }
            ))
        } else {
            return AnyView(NotebookDetailView(notebook: notebook))
        }
    }
    
    private func deleteNotebooks(offsets: IndexSet) {
        withAnimation {
            offsets.map { notebooks[$0] }.forEach { notebook in
                viewContext.delete(notebook)
            }

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
