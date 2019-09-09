//
//  NoiseManager.swift
//  Noise
//
//  Created by Nick on 19/4/16.
//  Copyright © 2016 spromicky. All rights reserved.
//

import Foundation

open class NoiseManager {
    public static let manager = NoiseManager()
    
    let operationQueue = OperationQueue.main
    
    open var isEmpty: Bool {
        return operationQueue.operations.filter { $0 is NoiseOperation }.isEmpty
    }
    
    func addPresentationOperation(_ operation: NoiseOperation) {
        operationQueue.addOperation(operation)
        
        let ops = operationQueue.operations.filter { $0 is NoiseOperation } as! [NoiseOperation]
        let deadOps = ops.filter { $0.notificationController.showingInFixedViewController && $0.notificationController.fixedViewController == nil }
        
        for op in deadOps {
            op.cancel()
        }
        
        let executingOps = ops.filter { $0.isExecuting }
        guard !executingOps.isEmpty else { return }
        
        let currentOperation = ops[0]
        let currentController = currentOperation.notificationController.topViewController
        guard currentController != NoiseController.findTopViewController() &&
              currentController != NoiseController.findTopViewControllerInNavigationController() else { return }
        
        currentOperation.notificationController.closeNotification(animated: false)
    }
    
    open func cancelAll() {
        let ops = operationQueue.operations.filter { $0 is NoiseOperation
        }
        for op in ops {
            op.cancel()
        }
    }
}
