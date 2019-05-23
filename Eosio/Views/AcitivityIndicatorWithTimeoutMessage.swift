//
//  ActivityIndicatorViewWithTimout.swift
//  AcitivityIndicatorWithTimeout
//
//  Created by Farid Rahmani on 1/24/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//
import UIKit
class ActivityIndicatorWithTimeoutMessage:UIView{
    public var firstMessageTimeout:TimeInterval = 2
    public var secondMessageTimeout:TimeInterval = 5
    
    public let titleLabel:UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 36)
        label.alpha = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    
    public let subTitleLabel:UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.numberOfLines = 2
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    public let activityIndicator = UIImageView(image: UIImage.animatedImageNamed("Loading Icon Part000", duration: 1.5))
    public var firstTitle:String?
    public var secondTitle:String?
    public var firstSubtitle:String?
    public var secondSubtitle:String?
    public let button = UIButton(type: UIButton.ButtonType.system)
    private var height:NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup(){
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        //activityIndicator.backgroundColor = .white
        activityIndicator.contentMode = .scaleAspectFit
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.widthAnchor.constraint(equalToConstant: 100).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 100).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 40).isActive = true
        //title.heightAnchor.constraint(equalToConstant: 80).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        titleLabel.transform.ty = 30
        
        
        view.addSubview(subTitleLabel)
        subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24).isActive = true
        subTitleLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        subTitleLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        subTitleLabel.textAlignment = .center
        subTitleLabel.transform.ty = 50
        
        
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        view.widthAnchor.constraint(equalToConstant: 320).isActive = true
        height = view.heightAnchor.constraint(equalToConstant: 100)
        height.isActive = true
        view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        
        
        activityIndicator.startAnimating()
        
        addSubview(button)
        button.alpha = 0
        button.transform.ty = -30
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        button.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -24).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(buttonPress(_:)), for: .touchUpInside)
        
        backgroundColor = .white
    }
    
    typealias CancelBlock = ()->Void
    
    private var cancelBlock:CancelBlock?
    
    @objc
    private func buttonPress(_ sender:UIButton){
        cancelBlock?()
        print("cancel")
    }
    
    /**
        Starts the timers. At the first timeout, it will show the firstTitleText and firstSubtitleText in the titleLabel and subTitleLabel. At the second timout, it will show the secondTitleText and secondSubtitleText in the aforementioned labels.
    */
    public func startCountDown(){
        Timer.scheduledTimer(withTimeInterval: firstMessageTimeout, repeats: false) {[weak self] (timer) in
            self?.titleLabel.text = self?.firstTitle
            self?.subTitleLabel.text = self?.firstSubtitle
            
            self?.height.constant = 300
            UIView.animate(withDuration: 0.3, animations: {
                self?.layoutIfNeeded()
                
            }, completion:{completed in
                UIView.animate(withDuration: 0.3, animations: {
                    self?.titleLabel.alpha = 1
                    
                    self?.titleLabel.transform = CGAffineTransform.identity
                    self?.subTitleLabel.alpha = 1
                    self?.subTitleLabel.transform = .identity
                    
                })
            })
            
            
            
            
        }
        
        Timer.scheduledTimer(withTimeInterval: secondMessageTimeout, repeats: false) {[weak self] (timer) in
            UIView.animate(withDuration: 0.3, animations: {
                self?.titleLabel.transform.ty = 30
                self?.subTitleLabel.transform.ty = 50
                self?.titleLabel.alpha = 0
                self?.subTitleLabel.alpha = 0
                
            }, completion:{completed in
                self?.titleLabel.text = self?.secondTitle
                self?.subTitleLabel.text = self?.secondSubtitle
                UIView.animate(withDuration: 0.3, animations: {
                    self?.titleLabel.alpha = 1
                    self?.button.alpha = 1
                    self?.button.transform = .identity
                    self?.titleLabel.transform = CGAffineTransform.identity
                    self?.subTitleLabel.alpha = 1
                    self?.subTitleLabel.transform = .identity
                    
                })
            })
        }
    }
    
    override func didMoveToSuperview() {
        guard let superview = superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.rightAnchor).isActive = true
        topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    /**
        The block that is provided as argument to this function will be called when the user presses the cancel button.
    */
    public func doOnCancel(_ cancelBlock: @escaping CancelBlock) {
        self.cancelBlock = cancelBlock
    }
}
