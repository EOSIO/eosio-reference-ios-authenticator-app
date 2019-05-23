
//
//  ExpiringButton.swift
//  ExpirationButton
//
//  Created by Farid Rahmani on 1/18/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import UIKit
@IBDesignable
public class ExpiringButton: UIView {
    
    typealias CallBack = ()->Void
    
    /**
        The block that will be called when the time expires.
    */
    var expirationBlock:CallBack?
    
    /**
        The block that will be called when the button is tapped.
    */
    var tapBlock:CallBack?
    
    
    private var started = false //Set to true once the animation is started by startAnimation(:) method.
    
    var animationStarted:Bool{
        get{
            return started
        }
    }
    
    /**
        Total duration time that the button will be active.
    */
    var duration:TimeInterval{
        return propertyAnimator.duration
    }
    
    /**
        The fraction of the animation that is completed so far.
    */
    var completedAnimationFraction:CGFloat{
        return propertyAnimator.fractionComplete
    }
    
    /**
        The label that is shown while the time is not expired yet.
    */
    private let foregroundLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /**
        The label that will be unmasked by the mask.
    */
    private let backgroundLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    @IBInspectable public var text:String?{
        didSet{
            foregroundLabel.text = text
            backgroundLabel.text = text
        }
    }
    
    @IBInspectable public var fontSize:CGFloat = 17{
        didSet{
            let font = UIFont(name: fontName, size: fontSize)
            foregroundLabel.font = font
            backgroundLabel.font = font
        }
    }
    
    @IBInspectable public var fontName:String = "Helvetica"{
        didSet{
            let font = UIFont(name: fontName, size: fontSize)
            foregroundLabel.font = font
            backgroundLabel.font = font
        }
    }
    
    var isEnabled:Bool = true
    
    @IBInspectable public var expiredText:String? = "Expired"
    
    /**
        Normal background color.
    */
    @IBInspectable public var foregroundColor:UIColor?{
        didSet{
            foregroundLabel.backgroundColor = foregroundColor
        }
    }
    
    /**
        Background when expired.
    */
    override public var backgroundColor: UIColor?{
        didSet{
            backgroundLabel.backgroundColor = backgroundColor
        }
    }
    
    @IBInspectable public var textColor:UIColor?{
        didSet{
            foregroundLabel.textColor = textColor
        }
        
    }
    
    @IBInspectable public var expiredTextColor:UIColor?{
        didSet{
            backgroundLabel.textColor = expiredTextColor
        }
    }
    
    @IBInspectable public var cornerRadius:CGFloat = 0{
        didSet{
            layer.cornerRadius = cornerRadius
            clipsToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable public var font:UIFont?{
        didSet{
            foregroundLabel.font = font
            backgroundLabel.font = font
        }
    }
    
    private var propertyAnimator = UIViewPropertyAnimator()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
       
    }
    
    private func setup(){
        
        addSubview(foregroundLabel)
        foregroundLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        foregroundLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        foregroundLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        foregroundLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(backgroundLabel)
        backgroundLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        backgroundLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        backgroundLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        backgroundLabel.isHidden = true
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(sender:))))
        
    }
    

    
    @objc
    private func tapped(sender:UITapGestureRecognizer){
        if isEnabled{
            tapBlock?()
        }
    }
    
    private let viewMask = UIView() //View used as mask for backgroundLabel
    
    /**
        Starts the animation.
 
        - Parameters:
            -animationTime:Number of seconds remaining until expiration.
    */
    func startAnimation(animationTime:TimeInterval) {
        if started{
            return
        }
        started = true
        viewMask.backgroundColor = UIColor.gray
        viewMask.frame = bounds
        viewMask.frame.origin.x = bounds.width
        backgroundLabel.mask = viewMask
        backgroundLabel.isHidden = false
        propertyAnimator = UIViewPropertyAnimator(duration: animationTime, curve: .linear) {[weak self] in
            self?.viewMask.frame.origin.x = 0
        }
        propertyAnimator.addCompletion {[weak self] (position) in
            self?.setToExpired()
        }
        propertyAnimator.startAnimation()
        
    }
    
    
    
    
    /**
        Calls this block when time is expired.
     -Parameters:
        -callBack: The block to call when time is out.
     
    */
    func doWhenExpired(_ callBack:@escaping ()->Void) {
        self.expirationBlock = callBack
        
    }
    
    /**
     Calls this block when button is tapped.
     -Parameters:
        -callBack: The block to call when button is tapped.
     
     */
    func doWhenTapped(_ callBack:@escaping ()->Void) {
        self.tapBlock = callBack
    }
    
    
    /*
        Stops the animation, corrects the animation position, and resets the timout of the animation based on remainingTime and fractionComplete arguments.
     -Parameters:
        -fractionComplete: The fraction of the animation that is completed.
        -remainingTime: The time that is remaining until the end of animation.
     */
    func continueAnimation(withFractionComplete completed:CGFloat, remainingTime:TimeInterval) {
        let remainingX = backgroundLabel.bounds.width * completed
        propertyAnimator.stopAnimation(true)
        viewMask.frame.origin.x = remainingX
        propertyAnimator = UIViewPropertyAnimator(duration: remainingTime, curve: .linear) {[weak self] in
            self?.viewMask.frame.origin.x = 0
        }
        propertyAnimator.addCompletion {[weak self] (position) in
            self?.setToExpired()
            
            
        }
        propertyAnimator.startAnimation()
    }
    
    /**
        Sets button state to expired.
    */
    func setToExpired() {
        viewMask.frame.origin.x = 0
        backgroundLabel.text = expiredText
        isEnabled = false
        expirationBlock?()
        
    }
    
    /**
        Starts the animation from a different location based on fractionComplete argument.
     
        -Parameters:
            -fractionComplete: A number between 0.0 an 1.0 with 0.0 being the start location of animation and 1.0 being the end location of animation
     
    */
    func restartFrom(fractionComplete complete: CGFloat) {
        propertyAnimator.pauseAnimation()
        propertyAnimator.fractionComplete = complete
        propertyAnimator.startAnimation()
    }
    
    func stopAnimation() {
        propertyAnimator.stopAnimation(true)
    }
    
    func approved() {
        
    }
}


