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
    
    typealias Handler = (_ processor: Double) -> Void
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
    
    @objc private func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        var percent = pan.translation(in: self).y / self.frame.height * 2
        if percent < 0 {
            percent = max(percent, -1)
        } else {
            percent = min(percent, 1)
        }
        
        switch pan.state {
        case .changed:
            gradientLayer.opacity = 1
        default:
            gradientLayer.opacity = 0
        }

        _processor(percent)
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        if state == .began {
            let vel = velocity(in: view)
            if abs(vel.x) > abs(vel.y) {
                state = .cancelled
            }
        }
    }
    
}
