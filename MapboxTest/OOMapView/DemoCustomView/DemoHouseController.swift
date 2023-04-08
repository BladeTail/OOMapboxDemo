//
//  DemoHouseController.swift
//  Demo
//
//  Created by huxiaoyang on 2023/3/5.
//

import UIKit

final class DemoHouseController: UIViewController {
    
    let images = ["c1", "c2", "c3", "c4", "c5", "c6"]
    
    public var collectionView: UICollectionView!
    fileprivate var layerView: UIView!
    fileprivate var backBtn: UIButton!
    fileprivate var addBtn: UIButton!
    fileprivate var titleLabel: UILabel!
    
    public var collectionViewIndex: Int = 0 {
      didSet {
        if collectionViewIndex == oldValue {
          return
        }
        // The selection index of collectionView.
      }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = self
        view = DemoTouchView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.clear
        setupNaviBar()
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let delegatingView = view as? DemoTouchView {
            delegatingView.touchDelegate = presentingViewController?.view
        }
    }
    
    func setViews(visiable: Bool) {
        layerView.alpha = visiable ? 1 : 0
        backBtn.alpha = visiable ? 1 : 0
        addBtn.alpha = visiable ? 1 : 0
        titleLabel.alpha = visiable ? 1 : 0
    }
    
}

extension DemoHouseController {
    
    fileprivate func setupNaviBar() {
        layerView = UIView()
        layerView.isUserInteractionEnabled = false
        layerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 262.5)
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = [UIColor(red: 0.02, green: 0, blue: 0.21, alpha: 1).cgColor, UIColor(red: 0.09, green: 0.07, blue: 0.3, alpha: 0).cgColor]
        bgLayer1.locations = [0, 1]
        bgLayer1.frame = layerView.bounds
        bgLayer1.startPoint = CGPoint(x: 0.5, y: 0)
        bgLayer1.endPoint = CGPoint(x: 0.76, y: 0.76)
        layerView.layer.addSublayer(bgLayer1)
        view.addSubview(layerView)
        
        backBtn = UIButton.init(type: .custom)
        addBtn = UIButton.init(type: .custom)
        titleLabel = UILabel()
        
        backBtn.frame = CGRect(x: 21, y: 55, width: 24, height: 24)
        addBtn.frame = CGRect(x: UIScreen.main.bounds.width - 15 - 24, y: 55, width: 24, height: 24)
        titleLabel.frame = CGRect(x: (UIScreen.main.bounds.width - 203) / 2.0, y: 55, width: 203, height: 24)

        backBtn.setImage(UIImage(named: "tab_icon_back"), for: .normal)
        addBtn.setImage(UIImage(named: "tab_icon_add"), for: .normal)
        titleLabel.text = "The French laudrey"
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 21)
        
        view.addSubview(backBtn)
        view.addSubview(addBtn)
        view.addSubview(titleLabel)
        
        backBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    @objc fileprivate func close() {
        self.dismiss(animated: true)
    }
    
}

extension DemoHouseController {
    fileprivate func setupCollectionView() {
        let frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 300 - 85, width: UIScreen.main.bounds.width, height: 300)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: CentralCardLayout(scaled: true))
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.decelerationRate = .fast
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(CardCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: CardCollectionViewCell.self))
        self.view.addSubview(collectionView)
    }
    
}


extension DemoHouseController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CardCollectionViewCell.self), for: indexPath)
        if let vCell = cell as? CardCollectionViewCell {
          vCell.backGroundImageView.image = UIImage(named: images[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView,
              let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        let initialOffset = (collectionView.bounds.size.width - layout.itemSize.width) / 2
        let currentItemCentralX =
            collectionView.contentOffset.x + initialOffset + layout.itemSize.width / 2
        let pageWidth = layout.itemSize.width + layout.minimumLineSpacing
          collectionViewIndex = Int(currentItemCentralX / pageWidth)
    }
    
}

// MARK: - 转场配置
extension DemoHouseController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DemoHouseTransitioning()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DemoHouseHiddenTransitioning()
    }
    
}


// MARK: - 重写页面设置
extension DemoHouseController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var modalPresentationStyle: UIModalPresentationStyle {
        get {
            return .overFullScreen
        }
        set {}
    }
    
}
