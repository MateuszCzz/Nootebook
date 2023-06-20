import SwiftUI
import UIKit

struct AddNotebookView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @State private var name = ""
    @State private var description = ""
    @State private var password = ""
    @State private var creationDate = Date()
    @State private var selectedImage: UIImage?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isShowingImagePicker = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notebook Details")) {
                    TextField("Name", text: $name)
                        .padding(.vertical, 8)
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .padding(.vertical, 8)
                    SecureField("Password", text: $password)
                        .padding(.vertical, 8)
                    DatePicker("Creation Date", selection: $creationDate, in: ...Date(), displayedComponents: .date)
                        .padding(.vertical, 8)
                }
                
                Section(header: Text("Notebook Image")) {
                    Button(action: {
                        isShowingImagePicker = true
                    }) {
                        Text("Choose Image")
                    }
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                    }
                }

                Section {
                    Button("Save") {
                        saveNotebook()
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationBarTitle("Add Notebook")
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Validation Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $isShowingImagePicker, onDismiss: loadImage) {
            ImagePicker(sourceType: .photoLibrary) { image in
                selectedImage = image
            }
        }
    }

    private func saveNotebook() {
        guard !name.isEmpty else {
            showAlert(message: "Please enter a name for the notebook.")
            return
        }
        
        guard !description.isEmpty else {
            showAlert(message: "Please enter a description for the notebook.")
            return
        }
        
        guard creationDate <= Date() else {
            showAlert(message: "Creation date cannot be in the future.")
            return
        }
        

        // Save notebook
        withAnimation {
            let newNotebook = Notebook(context: viewContext)
            newNotebook.notebookID = UUID()
            newNotebook.name = name
            newNotebook.desc = description
            newNotebook.password = password
            newNotebook.creationDate = creationDate
            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func loadImage() {
        // Handle the selected image from the image picker
    }

    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}

struct AddNotebookView_Previews: PreviewProvider {
    static var previews: some View {
        AddNotebookView()
    }
}
