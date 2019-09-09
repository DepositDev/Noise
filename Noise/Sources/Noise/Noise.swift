//
//  Noise.swift
//  Noise
//
//  Created by Nick on 22/4/16.
//  Copyright © 2016 spromicky. All rights reserved.
//

import Foundation
import UIKit

@objc
public enum NoiseType: Int {
    case error
    case warning
    case `default`
    case success
}

@objc
open class Noise: NSObject {
    
    public static let DefaultNotificationDuration = 2.0
    
    @objc
    open class func showNotificationWith(message: String) {
        Noise.generalShowWith(message: message)
    }
    
    @objc
    open class func showNotificationWith(title: String, message: String) {
        Noise.generalShowWith(message: message, title: title)
    }
    
    @objc
    open class func showNotificationWith(title: String?, message: String, icon: UIImage?) {
        Noise.generalShowWith(message: message, title: title, icon: icon)
    }
    
    @objc
    open class func showNotificationWith(title: String?, message: String, icon: UIImage?, type: NoiseType) {
        Noise.generalShowWith(message: message, title: title, icon: icon, type: type)
    }
    
    @objc
    open class func showNotificationWith(title: String?, message: String, icon: UIImage?, type: NoiseType, textAlignment: NSTextAlignment) {
        Noise.generalShowWith(message: message, title: title, icon: icon, type: type, textAlignment: textAlignment)
    }
    
    @objc
    open class func showNotificationWith(title: String?, message: String, icon: UIImage?, viewController: UIViewController?) {
        Noise.generalShowWith(message: message, title: title, icon: icon, inViewController: viewController)
    }
    
    @objc
    open class func showNotificationWith(title: String?, message: String, icon: UIImage?, viewController: UIViewController?, duration: Double, callBack: (() -> Bool)?) {
        Noise.generalShowWith(message: message, title: title, duration: duration, icon: icon, inViewController: viewController, action: callBack)
    }
    
    @objc
    open class func showNotificationWith(title: String?, message: String, icon: UIImage?, viewController: UIViewController?, duration: Double, type: NoiseType, callBack: (() -> Bool)?) {
        Noise.generalShowWith(message: message, title: title, duration: duration, icon: icon, inViewController: viewController, type: type, action: callBack)
    }
    
    @discardableResult
    open class func showNotificationWith(title: String?, message: String, icon: UIImage?, viewController: UIViewController?, duration: Double?, blured: Bool, callBack: (() -> Bool)?) -> NoiseController {
        return Noise.generalShowWith(message: message, title: title, duration: duration, icon: icon, blured: blured, inViewController: viewController, action: callBack)
    }
    
    @discardableResult
    open class func showNotificationWith(title: String?, message: String, icon: UIImage?, viewController: UIViewController?, duration: Double?, backgroundColor: UIColor, callBack: (() -> Bool)?) -> NoiseController {
        return Noise.generalShowWith(message: message, title: title, duration: duration, icon: icon, backgroundColor: backgroundColor, inViewController: viewController, action: callBack)
    }
    
    @objc
    open class func showNotificationWith(title: String?, message: String, icon: UIImage?, viewController: UIViewController?, untilUserClose: Bool, callBack: (() -> Bool)?) {
        if untilUserClose {
            Noise.generalShowWith(message: message, title: title, duration: nil, icon: icon, inViewController: viewController, action: callBack)
        } else {
            Noise.generalShowWith(message: message, title: title, icon: icon, inViewController: viewController, action: callBack)
        }
    }
    
    @discardableResult
    class func generalShowWith(message: String,
                               title: String? = nil,
                               duration: Double? = DefaultNotificationDuration,
                               icon: UIImage? = nil,
                               blured: Bool = false,
                               backgroundColor: UIColor? = nil,
                               inViewController viewController: UIViewController? = nil,
                               type: NoiseType = .default,
                               textAlignment: NSTextAlignment = .left,
                               action: (() -> Bool)? = nil) -> NoiseController {
    
        let controller = NoiseController() { (maxSize, topOffset) in
            var view: NoiseDefaultView!
            if blured {
                view = NoiseDefaultBluredView(maxSize: maxSize, topOffset: topOffset, message: message, title: title, icon: icon)
            } else {
                view = NoiseDefaultView(maxSize: maxSize, topOffset: topOffset, message: message, title: title, icon: icon)
            }
            
            if let backgroundColor = backgroundColor {
                view.backgroundColor = backgroundColor
            } else {
                if !blured {
                    switch type {
                    case .error:   view.backgroundColor = UIColor(red:0.98, green:0.27, blue:0.35, alpha:1.00)
                    case .warning: view.backgroundColor = UIColor(red:1.00, green:0.47, blue:0.31, alpha:1.00)
                    case .default: view.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
                    case .success: view.backgroundColor = UIColor(red:0.56, green:0.78, blue:0.25, alpha:1.00)
                    }
                }
            }
            
            view.titleLabel.textAlignment = textAlignment
            view.messageLabel.textAlignment = textAlignment
            return view
        }
        controller.tapClosure = action
        controller.show(inFixedViewController: viewController, duration: duration)
        
        return controller
    }
}

public extension UIViewController {
    
    @objc
    func showNoise(_ message: String) {
        Noise.generalShowWith(message: message, inViewController: self)
    }
    
    @objc
    func showNoise(title: String, message: String) {
        Noise.generalShowWith(message: message, title: title, inViewController: self)
    }
    
    @objc
    func showNoise(title: String?, message: String, icon: UIImage) {
        Noise.generalShowWith(message: message, title: title, icon: icon, inViewController: self)
    }
    
    @objc
    func showNoise(title: String?, message: String, icon: UIImage?, type: NoiseType) {
        Noise.generalShowWith(message: message, title: title, icon: icon, inViewController: self, type: type)
    }
    
    @objc
    func showNoise(title: String?, message: String, icon: UIImage?, duration: Double, callBack: (() -> Bool)?) {
        Noise.generalShowWith(message: message, title: title, duration: duration, icon: icon, inViewController: self, action: callBack)
    }
    
    @objc
    func showNoise(title: String?, message: String, icon: UIImage?, duration: Double, type: NoiseType, callBack: (() -> Bool)?) {
        Noise.generalShowWith(message: message, title: title, duration: duration, icon: icon, inViewController: self, type: type, action: callBack)
    }
    
    @discardableResult
    func showNoise(title: String?, message: String, icon: UIImage?, duration: Double?, backgroundColor: UIColor?, callBack: (() -> Bool)?) -> NoiseController {
        return Noise.generalShowWith(message: message, title: title, duration: duration, icon: icon, backgroundColor: backgroundColor, inViewController: self, action: callBack)
    }
    
    @discardableResult
    func showNoise(title: String?, message: String, icon: UIImage?, duration: Double?, blured: Bool, callBack: (() -> Bool)?) -> NoiseController {
        return Noise.generalShowWith(message: message, title: title, duration: duration, icon: icon, blured: blured, inViewController: self, action: callBack)
    }
    
    @objc
    func showNoise(title: String?, message: String, icon: UIImage?, untilUserClose: Bool, callBack: (() -> Bool)?) {
        if untilUserClose {
            Noise.generalShowWith(message: message, title: title, duration: nil, icon: icon, inViewController: self, action: callBack)
        } else {
            Noise.generalShowWith(message: message, title: title, icon: icon, inViewController: self, action: callBack)
        }
    }
}
