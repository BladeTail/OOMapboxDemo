//
//  CardCollectionViewCell.swift
//  Demo
//
//  Created by huxiaoyang on 2023/3/3.
//

import UIKit

public class CardCollectionViewCell: UICollectionViewCell {
    
    public var backGroundImageView: UIImageView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 4.0
        backGroundImageView = UIImageView()
        backGroundImageView.contentMode = .scaleAspectFill
        backGroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 10.0
        
        self.contentView.addSubview(backGroundImageView)
        buildConstraint()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private
    private func buildConstraint() {
        self.backGroundImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.backGroundImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.backGroundImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.backGroundImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
    }
}
