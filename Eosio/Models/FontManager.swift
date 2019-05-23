//
//  FontManager.swift
//  Eosio
//
//  Created by Adam Halper on 9/28/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import UIKit

// Usage Examples
let sourceSansPro18 = Font(.installed(.SourceSansProRegular), size: .standard(.body)).instance
public let sourceSansProSemiBold16 = Font(.installed(.SourceSansProSemibold ), size: .standard(.h5)).instance
let sourceSansProBold18 = Font(.installed(.SourceSansProBold), size: .standard(.body)).instance
let sourceSansProBold15 = Font(.installed(.SourceSansProBold), size: .custom(15)).instance
let sourceSansProBoldIt15 = Font(.installed(.SourceSansProBoldItalic), size: .custom(15)).instance
let sourceSansProBoldIt16 = Font(.installed(.SourceSansProBold), size: .custom(16)).instance
let sourceSansPro20 = Font(.installed(.SourceSansProRegular), size: .standard(.h4)).instance
let sourceSansPro30 = Font(.installed(.SourceSansProRegular), size: .standard(.h2)).instance
let sourceSansPro32 = Font(.installed(.SourceSansProRegular), size: .standard(.h1)).instance
let sourceSansProBold30 = Font(.installed(.SourceSansProBold), size: .custom(30)).instance
let sourceSansProBold36 = UIFont(name: "SourceSansPro-Bold", size: 36)
let sourceSansProBold16 = UIFont(name: "SourceSansPro-Bold", size: 16)
let sourceSansPro16 = Font(.installed(.SourceSansProRegular ), size: .custom(16)).instance
let sourceSansPro17 = Font(.installed(.SourceSansProRegular ), size: .custom(17)).instance

struct Font {

    enum FontType {
        case installed(FontName)
        case custom(String)
        case system
        case systemBold
        case systemItatic
        case systemWeighted(weight: Double)
        case monoSpacedDigit(size: Double, weight: Double)
    }
    enum FontSize {
        case standard(StandardSize)
        case custom(Double)
        var value: Double {
            switch self {
            case .standard(let size):
                return size.rawValue
            case .custom(let customSize):
                return customSize
            }
        }
    }

    enum FontName: String {
        case SourceSansProRegular          = "SourceSansPro-Regular"
        case SourceSansProItalic           = "SourceSansPro-It.otf"
        case SourceSansProSemibold         = "SourceSansPro-Semibold"
        case SourceSansProSemiboldItalic   = "SourceSansPro-SemiboldIt.otf"
        case SourceSansProBold             = "SourceSansPro-Bold"
        case SourceSansProBoldItalic       = "SourceSansPro-BoldIt"
        case SourceSansProLight            = "SourceSansPro-Light"
        case SourceSansProLightItalic      = "SourceSansPro-LightIt"
        case SourceSansProExtraLight       = "SourceSansPro-ExtraLight"
        case SourceSansProExtraLightItalic = "SourceSansPro-ExtraLightIt"
    }

    enum StandardSize: Double {
        case h1 = 32.0
        case h2 = 30.0
        case h3 = 24.0
        case h4 = 20.0
        case h5 = 16.0
        case body = 18.0
    }


    var type: FontType
    var size: FontSize
    init(_ type: FontType, size: FontSize) {
        self.type = type
        self.size = size
    }
}

extension Font {

    var instance: UIFont {

        var instanceFont: UIFont!
        switch type {
        case .custom(let fontName):
            guard let font =  UIFont(name: fontName, size: CGFloat(size.value)) else {
                fatalError("\(fontName) font is not installed, make sure it added in Info.plist and logged with Utility.logAllAvailableFonts()")
            }
            instanceFont = font
        case .installed(let fontName):
            guard let font =  UIFont(name: fontName.rawValue, size: CGFloat(size.value)) else {
                fatalError("\(fontName.rawValue) font is not installed, make sure it added in Info.plist and logged with Utility.logAllAvailableFonts()")
            }
            instanceFont = font
        case .system:
            instanceFont = UIFont.systemFont(ofSize: CGFloat(size.value))
        case .systemBold:
            instanceFont = UIFont.boldSystemFont(ofSize: CGFloat(size.value))
        case .systemItatic:
            instanceFont = UIFont.italicSystemFont(ofSize: CGFloat(size.value))
        case .systemWeighted(let weight):
            instanceFont = UIFont.systemFont(ofSize: CGFloat(size.value),
                                             weight: UIFont.Weight(rawValue: CGFloat(weight)))
        case .monoSpacedDigit(let size, let weight):
            instanceFont = UIFont.monospacedDigitSystemFont(ofSize: CGFloat(size),
                                                            weight: UIFont.Weight(rawValue: CGFloat(weight)))
        }
        return instanceFont
    }
}

class Utility {
    /// Logs all available fonts from iOS SDK and installed custom font
    class func logAllAvailableFonts() {
        for family in UIFont.familyNames {
            print("\(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   \(name)")
            }
        }
    }
}
