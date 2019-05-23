//
//  UIExtensions.swift
//  Eosio
//
//  Created by Adam Halper on 8/17/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import LocalAuthentication

extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}

/*
public extension UIAlertController {
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindowLevelAlert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
    
    func show(andDismissAfterSeconds dismissAfter: Int) {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindowLevelAlert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
        
        let when = DispatchTime.now() + DispatchTimeInterval.seconds(dismissAfter)
        DispatchQueue.main.asyncAfter(deadline: when){
            self.dismiss(animated: true, completion: nil)
        }
    }

    func showCheckmark() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = SuccessCheckmarkViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindowLevelAlert
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
    
}
 */

extension UILabel {
    func underline() {
        if let textString = self.text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
    func numberOfVisibleLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String, font: UIFont = sourceSansProBold15 , foregroundColor: UIColor = UIColor.customBlueMarine) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: foregroundColor]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let normal = NSAttributedString(string: text)
        append(normal)
        
        return self
    }
}


private var kAssociationKeyMaxLength: Int = 0
extension UITextField {
    
    @IBInspectable var maxLength: Int {
        get {
            if let length = objc_getAssociatedObject(self, &kAssociationKeyMaxLength) as? Int {
                return length
            } else {
                return Int.max
            }
        }
        set {
            objc_setAssociatedObject(self, &kAssociationKeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
            addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
        }
    }
    
    @objc func checkMaxLength(textField: UITextField) {
        guard let prospectiveText = self.text,
            prospectiveText.count > maxLength
            else {
                return
        }
        
        let selection = selectedTextRange
        
        let indexEndOfText = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
        let substring = prospectiveText[..<indexEndOfText]
        text = String(substring)
        
        selectedTextRange = selection
    }
    
    func setPadding(){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}

extension UIViewController {

    var topbarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
}

extension String {
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }

    func matchingStrings(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))

        return results.map { result in
            (0..<result.numberOfRanges).map { result.range(at: $0).location != NSNotFound
                ? nsString.substring(with: result.range(at: $0))
                : ""
            }
        }
    }

    func isAbsoluteURL() -> Bool {
        return self.lowercased().contains("http://") || self.lowercased().contains("https://") ? true : false
    }
}

extension WKWebView {
    
    func loadHTML(fromString: String) {
        let htmlString = """
        <link rel="stylesheet" type="text/css" href="iPhone.css">
        <span style="">\(fromString)</span>
        """
        self.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
    }
}

extension UIImage {
    static func generateGradient(size : CGSize, colors : [UIColor], startPoint: CGPoint, endPoint: CGPoint) -> UIImage? {
        let cgcolors = colors.map { $0.cgColor }
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        defer { UIGraphicsEndImageContext() }
        var locations : [CGFloat] = [0.0, 1.0]
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: cgcolors as NSArray as CFArray, locations: &locations) else { return nil }
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        return UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
    }
}

extension UINavigationBar {
    func clear() {
        shadowImage = UIImage()
        setBackgroundImage(UIImage(), for: .default)
        backgroundColor = .clear
    }

    func applyGradient(colors : [UIColor] = [UIColor.customRoyalBlue, UIColor.customRoyalBlueLight]) {
        var frameAndStatusBar: CGRect = self.bounds
        frameAndStatusBar.size.height += 20 // add 20 to account for the status bar
        let start = CGPoint(x: 0.0, y: frameAndStatusBar.height)
        let end = CGPoint(x: frameAndStatusBar.width, y: 0.0)
        setBackgroundImage(UIImage.generateGradient(size: frameAndStatusBar.size, colors: colors, startPoint: start, endPoint: end), for: .default)
    }
}

extension UIButton {
    func applyGradient() {
        let start = CGPoint(x: 0.0, y: 0.0)
        let end = CGPoint(x: (self.frame.size.width * 1.4), y: 0.0)
        let gradientImage = UIImage.generateGradient(size: self.frame.size, colors: [UIColor.customRoyalBlue, UIColor.customTurquoise], startPoint: start, endPoint: end)
        self.setBackgroundImage(gradientImage, for: .normal)
    }
}

class LightBlueTransparentButtonWithDarkBorder: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.applyStyling()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.applyStyling()
    }

    func applyStyling() {
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 6
        self.layer.borderColor = UIColor.customDarkBlue.cgColor
        self.setTitleColor(UIColor.customRainySkyGray, for: .normal)
    }
}

class DarkBlueButtonWhiteTitle: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.applyStyling()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.applyStyling()
    }

    func applyStyling() {
        self.layer.cornerRadius = 6
        self.setTitleColor(UIColor.white, for: .normal)
        self.backgroundColor = UIColor.customNavyBlue
    }
}


class BounceButton: UIButton {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 6, options: .allowUserInteraction, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
        
        super.touchesBegan(touches, with: event)
    }
}

extension UIView {

    func applyShakeAnimation() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 8.0, y: self.center.y))
        animation.toValue   = NSValue(cgPoint: CGPoint(x: self.center.x + 8.0, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
}

extension LABiometryType {
    public var description: String {
        switch self {
        case .none:
            return "None"
        case .touchID:
            return "Touch ID"
        case .faceID:
            return "Face ID"
        default:
            return "None"
        }
    }
}

