//
//  BaseTabbarController.swift
//  TabbarControllerTransition
//
//  Created by Evan on 2017/4/18.
//  Copyright © 2017年 Evan. All rights reserved.
//

import UIKit

class BaseTabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        addPanGestureRecongnizer()
    }
    
    ///A gesture on whole tabbar view
    fileprivate func addPanGestureRecongnizer() {
        let panGes = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        view.addGestureRecognizer(panGes)
    }
    
    fileprivate var interactionController: UIPercentDrivenInteractiveTransition?
    
    fileprivate var isDuringChangedStage = false
    fileprivate var isForward = false
    
    func didPan(_ pan: UIPanGestureRecognizer) {
        guard let targetView = pan.view, let childVcs = viewControllers else { return }
        let translationX = pan.translation(in: targetView).x
       
        let _isForward = translationX <= 0
        if (_isForward && selectedIndex == childVcs.count - 1 && !isDuringChangedStage) || (!_isForward && selectedIndex == 0 && !isDuringChangedStage)  {
            return
        }
        switch pan.state {
        case .began:
            isDuringChangedStage = true
            interactionController = UIPercentDrivenInteractiveTransition()
            //changing selectedIndex triggers tabBarViewController's transition
            selectedIndex -= (translationX > 0 ? 1 : -1)
            isForward = _isForward
        case .changed:
            let multiplier: CGFloat = isForward ? -1 : 1
            let percentComplete = min(max(multiplier * translationX / view.bounds.width, 0), 1)
            interactionController?.update(percentComplete)
        case .ended, .cancelled:
            let multiplier: CGFloat = isForward ? -1 : 1
            let percentComplete = min(max(multiplier * translationX / view.bounds.width, 0), 1)
            //threshold = 0.3
            if percentComplete >= 0.3 {
                interactionController?.finish()
            }
            else {
                interactionController?.cancel()
            }
            //cleanUp
            interactionController = nil
            isDuringChangedStage = false
            isForward = false
        default:
            break
        }
    }
}

extension BaseTabbarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TabBarAnimatorController()
    }
}
