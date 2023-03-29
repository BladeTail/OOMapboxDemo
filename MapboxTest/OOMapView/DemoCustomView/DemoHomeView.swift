//
//  DemoHomeView.swift
//  Demo
//
//  Created by huxiaoyang on 2023/3/4.
//

import UIKit

public class DemoHomeView: DemoTouchView {
    
    typealias Action = (_ action: String) -> Void
    private var call: Action!
    
    private var leftNavi: UIButton!
    private var rightNavi: UIButton!
    private var leftBottom: UIButton!
    private var rightBottom: UIButton!
    private var share: UIButton!
    private var ispace: UIButton!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 回调
    func callback(handler: @escaping Action) {
        call = handler
    }
    
}

// MARK: - 布局
extension DemoHomeView {
    
    fileprivate func setupViews() {
        
        let layerView = UIView()
        layerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 262.5)
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = [UIColor(red: 0.02, green: 0, blue: 0.21, alpha: 1).cgColor, UIColor(red: 0.09, green: 0.07, blue: 0.3, alpha: 0).cgColor]
        bgLayer1.locations = [0, 1]
        bgLayer1.frame = layerView.bounds
        bgLayer1.startPoint = CGPoint(x: 0.5, y: 0)
        bgLayer1.endPoint = CGPoint(x: 0.76, y: 0.76)
        layerView.layer.addSublayer(bgLayer1)
        self.addSubview(layerView)
        
        leftNavi = setupBtn("tab_icon_discover_default")
        rightNavi = setupBtn("tab_icon_messages_default")
        leftBottom = setupBtn("nav_icon_friends_default")
        rightBottom = setupBtn("nav_img_my_default")
        share = setupBtn("nav_icon_share_default")
        ispace = setupBtn("nav_icon_ispace_default")
        
        let bgView = UIView()
        bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 42;
        
        leftNavi.frame = CGRect(x: 30, y: 55, width: 36, height: 36)
        rightNavi.frame = CGRect(x: self.bounds.width - 30 - 36, y: 55, width: 36, height: 36)
        leftBottom.frame = CGRect(x: 30, y: self.bounds.height - 72 - 36, width: 36, height: 36)
        rightBottom.frame = CGRect(x: self.bounds.width - 30 - 48, y: self.bounds.height - 66 - 48, width: 48, height: 48)
        bgView.frame = CGRect(x: (self.bounds.width - 166) / 2.0, y: self.bounds.height - 48 - 84, width: 166, height: 84)
        share.frame = CGRect(x: (bgView.bounds.width - 128 - 8) / 2.0, y: (bgView.bounds.height - 64) / 2.0, width: 64, height: 64)
        ispace.frame = CGRect(x: share.frame.maxX + 8, y: (bgView.bounds.height - 64) / 2.0, width: 64, height: 64)
        
        bgView.addSubview(share)
        bgView.addSubview(ispace)
        self.addSubview(leftNavi)
        self.addSubview(rightNavi)
        self.addSubview(leftBottom)
        self.addSubview(rightBottom)
        self.addSubview(bgView)
        
        share.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        ispace.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        leftNavi.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        rightNavi.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        leftBottom.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        rightBottom.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
    }
    
    fileprivate func setupBtn(_ imageName: String) -> UIButton {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage(named: imageName), for: .normal)
        return btn
    }
    
    @objc fileprivate func click(_ btn: UIButton) {
        if btn == ispace {
            call("ispace")
        } else if btn == share {
            call("share")
        } else {
            call("card")
        }
    }
    
}
