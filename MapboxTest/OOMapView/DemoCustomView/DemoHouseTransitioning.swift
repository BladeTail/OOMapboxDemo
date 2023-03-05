//
//  DemoHouseTransitioning.swift
//  Demo
//
//  Created by huxiaoyang on 2023/3/5.
//

import UIKit

final class DemoHouseTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
        
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? ViewController else { return }
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? DemoHouseController else { return }

        let duration = self.transitionDuration(using: transitionContext)
        
        toVC.layerView.alpha = 0
        transitionContext.containerView.addSubview(toVC.view)
        
        fromVC.mapViewModel.setCurrentUserAnnoVisible(visible: false)
        fromVC.mapViewModel.setAllAnnotationsVisible(visible: false)
        toVC.collectionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: 300)
        
        UIView.animate(withDuration: duration, delay: 0) {
            fromVC.homeView.alpha = 0
            toVC.layerView.alpha = 1
            toVC.collectionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 300 - 85, width: UIScreen.main.bounds.width, height: 300)
        } completion: { finish in
            fromVC.homeView.isHidden = true
            if transitionContext.transitionWasCancelled {
                fromVC.view.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
    }
    
}

