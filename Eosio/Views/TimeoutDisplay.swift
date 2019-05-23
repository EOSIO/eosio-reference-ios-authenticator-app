//
//  TimerDisplay.swift
//  ExperimentForTimerDisplay
//
//  Created by Farid Rahmani on 2/6/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import UIKit

@IBDesignable
public class TimeoutDisplay: UIView {
    public enum Style {
        case small
        case medium
        case large
    }
    typealias CallBack = ()->Void
    
    /**
     The block that will be called when the time expires.
     */
    var expirationBlock:CallBack?
    
    
    
    private var started = false //Set to true once the animation is started by startAnimation(:) method.
    
    var animationStarted:Bool{
        get{
            return started
        }
    }
    
    /**
     Total duration time that the timerDisplay will be active.
     */
    var duration:TimeInterval{
        return animation.duration
    }
    
    /**
     The fraction of the animation that is completed so far.
     */
    var completedAnimationFraction:CGFloat{
        return 1 - activeCircle.strokeEnd
    }
    
    
    
    
    
    public var style:Style = .small{
        didSet{
            setup()
        }
    }
    
    
    @IBInspectable public var fontSize:CGFloat = 17{
        didSet{
            label.font = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
            
        }
    }
    
    @IBInspectable public var fontName:String = "San Francisco"{
        didSet{
            label.font = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
            
        }
    }
    
    var isEnabled:Bool = true
    private var currentTime:Int = 0
    private var timer:CADisplayLink?
    
    
    
    /**
     Normal background color.
     */
    @IBInspectable public var activeCircleColor:UIColor? = .lightGray{
        didSet{
            activeCircle.strokeColor = activeCircleColor?.cgColor
        }
    }
    //UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.41)
    @IBInspectable public var expiredCircleColor:UIColor? = UIColor.gray{
        didSet{
            expiredCircle.strokeColor = expiredCircleColor?.cgColor
        }
    }
    
    /**
     Empty override to prevent setting the views background color
     */
    override public var backgroundColor: UIColor?{
        set{
            //backgroundColor = .red
        }
        get{
            return .clear
        }
    }
    
    @IBInspectable public var textColor:UIColor? = .lightGray{
        didSet{
            label.textColor = textColor
        }
        
    }
    
    
    private let animation = CABasicAnimation(keyPath: "strokeEnd")
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        
    }
    
    public init(style: Style) {
        self.style = style
        super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 80, height: 80)))
        setup()
    }
    
    private var innerView:UIView!
    private var label = UILabel()
    private let expiredCircle = CAShapeLayer()
    private let activeCircle = CAShapeLayer()
    
    
    private func setup(){
        innerView?.removeFromSuperview()
        innerView = UIView()
        innerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(innerView)
        var radius:CGFloat
        var lineWidth:CGFloat
        
        switch style {
        case .small:
            radius = 18
            lineWidth = 3
            fontSize = 10
        case .medium:
            radius = 24
            lineWidth = 4
            fontSize = 14
        case .large:
            radius = 30
            lineWidth = 5
            fontSize = 17
        }
        
        innerView.widthAnchor.constraint(equalToConstant: 2 * (radius + lineWidth)).isActive = true
        innerView.heightAnchor.constraint(equalToConstant: 2 * (radius + lineWidth)).isActive = true
        innerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        innerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        //innerView.backgroundColor = UIColor(displayP3Red: 26/255, green: 50/255, blue: 112/255, alpha: 1)
        
        expiredCircle.fillColor = UIColor.clear.cgColor
        expiredCircle.strokeColor = expiredCircleColor?.cgColor
        expiredCircle.lineWidth = lineWidth / 3
        innerView.layer.addSublayer(expiredCircle)
        let circleCenter = CGPoint(x: radius + lineWidth, y: radius + lineWidth)
        let path = UIBezierPath(arcCenter: circleCenter, radius: radius, startAngle: -CGFloat.pi / 2 - 0.000001, endAngle: -CGFloat.pi / 2, clockwise: false)
        expiredCircle.path = path.cgPath
        
        activeCircle.fillColor = UIColor.clear.cgColor
        activeCircle.strokeColor = activeCircleColor?.cgColor
        activeCircle.lineWidth = lineWidth
        innerView.layer.addSublayer(activeCircle)
        activeCircle.path = path.cgPath
        activeCircle.lineCap = .round
        activeCircle.lineJoin = .miter
        activeCircle.strokeEnd = 1
        
        label.textAlignment = .center
        label.textColor = textColor
        
        
        
        innerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: innerView.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: innerView.rightAnchor).isActive = true
        label.topAnchor.constraint(equalTo: innerView.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: innerView.bottomAnchor).isActive = true
        
        
        
        
        
        
        
        
        
    }
    
    
    
    private var expirationTime:Date!
    
    /**
        Starts the animation.
     
        - Parameters:
            -animationTime: Number of seconds remaining until expiration.
     */
    
    func startAnimation(expirationTime:Date) {
        if started{
            return
        }
        started = true
        self.expirationTime = expirationTime
        currentTime = Int(expirationTime.timeIntervalSinceNow)
        animation.duration = expirationTime.timeIntervalSinceNow
        animation.fromValue = 1
        animation.toValue = 0
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        activeCircle.strokeEnd = 0
        activeCircle.add(animation, forKey: "k")
        label.text = currentTime > 60 ? "\(currentTime / 60)m" : "\(currentTime)s"
        timer = CADisplayLink.init(target: self, selector: #selector(timerFunc))
        timer?.add(to: RunLoop.current, forMode: .common)
        
    }
    
    @objc
    private func timerFunc() {
        self.currentTime = Int(ceil(expirationTime.timeIntervalSinceNow))
        if currentTime < 0{
            timer?.invalidate()
            self.label.text = "0s"
            expirationBlock?()
            return
        }
        label.text = currentTime > 60 ? "\(currentTime / 60)m" : "\(currentTime)s"
    }
    
    /**
     Stops the animation, corrects the animation position, and resets the timout of the animation based on remainingTime and fractionComplete arguments.
     
     - Parameters:
     - fractionComplete: The fraction of the animation that is completed.
     - remainingTime: The time that is remaining until the end of animation.
     */
    
    func continueAnimation(withFractionComplete completed:CGFloat, expirationTime:Date) {
        if !started{
            return
        }
        self.expirationTime = expirationTime
        timer?.invalidate()
        animation.fromValue = completed
        animation.duration = expirationTime.timeIntervalSinceNow
        activeCircle.removeAllAnimations()
        activeCircle.add(animation, forKey: "expiring")
        
        currentTime = Int(ceil(expirationTime.timeIntervalSinceNow))
        label.text = currentTime > 60 ? "\(currentTime / 60)m" : "\(currentTime)s"
        timer = CADisplayLink.init(target: self, selector: #selector(timerFunc))
        timer?.add(to: RunLoop.current, forMode: .common)
    }
    
    
    
    
    
    
    /**
     Calls this block when time is expired.
     
     - Parameters:
     -callBack: The block to call when time is out.
     
     */
    func doWhenExpired(_ callBack:@escaping ()->Void) {
        self.expirationBlock = callBack
        
    }
    
    
    
    
    
    
    /**
     Sets button state to expired.
     */
    func setToExpired() {
        timer?.invalidate()
        label.text = "0"
        activeCircle.strokeEnd = 0
        isEnabled = false
        expirationBlock?()
        
    }
    
    
    
    func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
    
    
}
