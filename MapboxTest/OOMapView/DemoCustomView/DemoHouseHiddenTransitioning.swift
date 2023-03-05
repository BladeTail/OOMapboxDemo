//
//  DemohouseHiddenTransitioning.swift
//  Demo
//
//  Created by huxiaoyang on 2023/3/5.
//

import UIKit


final class DemoHouseHiddenTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
 
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? DemoHouseController else { return }
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? ViewController else { return }

        let duration = self.transitionDuration(using: transitionContext)
        
        toVC.homeView.isHidden = false
        toVC.homeView.alpha = 0
        
        transitionContext.containerView.addSubview(fromVC.view)
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) {
            toVC.homeView.alpha = 1
            fromVC.layerView.alpha = 0
            fromVC.collectionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: 300)
        } completion: { finish in
            toVC.mapViewModel.deselectHouseOrAnnotaion()
            toVC.mapViewModel.setCurrentUserAnnoVisible(visible: true)
            toVC.mapViewModel.setAllAnnotationsVisible(visible: true)
            if transitionContext.transitionWasCancelled {
                fromVC.view.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
    }
    
}
