//
//  AlertService.swift
//  Clima
//
//  Created by nguyen manh hung on 5/15/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit

class AlertService: NSObject {
    
    class func alertRequestOpenSetting(title: String?, message: String?, actionCancel: (() -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if actionCancel != nil {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                actionCancel!()
            }))
        }
        else {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }
        alert.addAction(UIAlertAction(title: "Open Setting",
                                      style: .default,
                                      handler: { _ in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        }))
        return alert
    }
    
}
