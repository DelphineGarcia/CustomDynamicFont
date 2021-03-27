//
//  CustomDynamicLabel.swift
//  CustomDynamicFont
//
//  Created by GARCIA Delphine on 12/03/2021.
//

import UIKit

public class CustomDynamicLabel: UILabel {

    private var textStyle: String?
    private var attributesArray: [[NSAttributedString.Key : Any]] = []
    public var lineHeightMultiple: CGFloat?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupDynamicLabel()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDynamicLabel()
    }

    public override var text: String? {
        willSet(newValue) {
            registerOldAttributes(text: newValue)
        }
        didSet {
            setupDynamicLabel()
            applyAttributesIfNecessary()
        }
    }
}

// MARK: - Private functions
public extension CustomDynamicLabel {

    private func registerOldAttributes(text: String?) {
        guard let attributedText = attributedText, let text = text, !text.isEmpty else { return }
        attributesArray.removeAll()
        attributedText.enumerateAttributes(in: NSRange(0..<attributedText.length), options: .longestEffectiveRangeNotRequired, using: { (dict, range, _) in
            if range == NSRange(location: 0, length: attributedText.length) {
                attributesArray.append(dict)
            }
        })
    }

    func setupDynamicLabel() {
        if let text = text, !text.isEmpty {
            applyStyle(to: text)
        }
    }

    private func applyAttributesIfNecessary() {
        guard let attrText = attributedText, !attrText.string.isEmpty else { return }

        // Save settings before setAttributedText
        let defaultLineBreakMode = lineBreakMode
        let defaultAdjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        let defaultMinimumScaleFactor = minimumScaleFactor

        let attributedString = NSMutableAttributedString()
        attributedString.append(attrText)
        attributesArray.forEach({ attributedString.addAttributes($0, range: NSRange(location: 0, length: attributedString.length)) })

        if let multiple = lineHeightMultiple {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = multiple
            paragraphStyle.alignment = textAlignment
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        }

        attributedText = attributedString
        attributesArray.removeAll()

        // Apply previous settings after setAttributedText
        lineBreakMode = defaultLineBreakMode
        adjustsFontSizeToFitWidth = defaultAdjustsFontSizeToFitWidth
        minimumScaleFactor = defaultMinimumScaleFactor
    }

    private func applyStyle(to text: String) {
        if textStyle == nil, let style = font.fontDescriptor.object(forKey: UIFontDescriptor.AttributeName.textStyle) as? UIFont.TextStyle {
            textStyle = style.rawValue
        }
        if let customFont = CustomDynamicFontManager.getFont(forStyle: textStyle, dynamicMode: adjustsFontForContentSizeCategory) {
            font = customFont
        }
    }
}
