import SwiftUI

struct MarkdownRendererView: View {
    let markdown: String
    let images: [Data]

    var body: some View {
        // Split the markdown string into blocks
        // For a more robust solution, you'd use a markdown parser library.
        let lines = markdown.components(separatedBy: .newlines)
        
        VStack(alignment: .leading, spacing: 12) {
            ForEach(lines.indices, id: \.self) { index in
                let line = lines[index]
                
                if line.hasPrefix("![image-") {
                    // Render an Image
                    if let imageIndex = parseImageIndex(from: line),
                       imageIndex < images.count,
                       let uiImage = UIImage(data: images[imageIndex]) {
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding(.vertical)
                    }
                } else if line.hasPrefix("- ") {
                    // Render a list item
                    HStack(alignment: .top) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .offset(y: 8)
                            .foregroundColor(.secondary)
                        Text(formatMarkdownText(line.replacingOccurrences(of: "- ", with: "")))
                            .lineLimit(nil)
                    }
                } else if line.hasPrefix(">") {
                    // Render a quote
                    Text(formatMarkdownText(line.replacingOccurrences(of: ">", with: "")))
                        .italic()
                        .font(.system(size: 17, design: .serif))
                        .padding(.leading, 10)
                        .overlay(
                            Rectangle()
                                .frame(width: 3, height: nil)
                                .foregroundColor(.secondary),
                            alignment: .leading
                        )
                        .padding(.vertical, 5)
                } else {
                    // Render plain or bold/italic text
                    Text(formatMarkdownText(line))
                        .lineLimit(nil)
                }
            }
        }
    }

    // A helper to extract the image index from the placeholder
    func parseImageIndex(from line: String) -> Int? {
        let regex = #"!\[image-(\d+)\]"#
        if let match = line.range(of: regex, options: .regularExpression) {
            let numberString = line[match].replacingOccurrences(of: "![image-", with: "").replacingOccurrences(of: "]", with: "")
            return Int(numberString)
        }
        return nil
    }

    // A helper to apply bold and italic formatting using AttributedString
    func formatMarkdownText(_ text: String) -> AttributedString {
        var formatted = AttributedString(text)
        
        // Find and format bold text
        let boldRegex = #"\*\*(.*?)\*\*"#
        if let boldMatches = try? NSRegularExpression(pattern: boldRegex).matches(in: text, range: NSRange(text.startIndex..., in: text)) {
            for match in boldMatches.reversed() {
                if let range = Range(match.range, in: text) {
                    formatted.characters.removeSubrange(range)
                    let boldText = text[range].dropFirst(2).dropLast(2)
                    var boldPart = AttributedString(boldText)
                    boldPart.font = .body.weight(.bold)
                    formatted.characters.insert(contentsOf: boldPart.characters, at: formatted.characters.index(formatted.characters.startIndex, offsetBy: match.range.location))
                }
            }
        }
        
        // Find and format italic text
        let italicRegex = #"\*(.*?)\*"#
        if let italicMatches = try? NSRegularExpression(pattern: italicRegex).matches(in: text, range: NSRange(text.startIndex..., in: text)) {
            for match in italicMatches.reversed() {
                if let range = Range(match.range, in: text) {
                    formatted.characters.removeSubrange(range)
                    let italicText = text[range].dropFirst().dropLast()
                    var italicPart = AttributedString(italicText)
                    italicPart.font = .body.italic()
                    formatted.characters.insert(contentsOf: italicPart.characters, at: formatted.characters.index(formatted.characters.startIndex, offsetBy: match.range.location))
                }
            }
        }
        
        return formatted
    }
}