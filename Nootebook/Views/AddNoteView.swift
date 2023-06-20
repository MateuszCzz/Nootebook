import SwiftUI
import CoreData


struct AddNoteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @ObservedObject var notebook: Notebook
    
    @State private var noteName = ""
    @State private var noteDescription = ""
    @State private var noteColor = Color.black
    @State private var creationDate = Date()
    @State private var happiness: Int16 = 1
    @State private var showAlert = false
    @State private var alertMessage = ""
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Note Details")) {
                    TextField("Name", text: $noteName)
                    ColorPicker("Color", selection: $noteColor)
                    DatePicker("Creation Date", selection: $creationDate, in: ...Date(), displayedComponents: .date)
                    Stepper("Happiness: \(happiness)", value: $happiness, in: 1...5)
                    MultilineTextView(text: $noteDescription)
                                   .frame(height: 200)
                                   .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                           }
            }
            .navigationTitle("New Note")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Validation Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if validateNoteFields() {
                            addNewNote()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func validateNoteFields() -> Bool {

        guard !noteName.isEmpty else {
            showAlert(message: "Please enter a name for the note.")
            return false
        }
        guard !noteDescription.isEmpty else {
            showAlert(message: "Please enter a description for the notebook.")
            return false
        }
        guard creationDate <= Date() else {
            showAlert(message: "Creation date cannot be in the future.")
            return false
        }
        
        return true
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
    private func addNewNote() {
        withAnimation {
            let newNote = Note(context: viewContext)
            newNote.noteID = UUID()
            newNote.name = noteName
            newNote.desc = noteDescription
            newNote.color = noteColor.toHex()
            newNote.notebook = notebook
            newNote.happiness = happiness
            do {
                try viewContext.save()
            } catch {
                // Handle error
                print("Failed to save new note: \(error)")
            }
        }
    }
}




struct AddNoteView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let notebook = Notebook(context: context)
        notebook.notebookID = UUID()
        
        return AddNoteView(notebook: notebook)
            .environment(\.managedObjectContext, context)
    }
}

extension Color {
    func toHex() -> String? {
        guard let uiColor = UIColor(self).cgColor.components else {
            return nil
        }

        let red = uiColor[0]
        let green = uiColor[1]
        let blue = uiColor[2]

        let hexString = String(format: "#%02lX%02lX%02lX",
                               lroundf(Float(red) * 255),
                               lroundf(Float(green) * 255),
                               lroundf(Float(blue) * 255))

        return hexString
    }
}




extension UIColor {
    func toHexString() -> String {
        guard let components = self.cgColor.components else {
            return ""
        }
        
        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])
        
        let hexString = String(format: "#%02lX%02lX%02lX", lroundf(red * 255), lroundf(green * 255), lroundf(blue * 255))
        return hexString
    }
}
