import SwiftUI
import CoreData

struct NotebookDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    enum ActiveSheet: Identifiable {
        case settings, addNote
        
        var id: Int {
            hashValue
        }
    }
    
    @ObservedObject var notebook: Notebook
    @State private var activeSheet: ActiveSheet?
    @State private var selectedNotebook: Notebook?
    @State private var showSettings = false
    @State private var showCreateNoteSheet = false
    @State private var refreshID = UUID()
    @FetchRequest(fetchRequest: Note.fetchRequest()) var noteResults: FetchedResults<Note>
    @State private var notes: [Note] = []
    
    init(notebook: Notebook) {
        self.notebook = notebook
        _noteResults = FetchRequest(
            entity: Note.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Note.creationDate, ascending: false)
            ],
            predicate: NSPredicate(format: "notebook == %@", notebook)
        )
    }
    
    var body: some View {
        VStack {
            Text("Notes from \(notebook.name ?? "?")")
                .font(.title)
                .onLongPressGesture {
                    activeSheet = .settings
                    print(notebook.notebookID!)
                }
            
            Text("\(notebook.desc ?? "?")")
                .onLongPressGesture {
                    activeSheet = .settings
                }
            Text("\(notebook.creationDate ?? Date(), formatter: NecessaryFunctions.dateFormatter)")
                .font(.system(size: 12))
                .onLongPressGesture {
                    activeSheet = .settings
                }
            Divider()
            
            List {
                Button(action: {
                    activeSheet = .addNote
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                }
                
                ForEach(notes.indices, id: \.self) { index in
                    let note = notes[index]
                    let previousNote = index > 0 ? notes[index - 1] : nil
                    
                    NavigationLink(destination: NoteDetailView(note: note)) {
                        NoteView(note: note, previousNote: previousNote)
                    }
                }
                .onDelete(perform: deleteNotes)
                .id(refreshID)
                .onAppear {
                    loadNotes()
                }
            
            }
            .onAppear {
                loadNotes()
            }
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .settings:
                NotebookSettingsView(notebookID: notebook.notebookID!)
                    .environment(\.managedObjectContext, viewContext)
            case .addNote:
                AddNoteView(notebook: notebook)
                    .environment(\.managedObjectContext, viewContext)
                    .onDisappear {
                        refreshID = UUID()
                        loadNotes()
                    }
            }
        }

        .onAppear {
            loadNotes()
        }
    }
    
    private func loadNotes() {
        notes = Array(noteResults)
    }
    
    private func deleteNotes(offsets: IndexSet) {
        
        DispatchQueue.main.async {
            withAnimation {
                offsets.map { notes[$0] }.forEach { note in
                    viewContext.delete(note)
                }
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            refreshID = UUID()
            loadNotes()
        }
    }
}


struct NotebookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let notebook = Notebook(context: context)
        notebook.notebookID = UUID()
        
        return NotebookDetailView(notebook: notebook)
            .environment(\.managedObjectContext, context)
    }
}
