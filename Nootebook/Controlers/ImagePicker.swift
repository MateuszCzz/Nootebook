import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    typealias Coordinator = ImagePickerCoordinator

    var sourceType: UIImagePickerController.SourceType
    var completionHandler: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(completionHandler: completionHandler)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let completionHandler: (UIImage?) -> Void

        init(completionHandler: @escaping (UIImage?) -> Void) {
            self.completionHandler = completionHandler
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                completionHandler(selectedImage)
            } else {
                completionHandler(nil)
            }

            picker.dismiss(animated: true, completion: nil)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            completionHandler(nil)
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

extension View {
    func imagePicker(sourceType: UIImagePickerController.SourceType, completionHandler: @escaping (UIImage?) -> Void) -> some View {
        sheet(isPresented: .constant(true)) {
            ImagePicker(sourceType: sourceType, completionHandler: completionHandler)
        }
    }
}
