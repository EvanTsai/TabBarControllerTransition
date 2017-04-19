//
//  TabBarAnimatorController.swift
//  TabbarControllerTransition
//
//  Created by Evan on 2017/4/18.
//  Copyright © 2017年 Evan. All rights reserved.
//

import UIKit

struct TabBarAnimatorControllerData {
    static let animationDuration = 0.3
}

class TabBarAnimatorController: NSObject {
    
}


extension TabBarAnimatorController: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TabBarAnimatorControllerData.animationDuration
    }
    
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVc = transitionContext.viewController(forKey: .from), let toVc = transitionContext.viewController(forKey: .to), let tabBarVc = fromVc.tabBarController else { return }
        
        let fromVcIndex = tabBarVc.viewControllers!.index(of: fromVc)!
        let toVcIndex = tabBarVc.viewControllers!.index(of: toVc)!

        let containerView = transitionContext.containerView
        let isForward = fromVcIndex < toVcIndex

        let toVcFinalFrame = transitionContext.finalFrame(for: toVc)
        let fromVcFinalFrame = transitionContext.finalFrame(for: fromVc)
        let fromVcInitialFrame = transitionContext.initialFrame(for: fromVc)
        
        
        containerView.addSubview(toVc.view)
        toVc.view.frame = frameOfToViewController(direction: isForward, finalFrame: toVcFinalFrame, containerBounds: containerView.bounds)
        
        
        let middleFrameOfFromVC = frameOfFromViewController(direction: isForward, initialFrame: fromVcInitialFrame, containerBounds: containerView.bounds)
        
        UIView.animate(withDuration: TabBarAnimatorControllerData.animationDuration, delay: 0.0, options: .curveEaseInOut, animations: { 
            toVc.view.frame = toVcFinalFrame
            fromVc.view.frame = middleFrameOfFromVC
        }) { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
            //If the transition wasn't cancelled, set the fromViewController's view to its final frame instead of our temporary value.
            if !transitionContext.transitionWasCancelled {
                fromVc.view.frame = fromVcFinalFrame
            }
        }
        
    }
    
    ///Put toViewController's view at left or right aside with fromViweController's view according to the direction.
    fileprivate func frameOfToViewController(direction isForward: Bool, finalFrame: CGRect, containerBounds: CGRect) -> CGRect {
        var frame = finalFrame
        let multiplier: CGFloat = isForward ? 1 : -1
        frame.origin = CGPoint(x: multiplier * containerBounds.width, y: 0)
        return frame
    }
    
    ///Temporary frame of fromViewController's frame in accordance with the animation effect.
    fileprivate func frameOfFromViewController(direction isForward: Bool, initialFrame: CGRect, containerBounds: CGRect) -> CGRect {
        var frame = initialFrame
        let multiplier: CGFloat = isForward ? -1 : 1
        frame.origin = CGPoint(x: multiplier * containerBounds.width, y: 0)
        return frame
    }
    
    
    func animationEnded(_ transitionCompleted: Bool) {
        print("Animation Ended")
    }
}
