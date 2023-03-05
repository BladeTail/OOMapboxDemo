//
//  DemoTouchView.swift
//  Demo
//
//  Created by huxiaoyang on 2023/3/3.
//

import UIKit

public class DemoTouchView: UIView {
    
    weak var touchDelegate: UIView? = nil

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            return super.hitTest(point, with: event)
        }

        guard view === self, let point = touchDelegate?.convert(point, from: self) else {
            return view
        }

        return touchDelegate?.hitTest(point, with: event)
    }
    
}
