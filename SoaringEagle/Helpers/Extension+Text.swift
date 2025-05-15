import SwiftUI

struct Extension_Text: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .gameFont(32)
    }
}

extension Text {
    func gameFont(_ size: CGFloat) -> some View {
        let baseFont = UIFont(name: "Titan One", size: size) ?? UIFont.systemFont(ofSize: size, weight: .heavy)
        let scaledFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont)

        return self
            .font(Font(scaledFont))
            .foregroundStyle(.white)
            .shadow(color: .black, radius: 1)
            .multilineTextAlignment(.center)
            .textCase(.uppercase)
    }
}

#Preview {
    Extension_Text()
}
