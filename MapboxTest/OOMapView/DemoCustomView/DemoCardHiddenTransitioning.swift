//
//  DemoCardHiddenTransitioning.swift
//  Demo
//
//  Created by huxiaoyang on 2023/3/4.
//

import UIKit

class DemoCardHiddenTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? DemoCardController else { return }
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? ViewController else { return }

        let duration = self.transitionDuration(using: transitionContext)
        
        transitionContext.containerView.addSubview(fromVC.view)
        
        toVC.homeView.isHidden = false
        toVC.homeView.alpha = 0
        toVC.mapViewModel.deselectHouseOrAnnotaion()
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) {
            toVC.homeView.alpha = 1
            fromVC.view.alpha = 0
        } completion: { finish in
            toVC.homeView.alpha = 1
            toVC.mapViewModel.setHouseVisible(visible: true)
            toVC.mapViewModel.setCurrentUserAnnoVisible(visible: true)
            if transitionContext.transitionWasCancelled {
                fromVC.view.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
    }
}
