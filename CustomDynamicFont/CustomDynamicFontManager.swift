//
//  CustomDynamicFontManager.swift
//  CustomDynamicFont
//
//  Created by GARCIA Delphine on 12/03/2018.
//

import UIKit

public typealias StyleFontDescription = [UIFont.TextStyle.RawValue: CustomFontDescription]
public typealias StyleDictionary = [UIContentSizeCategory.RawValue: StyleFontDescription]

public struct CustomFontDescription: Decodable {
    public let fontName: String
    public let fontSize: CGFloat
}

public final class CustomDynamicFontManager {
    
    private static var styleDict: StyleDictionary?
    private static let defaultFontSize: CGFloat = 17
    
    public static var styleDictionary: StyleDictionary? {
        if CustomDynamicFontManager.styleDict == nil {
            if let url = Bundle.main.url(forResource: "Caveat", withExtension: "plist"), let data = try? Data(contentsOf: url) {
                let decoder = PropertyListDecoder()
                CustomDynamicFontManager.styleDict = try? decoder.decode(StyleDictionary.self, from: data)
            } else {
                print("⚠️ CustomDynamicFontManager - Error on parsing Ubuntu.plist")
            }
        }
        return CustomDynamicFontManager.styleDict
    }
    
    public static func getFont(forStyle style: String?, dynamicMode: Bool) -> UIFont? {
        guard let style = style, let styleDictionary = CustomDynamicFontManager.styleDictionary else {
            return nil
        }
        var styleFontDescription: StyleFontDescription? = styleDictionary[UIContentSizeCategory.large.rawValue]
        if dynamicMode {
            styleFontDescription = styleDictionary[UIApplication.shared.preferredContentSizeCategory.rawValue]
        }
        var customFont: UIFont?
        if let fontDescription = styleFontDescription?[style] {
            customFont = UIFont(name: fontDescription.fontName, size: fontDescription.fontSize)
        }
        return customFont
    }
}

