//
//  UIViewController+Extension.swift
//  Eber
//
//  Created by Denish Gediya on 14/02/25.
//  Copyright © 2025 Elluminati. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
//    func presentFromBottom(_ viewControllerToPresent: UIViewController) {
//        let transition = CATransition()
//        transition.duration = 0.25
//        transition.type = CATransitionType.fade
//        //        transition.subtype = CATransitionSubtype.fromTop
//        self.view.window!.layer.add(transition, forKey: kCATransition)
//        present(viewControllerToPresent, animated: false)
//    }
//    public func removeFromParentAndNCObserver() {
//        for childVC in self.children {
//            childVC.removeFromParentAndNCObserver()
//        }
//        if self.isKind(of: UINavigationController.classForCoder()) {
//            (self as! UINavigationController).viewControllers = []
//        }
//        self.dismiss(animated: false, completion: nil)
//        //self.view.removeFromSuperviewAndNCObserver()
//        NotificationCenter.default.removeObserver(self)
//        self.removeFromParent()
//    }
//    func hideKeyboardWhenTappedAround() {
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
//        tap.cancelsTouchesInView = false
//        view.addGestureRecognizer(tap)
//    }
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }
//    // An extension of UIViewController to check if a segue exist (TODO: Apple rejected?).
//    func canPerformSegue(id: String) -> Bool {
//        let segues = self.value(forKey: "storyboardSegueTemplates") as? [NSObject]
//        guard let filtered = segues?.filter({ $0.value(forKey: "identifier") as? String == id })
//        else {
//            return false
//        }
//        return (filtered.count > 0)
//    }
//
//    // An extension of UIViewController to perform a segue if exist (TODO: Apple rejected?).
//    func performSegue(id: String, sender: AnyObject?) {
//        if canPerformSegue(id: id) {
//            self.performSegue(withIdentifier: id, sender: sender)
//        }
//    }
    // An extension of UIViewController to let childViewControllers easily access their parent PBRevealViewController.
    func revealViewController() -> PBRevealViewController? {
        var viewController: UIViewController? = self
        if viewController != nil && viewController is PBRevealViewController {
            return viewController! as? PBRevealViewController
        }
        while (!(viewController is PBRevealViewController) && viewController?.parent != nil) {
            viewController = viewController?.parent
        }
        if viewController is PBRevealViewController {
            return viewController as? PBRevealViewController
        }
        return nil
    }
}
