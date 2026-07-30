import SwiftUI

// Matches the Runwell web dashboard dark theme.
enum Theme {
    static let bg      = Color(hex: 0x131315)
    static let soft    = Color(hex: 0x1D1D20)
    static let ink     = Color(hex: 0xEDEDED)
    static let muted   = Color(hex: 0x9A9A9E)
    static let faint   = Color(hex: 0x6F6F74)
    static let line    = Color(hex: 0x2A2A2E)
    static let accent  = Color(hex: 0xEDEDED)
    static let sidebar = Color(hex: 0x17171A)

    static let font = Font.system(.body, design: .rounded)
    static let title = Font.system(.title2, design: .rounded).weight(.semibold)
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: alpha
        )
    }
}
