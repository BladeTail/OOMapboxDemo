//
//  OOMapGestureView.swift
//  MapboxTest
//
//  Created by huxiaoyang on 2023/4/6.
//

import UIKit

enum OOMapGestureViewPosition {
    case left
    case right
}

class OOMapGestureView: UIView {
    
    typealias Handler = (_ processor: Double, _ isStart:Bool) -> Void
    var processor: Handler {
        get {
            return _processor
        }
        set {
            _processor = newValue
        }
    }
    private var _processor: Handler!
    
    private var gradientLayer: CAGradientLayer!
    
    init(frame: CGRect, position: OOMapGestureViewPosition) {
        super.init(frame: frame)
        
        let pan = OOPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        pan.cancelsTouchesInView = false
        addGestureRecognizer(pan)
        
        switch position {
        case .left:
            addLeftColorLayer()
        case .right:
            addRightColorLayer()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var startY:Double = 0.0
    @objc private func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        var percent:Double = 0.0;
        switch pan.state {
        case .began:
            startY = pan.location(in: pan.view).y;
            _processor(0, true)
            break;
        case .changed:
            percent = (pan.location(in: pan.view).y - startY) / self.frame.height;
            gradientLayer.opacity = 1
            _processor(percent, false)
            break;
        case .cancelled, .ended, .failed, .recognized:
            gradientLayer.opacity = 0
            break
        default:
            break;
        }
    }
    
    private func addLeftColorLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.opacity = 0
        gradientLayer.colors = [UIColor.green.cgColor,
                                UIColor.green.withAlphaComponent(0.15).cgColor,
                                UIColor.green.withAlphaComponent(0).cgColor]
        gradientLayer.locations = [0, 0.15, 1]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 0)
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
    }
    
    private func addRightColorLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.opacity = 0
        gradientLayer.colors = [UIColor.yellow.withAlphaComponent(0).cgColor,
                                UIColor.yellow.withAlphaComponent(0.15).cgColor,
                                UIColor.yellow.cgColor]
        gradientLayer.locations = [0, 0.85, 1]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 0)
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
    }
    
}


class OOPanGestureRecognizer: UIPanGestureRecognizer {
    
}
