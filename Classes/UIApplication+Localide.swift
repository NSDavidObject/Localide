//
//  UIApplication+Localide.swift
//  Localide
//
//  Created by David Elsonbaty on 5/29/16.
//  Copyright © 2016 David Elsonbaty. All rights reserved.
//

import UIKit

// Special thanks to @dianz (http://stackoverflow.com/a/30858591)
internal extension UIApplication {
    internal class func topViewController(fromRoot root: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        if let navigationController = root as? UINavigationController {
            return topViewController(fromRoot: navigationController.visibleViewController)
        }

        if let tabBarController = root as? UITabBarController,
            let selectedViewController = tabBarController.selectedViewController {
            return topViewController(fromRoot: selectedViewController)
        }

        if let presentedViewController = root?.presentedViewController {
            return topViewController(fromRoot: presentedViewController)
        }

        return root
    }
}
