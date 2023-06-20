import CoreData
import SwiftUI

struct NotebookSettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    var notebookID: UUID

    @State private var name = ""
    @State private var description = ""
    @State private var password = ""
    @State private var creationDate = Date()
    @State private var selectedImage: UIImage?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isShowingImagePicker = false

    private var notebook: Notebook? {
        NecessaryFunctions.fetchNotebook(with: notebookID, in: viewContext)
    }

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
                        validateInputFields()
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationBarTitle("Notebook Settings")
        }
        .sheet(isPresented: $isShowingImagePicker, onDismiss: loadImage) {
            ImagePicker(sourceType: .photoLibrary) { image in
                selectedImage = image
            }
        }
        .onAppear {
            if let notebook = notebook {
                name = notebook.name ?? ""
                description = notebook.desc ?? ""
                creationDate = notebook.creationDate ?? Date()
                if let imageData = notebook.image {
                    selectedImage = UIImage(data: imageData)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Validation Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func validateInputFields() {
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

        validatePassword()
    }

    private func validatePassword() {
        
        if password == notebook!.password || !NecessaryFunctions.isPasswordRequired(notebook: notebook!) {
            updateNotebook()
        } else {
            showAlert(message: "Invalid password")
        }
    }

    private func updateNotebook() {
        guard let notebook = self.notebook else {
            return
        }

        withAnimation {
            notebook.name = name
            notebook.desc = description
            notebook.password = password
            notebook.creationDate = creationDate

            if let selectedImage = selectedImage {
                if let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
                    notebook.image = imageData
                }
            }

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

struct NotebookSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotebookSettingsView(notebookID: UUID())
    }
}
