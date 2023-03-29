//
//  DemoCardController.swift
//  Demo
//
//  Created by huxiaoyang on 2023/3/3.
//

import UIKit


final class DemoCardController: UIViewController {
    
    fileprivate var collectionView: UICollectionView!
    
    typealias Complated = (_ index: Int) -> Void
    fileprivate var call: Complated!
    
    let images = ["c1", "c2", "c3", "c4", "c5", "c6"]
    let titles = ["Friends", "For You", "Nearby"]
    let subTitles = ["All", "Moments", "Invites"]
    
    fileprivate var layerView: UIView!
    fileprivate var btn1: UIButton!
    fileprivate var btn2: UIButton!
    fileprivate var btn3: UIButton!
    fileprivate var subBtn1: UIButton!
    fileprivate var subBtn2: UIButton!
    fileprivate var subBtn3: UIButton!
    fileprivate var slider: UIView!
    fileprivate var backBtn: UIButton!
    fileprivate var searchBtn: UIButton!

    public var collectionViewIndex: Int = 0 {
        didSet {
            if collectionViewIndex == oldValue {
                return
            }
            // The selection index of collectionView.
            call(collectionViewIndex)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = self
        view = DemoTouchView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.clear
        setupCollectionView()
        setupNaviBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let delegatingView = view as? DemoTouchView {
            delegatingView.touchDelegate = presentingViewController?.view
        }
    }
    
    // 回调
    func callback(handler: @escaping Complated) {
        call = handler
    }
    
    func setViews(visiable: Bool) {
        collectionView.alpha = visiable ? 1 : 0
        layerView.alpha = visiable ? 1 : 0
        backBtn.alpha = visiable ? 1 : 0
        searchBtn.alpha = visiable ? 1 : 0
        slider.alpha = visiable ? 1 : 0
        btn1.alpha = visiable ? 1 : 0
        btn2.alpha = visiable ? 1 : 0
        btn3.alpha = visiable ? 1 : 0
        subBtn1.alpha = visiable ? 1 : 0
        subBtn2.alpha = visiable ? 1 : 0
        subBtn3.alpha = visiable ? 1 : 0
    }
}

// MARK: - 导航布局

extension DemoCardController {
    
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
        self.view.addSubview(layerView)
        
        btn1 = setupBtn(title: titles[0], fontSize: 21)
        btn2 = setupBtn(title: titles[1], fontSize: 21)
        btn3 = setupBtn(title: titles[2], fontSize: 21)

        let size1 = getTextSize(text: titles[0], fontSize: 21)
        let size2 = getTextSize(text: titles[1], fontSize: 21)
        let size3 = getTextSize(text: titles[2], fontSize: 21)

        let x2 = (UIScreen.main.bounds.width - size2.width) / 2.0
        let x1 = x2 - 17.5 - size1.width
        let x3 = x2 + 17.5 + size2.width

        btn1.frame = CGRect(x: x1, y: 55, width: size1.width, height: size1.height)
        btn2.frame = CGRect(x: x2, y: 55, width: size2.width, height: size2.height)
        btn3.frame = CGRect(x: x3, y: 55, width: size3.width, height: size3.height)

        btn1.isSelected = true

        view.addSubview(btn1)
        view.addSubview(btn2)
        view.addSubview(btn3)
        
        let sx = x1 + (size1.width - 5) / 2.0
        let sy = 55 + size1.height + 4
        slider = UIView(frame: CGRect(x: sx, y: sy, width: 5, height: 2))
        slider.backgroundColor = UIColor(red: 0, green: 0.84, blue: 1, alpha: 1)
        slider.layer.shadowColor = UIColor(red: 0.41, green: 0.35, blue: 1, alpha: 0.3).cgColor
        slider.layer.shadowOpacity = 1
        slider.layer.shadowRadius = 10.5
        layerView.addSubview(slider)
        
        backBtn = UIButton.init(type: .custom)
        backBtn.frame = CGRect(x: 15, y: 55, width: 24, height: 24)
        backBtn.setImage(UIImage(named: "tab_icon_back"), for: .normal)
        view.addSubview(backBtn)
        
        backBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        searchBtn = UIButton.init(type: .custom)
        searchBtn.frame = CGRect(x: UIScreen.main.bounds.width - 15 - 24, y: 55, width: 24, height: 24)
        searchBtn.setImage(UIImage(named: "tab_icon_search"), for: .normal)
        view.addSubview(searchBtn)
        
        subBtn1 = setupBtn(title: subTitles[0], fontSize: 17)
        subBtn2 = setupBtn(title: subTitles[1], fontSize: 17)
        subBtn3 = setupBtn(title: subTitles[2], fontSize: 17)

        let subSize1 = getTextSize(text: subTitles[0], fontSize: 17)
        let subSize2 = getTextSize(text: subTitles[1], fontSize: 17)
        let subSize3 = getTextSize(text: subTitles[2], fontSize: 17)

        let sbx2 = (UIScreen.main.bounds.width - subSize2.width) / 2.0
        let sbx1 = sbx2 - 17 - subSize1.width
        let sbx3 = sbx2 + 17 + subSize2.width
        
        subBtn1.frame = CGRect(x: sbx1, y: 88, width: subSize1.width, height: subSize1.height)
        subBtn2.frame = CGRect(x: sbx2, y: 88, width: subSize2.width, height: subSize2.height)
        subBtn3.frame = CGRect(x: sbx3, y: 88, width: subSize3.width, height: subSize3.height)
        
        subBtn1.isSelected = true
        
        view.addSubview(subBtn1)
        view.addSubview(subBtn2)
        view.addSubview(subBtn3)
        
        subBtn1.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        subBtn2.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        subBtn3.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
    }
    
    fileprivate func setupBtn(title: String, fontSize: CGFloat) -> UIButton {
        let btn = UIButton.init(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .normal)
        btn.setTitleColor(UIColor.white, for: .highlighted)
        btn.setTitleColor(UIColor.white, for: .selected)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
        return btn
    }
    
    fileprivate func getTextSize(text: String, fontSize: CGFloat) -> CGSize {
        let font = UIFont.boldSystemFont(ofSize: fontSize)
        let size = NSString(string: text).boundingRect(with: CGSize(width: Double(MAXFLOAT), height: Double(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size
        return size
    }
    
    @objc fileprivate func close() {
        self.dismiss(animated: true)
    }
    
    @objc fileprivate func click(_ btn: UIButton) {
        subBtn1.isSelected = (btn == subBtn1)
        subBtn2.isSelected = (btn == subBtn2)
        subBtn3.isSelected = (btn == subBtn3)
    }
}

// MARK: - 卡片布局

extension DemoCardController {
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
    
    public func showCollectionItem(at index: NSInteger, animated: Bool) {
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: animated)
        }
    }
    
    public func addCollectionViewFadaInAnimation(completionBlock: ((Bool)->())? = nil) {
        let indexPaths = self.collectionViewFadeInCellIndexes()
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completionBlock?(true)
        }
        for (i, indexPath) in indexPaths.enumerated() {
            if let cell = self.collectionView.cellForItem(at: indexPath) {
                var animationBlock: ()->() = {}
                var newFrame = cell.frame
                newFrame.origin.y = self.collectionView.frame.size.height
                cell.frame = newFrame
                animationBlock = {
                    newFrame.origin.y = 5
                    cell.frame = newFrame
                    cell.alpha = 1.0
                }
                UIView.animate(withDuration: 2,
                               delay: Double(i)*0.17,
                               options: [],
                               animations: animationBlock,
                               completion: nil)
            }
        }
        CATransaction.commit()
    }
    
    func collectionViewFadeInCellIndexes() -> [IndexPath] {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return []
        }
        
        let visibleCellsCount =
          Int(ceil((collectionView.frame.size.width - collectionView.contentInset.left) /
            (layout.itemSize.width + layout.minimumLineSpacing)))
        
        var indexPaths: [IndexPath] = []
        for i in 0..<visibleCellsCount {
            indexPaths.append(IndexPath(row: i, section: 0))
        }
        return indexPaths
    }
}

extension DemoCardController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
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
        call(indexPath.item)
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

extension DemoCardController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DemoCardTransitioning()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DemoCardHiddenTransitioning()
    }
}

// MARK: - 重写页面设置

extension DemoCardController {
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
