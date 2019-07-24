//
//  TransitionAnimator.swift
//  CameraCapture7
//
//  Created by JiaCheng on 2018/10/28.
//  Copyright © 2018 JiaCheng. All rights reserved.
//

import UIKit

class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    weak var transitionContext: UIViewControllerContextTransitioning?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        let containerView = transitionContext.containerView
        let fromVC = transitionContext.viewController(forKey: .from) as! ViewController
        let toVC = transitionContext.viewController(forKey: .to) as! ScanTableViewController

        let tempView = fromVC.view.snapshotView(afterScreenUpdates: false)!//如果此处为true，那么在动画没有完成前，两个controller都是活动的，此时下面一句hidden后我的tempView就变黑了，在fromvc活动时是会实时更新的
        tempView.clipsToBounds = true
        fromVC.view.isHidden = true

        containerView.addSubview(tempView)
        containerView.addSubview(toVC.view)

        //本来四周都是圆角，所以给它长度高一点不显示底部圆角
        toVC.view.frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: SEGUED_HEIGHT+100)
        UIView.animate(withDuration: 0.25, animations: {
            //圆角h也是可以动画的。
            tempView.alpha = 0.5
            toVC.view.transform = CGAffineTransform(translationX: 0, y: -SEGUED_HEIGHT)
            tempView.transform = CGAffineTransform(translationX: 0, y: 0)
        }) { (_) in
            if !(self.transitionContext?.transitionWasCancelled)! {
                self.transitionContext?.completeTransition(true)
            } else {
                self.transitionContext?.completeTransition(false)
                fromVC.view.isHidden = false
                tempView.removeFromSuperview()
            }
        }
    }
    func animationEnded(_ transitionCompleted: Bool) {
//        print("Transition ended.")
    }
    
}
