//
//  ThemeConstants.swift
//  AskAnAIExpertTool
//
//  Created by Bhavik Baraiya on 26/03/26.
//

import SwiftUI

/// Centralized theme constants for the NCLEX Expert application
/// This ensures consistent styling across all screens while maintaining brand hierarchy
struct ThemeConstants {
    // MARK: - Primary Colors
    /// Primary brand color - Primary Dark Red
    /// Used for: Buttons, interactive elements, highlights
    static let primaryRed = Color(red: 1.0, green: 59/255, blue: 48/255) // #FF3B30
    
    /// Accent color - Lighter red tone
    /// Used for: Borders, secondary accents, dividers
    static let accentRed = Color(red: 1.0, green: 107/255, blue: 107/255) // #FF6B6B
    
    // MARK: - Background Colors
    /// Main scaffold background - Pure white
    /// Used for: Primary app backgrounds, cards
    static let white = Color.white // #FFFFFF
    
    /// Light theme variant (10% opacity of primary red over white)
    /// Used for: Input fields, data display containers, subtle overlays
    static let lightThemeTint = primaryRed.opacity(0.1) // 10% opacity
    
    /// Light theme variant (5% opacity of primary red over white)
    /// Used for: Very subtle backgrounds, section cards
    static let lightThemeTintSubtle = primaryRed.opacity(0.05) // 5% opacity
    
    /// Background tint - Light pink tone
    /// Deprecated: Use lightThemeTint instead for consistency
    @available(*, deprecated, renamed: "lightThemeTint")
    static let backgroundTint = Color(red: 1.0, green: 241/255, blue: 240/255) // #FFF1F0
    
    /// Section card background - Very light pink
    /// Deprecated: Use lightThemeTintSubtle instead for consistency
    @available(*, deprecated, renamed: "lightThemeTintSubtle")
    static let sectionCardBg = Color(red: 1.0, green: 245/255, blue: 245/255) // #FFF5F5
    
    // MARK: - Semantic Colors
    static let text = Color.black
    static let secondaryText = Color.gray
    static let border = accentRed.opacity(0.2)
    
    // MARK: - Component Sizes
    static let cornerRadius: CGFloat = 12
    static let smallCornerRadius: CGFloat = 8
    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 8
    
    // MARK: - Shadow Values
    static let shadowColor = primaryRed.opacity(0.1)
    static let shadowRadius: CGFloat = 4
    static let shadowX: CGFloat = 0
    static let shadowY: CGFloat = 2
}
