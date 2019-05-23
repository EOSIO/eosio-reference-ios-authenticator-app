//
//  ActivityIndicatorViewWithTimout.swift
//  AcitivityIndicatorWithTimeout
//
//  Created by Farid Rahmani on 1/24/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import UIKit

class CirclesActivityIndicatorView:UIView{
    
    private let innerView = UIView()
    
    private let bigCircle = CAShapeLayer() //Bigger outer circle
    private let smallCircle = CAShapeLayer() //Smaller inner circle
    
    /**
        Hides when stopAnimating() method is called.
    */
    public var hidesWhenStopped:Bool = false
    public var outerCircleColor:UIColor = .lightGray{
        didSet{
            bigCircle.strokeColor = outerCircleColor.cgColor
        }
        
    }
    
    
    //Empty override to prevent the setting the backgroundColor property
    override var backgroundColor: UIColor?{
        set{
            //do nothing
        }
        
        get{
            return self.backgroundColor
        }
    }
    
    
    /**
        The color of the the inner smaller circle.
    */
    public var innerCircleColor:UIColor = .lightGray{
        didSet{
            smallCircle.strokeColor = innerCircleColor.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    
    private func setup(){
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 100).isActive = true
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        innerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(innerView)
        innerView.widthAnchor.constraint(equalToConstant: 98).isActive = true
        innerView.heightAnchor.constraint(equalToConstant: 98).isActive = true
        innerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        innerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        //Setup the bigger circle
        bigCircle.position = innerView.center
        let p1 = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: 47, startAngle: -CGFloat.pi / 2, endAngle: 0, clockwise: false)
        bigCircle.fillColor = UIColor.clear.cgColor
        bigCircle.strokeColor = outerCircleColor.cgColor
        bigCircle.lineWidth = 3
        bigCircle.path = p1.cgPath
        innerView.layer.addSublayer(bigCircle)
        
        
        
        //Setup the smaller circel
        smallCircle.position = innerView.center
        innerView.layer.addSublayer(smallCircle)
        smallCircle.fillColor = UIColor.clear.cgColor
        smallCircle.strokeColor = innerCircleColor.cgColor
        smallCircle.lineWidth = 3
        let p2 = UIBezierPath(arcCenter: .zero, radius: 31, startAngle: CGFloat.pi / 2, endAngle: 0, clockwise: true)
        smallCircle.path = p2.cgPath
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        frame = CGRect(origin: frame.origin, size: CGSize(width: 100, height: 100))
        bigCircle.position = innerView.center
        smallCircle.position = innerView.center
    }
    
    
    /**
        Starts the spinning animation.
    */
    public func startAnimating(){
        innerView.isHidden = false
        let animation = CABasicAnimation()
        animation.duration = 2
        animation.repeatCount = Float.infinity
        animation.keyPath = "transform.rotation.z"
        animation.fromValue = 0
        animation.toValue = 2 * 3.14
        bigCircle.add(animation, forKey: "k")
        animation.toValue = -2 * 3.14
        smallCircle.add(animation, forKey: "rotation")
    }
    
    /**
        Stops the spinning animation. If hidesWhenStopped property is set to true, this also hides the ActivityIndicator.
    */
    public func stopAnimating(){
        bigCircle.removeAllAnimations()
        smallCircle.removeAllAnimations()
        
        if hidesWhenStopped{
            innerView.isHidden = true
        }
    }
    
    override var intrinsicContentSize: CGSize{
        return frame.size
    }
}
