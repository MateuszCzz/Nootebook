import SwiftUI

struct NotebookPasswordEntryView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var notebook: Notebook
    @Binding var isShowingPasswordEntry: Bool
    @State private var password = ""
    @State private var showAlert = false
    let passwordEnteredCallback: (UUID) -> Void
    
    var body: some View {
        VStack {
            SecureField("Enter password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Submit") {
                if password == notebook.password {
                    passwordEnteredCallback(notebook.notebookID!)
                    presentationMode.wrappedValue.dismiss()
                } else {
                    showAlert = true
                }
            }
            .padding()

            Spacer()
        }
        .navigationBarTitle("Enter Password")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Incorrect Password"), message: Text("Please enter the correct password."), dismissButton: .default(Text("OK")))
        }
    }
}

struct NotebookPasswordEntryView_Previews: PreviewProvider {
    static var previews: some View {
        let notebook = Notebook()
        return NotebookPasswordEntryView(notebook: notebook, isShowingPasswordEntry: .constant(true), passwordEnteredCallback: { _ in })
    }
}
