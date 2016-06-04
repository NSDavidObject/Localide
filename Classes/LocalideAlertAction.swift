//
//  LocalideAlertAction.swift
//  Localide
//
//  Created by David Elsonbaty on 5/30/16.
//  Copyright © 2016 David Elsonbaty. All rights reserved.
//

import UIKit

class LocalideAlertAction: UIAlertAction {
    var mockMapApp: LocalideMapApp?
    var mockHandler: ((UIAlertAction) -> Void)?
}

extension UIAlertAction {
    class func localideAction(withTitle title: String?, style: UIAlertActionStyle, handler: ((UIAlertAction) -> Void)?) -> LocalideAlertAction {
        let alertAction = LocalideAlertAction(title: title, style: style, handler: handler)
        alertAction.mockHandler = handler
        return alertAction
    }
}