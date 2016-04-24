//
//  DPNotification.swift
//  DPNotificationController
//
//  Created by Nick on 22/4/16.
//  Copyright © 2016 spromicky. All rights reserved.
//

import Foundation
import UIKit

public class DPNotification {
    public class func showNotificationWith(message message: String, icon: UIImage? = nil, action: (() -> ())? = nil) {
        guard let controller = DPNotificationViewController() else { return }
        
        controller.view = DPDefaultNotififcationView(maxSize: controller.maxSize, message: message, icon: icon, buttonAction: action)
        controller.show()
    }
}