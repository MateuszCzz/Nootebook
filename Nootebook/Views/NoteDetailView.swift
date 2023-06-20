import SwiftUI
import CoreData

struct NoteDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @ObservedObject var note: Note
    
    @State private var noteName: String
    @State private var noteDescription: String
    @State private var noteColor: Color
    @State private var creationDate: Date
    @State private var happiness: Int16
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    init(note: Note) {
        self.note = note
        _noteName = State(initialValue: note.name ?? "")
        _noteDescription = State(initialValue: note.desc ?? "")
        _noteColor = State(initialValue: Color(hexString: note.color ?? "") ?? .black)
        _creationDate = State(initialValue: note.creationDate ?? Date())
        _happiness = State(initialValue: note.happiness)
    }
    
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
            .navigationTitle("Edit Note")
            .onAppear {
                noteName = note.name ?? ""
                noteDescription = note.desc ?? ""
                noteColor = Color(hexString: note.color ?? "") ?? .black
                creationDate = note.creationDate ?? Date()
                happiness = note.happiness
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Validation Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if validateNoteFields() {
                            updateNote()
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
    
    private func updateNote() {
        withAnimation {
            note.name = noteName
            note.desc = noteDescription
            note.color = noteColor.toHex()
            note.creationDate = creationDate
            note.happiness = happiness
            
            do {
                try viewContext.save()
            } catch {
                // Handle error
                print("Failed to update note: \(error)")
            }
        }
    }
}

struct NoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let note = Note(context: context)
        note.name = "Sample Note"
        note.desc = "This is a sample note."
        note.color = "#FF0000"
        note.creationDate = Date()
        note.happiness = 3
        
        return NoteDetailView(note: note)
            .environment(\.managedObjectContext, context)
    }
}

extension Color {
    init?(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
    
    func toHex() -> String {
        let components = self.rgbComponents
        let r = UInt8(components.red * 255.0)
        let g = UInt8(components.green * 255.0)
        let b = UInt8(components.blue * 255.0)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    
    private var rgbComponents: (red: Double, green: Double, blue: Double) {
        guard let colorSpace = cgColor?.colorSpace, colorSpace.model == .rgb else {
            return (red: 0, green: 0, blue: 0)
        }
        
        let color = cgColor?.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)!
        
        let components = color?.components ?? [0, 0, 0, 0]
        return (red: Double(components[0]), green: Double(components[1]), blue: Double(components[2]))
    }
}
