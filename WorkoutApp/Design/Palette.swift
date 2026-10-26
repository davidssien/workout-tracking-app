import SwiftUI
import UIKit

/// Semantic colors adapt to the account's appearance setting and the system theme.
enum Palette {
    static let blue = adaptive(0x169EDB, 0x55C7F5)
    static let darkBlue = adaptive(0x0876A7, 0x8AD9F8)
    static let ink = adaptive(0x182D43, 0xF2F5FC)
    static let muted = adaptive(0x64778B, 0xA6B5CB)
    static let pale = adaptive(0xE3F4FF, 0x183449)
    static let background = adaptive(0xF4F7FC, 0x101823)
    static let surface = adaptive(0xFFFFFF, 0x1C2838)
    static let line = adaptive(0xDFE7F0, 0x334359)
    static let purple = adaptive(0x8461E8, 0xB49AFF)
    static let mint = adaptive(0x278C78, 0x6BDBC0)
    static let coral = adaptive(0xCD654C, 0xFFAA8B)

    static func adaptive(_ light: UInt, _ dark: UInt) -> Color {
        Color(uiColor: UIColor { traits in
            let value = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: CGFloat((value >> 16) & 255) / 255,
                           green: CGFloat((value >> 8) & 255) / 255,
                           blue: CGFloat(value & 255) / 255, alpha: 1)
        })
    }
}

enum WorkoutStyle {
    static let icons = ["dumbbell.fill", "bolt.fill", "flame.fill", "figure.boxing", "figure.run", "figure.yoga", "heart.fill", "mountain.2.fill", "figure.core.training", "figure.strengthtraining.traditional", "trophy.fill", "sparkles"]
    static let colors = ["sky", "violet", "mint", "coral"]
    static func color(_ name: String?) -> Color {
        switch name {
        case "violet": Palette.purple
        case "mint": Palette.mint
        case "coral": Palette.coral
        default: Palette.blue
        }
    }
}
