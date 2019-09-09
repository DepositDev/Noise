//
//  NosieController.swift
//  Noise
//
//  Created by Nick on 19/4/16.
//  Copyright © 2016 spromicky. All rights reserved.
//

import Foundation
import UIKit

open class NoiseController {
    private lazy var __onceAnimated: (Void) = { [unowned self] in
            self.animatePresentation(presentation: false, animated: true) { [unowned self] finished in
                self.view.removeFromSuperview()
                self.finishNotification()
            }
        }()
    private lazy var __onceNotAnimated: (Void) = { [unowned self] in
        self.animatePresentation(presentation: false, animated: false) { [unowned self] finished in
            self.view.removeFromSuperview()
            self.finishNotification()
        }
        }()
    static let NoiseDefaultAnimationTime = 0.3
    
    class func findTopViewController() -> UIViewController? {
        guard let delegate = UIApplication.shared.delegate else { return nil }
        guard let aWindow = delegate.window else { return nil }
        guard let bWindow = aWindow else { return nil }
        guard var topViewController = bWindow.rootViewController else { return nil }
        
        while (topViewController.presentedViewController != nil) {
            topViewController = topViewController.presentedViewController!
        }
        
        return topViewController
    }
    
    class func findTopViewControllerInNavigationController() -> UIViewController? {
        guard let topController = NoiseController.findTopViewController() else { return nil }
        guard let navigationController = topController as? UINavigationController else { return topController }
        
        return navigationController.viewControllers.last ?? nil
    }

    
    var showingInFixedViewController = false
    weak var fixedViewController: UIViewController?
    
    lazy var topViewController: UIViewController? = {
        return NoiseController.findTopViewController()
    }()
    
    lazy var topViewControllerInNavigationController: UIViewController? = {
        guard let navigationController = self.topViewController as? UINavigationController else { return self.topViewController }
        return navigationController.viewControllers.last ?? nil
    }()
    
    fileprivate weak var notificationOperation: NoiseOperation?
    fileprivate var showDuration: Double?
    fileprivate var view: UIView!
    
    fileprivate let viewCreationClosure: ((_ maxSize: CGSize, _ topOffset: CGFloat) -> UIView)
    
    /// Closure, that will be executed on tap on `Noise` view.
    ///
    /// Return bool value indicates behavior for `Noise` presentation:
    ///    - `true`: will hide `Noise` immediately;
    ///    - `false`: will left behavior as is;
    var tapClosure: (() -> Bool)? = nil
    
    
    public init(viewCreationClosure closure: @escaping (CGSize, CGFloat) -> UIView) {
        viewCreationClosure = closure
    }
    
    //MARK: - Showing
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if tapClosure?() == true {
            closeNotification()
        }
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .ended, .cancelled:
            guard sender.velocity(in: nil).y < -10 else { return }
            closeNotification()
        default: break
        }
    }
    
    func closeNotification(animated isAnimated: Bool = true) {
        guard let _ = view.superview else { return }
        
        if isAnimated {
            _ = self.__onceAnimated
        } else {
            _ = self.__onceNotAnimated
        }
    }
    
    fileprivate func finishNotification() {
        guard let operation = self.notificationOperation, operation.isCancelled == false else { return }
        operation.completeOperation()
    }
    
    func showNotification() {
        guard !showingInFixedViewController || fixedViewController != nil else { finishNotification(); return }
        guard let controller = fixedViewController ?? topViewController else { finishNotification(); return }
        guard controller == topViewController || controller == topViewControllerInNavigationController else { finishNotification(); return }
        topViewController = controller
        
        var topOffset = topViewController?.view.safeAreaInsets.top ?? 0 
        if let viewController = topViewController?.navigationController, !viewController.isNavigationBarHidden {
            topOffset = 0
        }
        
        view = viewCreationClosure(controller.view.frame.size, topOffset)
        
        view.autoresizingMask = [.flexibleWidth]
        controller.view.addSubview(view)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGesture)
        
        animatePresentation(presentation: true) { [unowned self] finished in
            guard let duration = self.showDuration, duration > 0 else { return }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { [weak self] in
                self?.closeNotification()
            }
        }
    }
    
    func animatePresentation(presentation: Bool, animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        
        if presentation {
            var newFrame = view.frame
            newFrame.origin.y = -newFrame.size.height
            view.frame = newFrame
        }
        
        var y: CGFloat = 0
        
        if let viewController = topViewController?.navigationController, !viewController.isNavigationBarHidden && viewController.navigationBar.isTranslucent {
            y = viewController.navigationBar.frame.maxY
        }
        
        UIView.animate(withDuration: NoiseController.NoiseDefaultAnimationTime, delay: 0, options: [], animations: { [unowned self] in
            var newFrame = self.view.frame
            newFrame.origin.y = presentation ? y : -newFrame.size.height
            self.view.frame = newFrame
            
        }, completion: completion)
    }
    
    open func show(inFixedViewController controller: UIViewController? = nil, duration: Double? = Noise.DefaultNotificationDuration) {

        fixedViewController = controller
        showingInFixedViewController = controller != nil
        showDuration = duration
        
        let operation = NoiseOperation(notificationController: self)
        notificationOperation = operation
        NoiseManager.manager.addPresentationOperation(operation)
    }

    open func close() {
        if let _ = view {
            closeNotification()
        } else {
            finishNotification()
        }
    }
}
