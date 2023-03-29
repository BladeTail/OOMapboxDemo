//
//  DemoCardTransitioning.swift
//  Demo
//
//  Created by huxiaoyang on 2023/3/3.
//

import UIKit

class DemoCardTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.75
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? ViewController else { return }
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? DemoCardController else { return }

        let duration = transitionDuration(using: transitionContext)
        
        transitionContext.containerView.addSubview(toVC.view)
        
//        let renderer = UIGraphicsImageRenderer(bounds: fromVC.mapViewModel.ooMapView.bounds)
//        let snap = renderer.image { rendererContext in
//            fromVC.mapViewModel.ooMapView.layer.render(in: rendererContext.cgContext)
//        }
//        let snapView = UIImageView(image: snap)
//        snapView.frame = fromVC.view.bounds
//        fromVC.view.addSubview(snapView)
        
        toVC.setViews(visiable: false)
        fromVC.mapViewModel.setCurrentUserAnnoVisible(visible: false)
        fromVC.mapViewModel.setHouseVisible(visible: false)
        
        UIView.animate(withDuration: duration, delay: 0) {
            toVC.setViews(visiable: true)
            fromVC.homeView.alpha = 0
        } completion: { finish in
            fromVC.homeView.alpha = 0
            toVC.setViews(visiable: true)
//            toVC.addCollectionViewFadaInAnimation()
            if transitionContext.transitionWasCancelled {
                toVC.view.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        
//        fromVC.homeView.isHidden = true
//
//        let scale = CABasicAnimation(keyPath: "transform.scale")
//        scale.fromValue = 1
//        scale.toValue = 1.65
//
//        let opacity = CABasicAnimation(keyPath: "opacity")
//        opacity.fromValue = 1
//        opacity.toValue = 0
//
//        let group = CAAnimationGroup()
//        group.animations = [scale, opacity]
//        group.duration = duration
//
//        fromVC.view.layer.add(group, forKey: "group")
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
//            if transitionContext.transitionWasCancelled {
//                toVC.view.removeFromSuperview()
//            }
//            fromVC.homeView.isHidden = true
//            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//        }
        
    }
    
}
