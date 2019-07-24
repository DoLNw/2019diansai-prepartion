//
//  Transition.swift
//  CameraCapture7
//
//  Created by JiaCheng on 2018/10/28.
//  Copyright © 2018 JiaCheng. All rights reserved.
//

import UIKit

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
//scanTableViewController的长度只要给下面的改值就好
let SEGUED_HEIGHT = UIScreen.main.bounds.size.height/2+100


class Transition: NSObject, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var navigationController: UINavigationController!
    var interactionController: UIPercentDrivenInteractiveTransition?
    var isPanGestureInteration = false
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push && toVC is ScanTableViewController {
            return TransitionAnimator()
        } else if operation == .pop && fromVC is ScanTableViewController {
            return TransitionAnimatorBack()
        } else {
            return nil
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactionController
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panned(gestureRecognizer:)))
        self.navigationController.view.addGestureRecognizer(panGesture)

        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapGesture.delegate = self
        self.navigationController.view.addGestureRecognizer(tapGesture)
    }
    
    //解决tableView点击事件跟手势冲突解决.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if NSStringFromClass((touch.view?.classForCoder)!) == "UITableViewCellContentView" || touch.view is UITableView || touch.view is UILabel {
            //            print("true")
            return false
        } else {
            //            print("false")
            return true
        }
    }

    @objc func tapped(_ gestureRecognizer: UITapGestureRecognizer) {
        if (self.navigationController?.viewControllers.count)! > 1 {

            self.navigationController?.popViewController(animated: true)
        }
    }
    
    var recordPopOrPush = true
    @objc func panned(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            self.interactionController = UIPercentDrivenInteractiveTransition()
            
            if (self.navigationController?.viewControllers.count)! > 1 {
                recordPopOrPush = false
                isPanGestureInteration = true
                self.navigationController?.popViewController(animated: true)
            } else {
                if BlueToothCentral.peripheral == nil && BlueToothCentral.isBlueOn {

                    isPanGestureInteration = true
                    recordPopOrPush = true
                    let scanTableController = self.navigationController.storyboard?.instantiateViewController(withIdentifier: "ScanTableController") as! ScanTableViewController
                    self.navigationController?.pushViewController(scanTableController, animated: true)
                }
            }
            
        case .changed:
            guard self.isPanGestureInteration else { return }
            
            let translation = gestureRecognizer.translation(in: self.navigationController!.view)
            let completionProgress = (recordPopOrPush ? -translation.y : translation.y) / (SCREEN_HEIGHT-50)

            self.interactionController?.update(completionProgress)
            if completionProgress == 1.0 {
                self.interactionController?.finish()
            }

        case .ended:
            isPanGestureInteration = false
            
            if (self.interactionController?.percentComplete)! > CGFloat(0.08) {
                self.interactionController?.finish()
            } else {
                self.interactionController?.cancel()
            }
            
            self.interactionController = nil
            
        default:
            print(4)
            self.interactionController?.cancel()
            self.interactionController = nil
        }
    }}
