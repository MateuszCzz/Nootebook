import SwiftUI

struct NoteView: View {
    let note: Note
    let previousNote: Note?

    var body: some View {
        VStack(alignment: .leading) {
            if let creationDate = note.creationDate {
                if let previousNote = previousNote {
                    if !Calendar.current.isDate(creationDate, inSameDayAs: previousNote.creationDate ?? Date()) {
                        Text(formatDate(creationDate))
                            .font(.title2)
                            .padding(.horizontal,50)
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                } else {
                    Text(formatDate(creationDate))
                        .font(.title2)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }

            Text(note.name ?? "")
                .font(.subheadline)
                .foregroundColor(getColor(from: note.color))
            

            if let desc = note.desc {
                Text(desc)
                    .font(.subheadline)
                    .padding()
            }

            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.caption)

                Text("\(note.happiness)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else {
            return ""
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }

    private func getColor(from colorString: String?) -> Color {
        guard let colorString = colorString,
              let color = UIColor(hexString: colorString) else {
            return .primary
        }

        return Color(color)
    }

}

struct NoteView_Previews: PreviewProvider {
    static var previews: some View {
        NoteView(note: Note(), previousNote: nil)
    }
}

extension UIColor {
    convenience init?(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)

        var alpha: CGFloat = 1.0
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0

        if hex.count == 6 {
            red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        } else if hex.count == 8 {
            alpha = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            red = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            green = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
            blue = CGFloat(rgbValue & 0x000000FF) / 255.0
        } else {
            return nil
        }

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
