//
//  OOImageViewAnnotation.swift
//
//  Created by Ruiqing Wan on 2023/3/4.
//

import UIKit
import MapboxMaps

protocol OOAnnotationViewDelegate : AnyObject {
    func didTappedAnnotationView(annotationView:OOImageViewAnnotation)
}

enum OOAnnotationType:NSInteger {
    case unknownAnnoType = 0
    case currentUserAnnoType = 1
    case houseAnnoType = 2
    case momentsAnnoType = 3
    case inveiteAnnoType = 4
}

class OOImageViewAnnotation : UIImageView {
    public weak var delegate:OOAnnotationViewDelegate!
    public var options:ViewAnnotationOptions
    private var coordinate:CLLocationCoordinate2D
    public var type:OOAnnotationType = .unknownAnnoType
    public var seleced:Bool = false
    public var visibleSize:CGSize = CGSizeZero
    
    init(coordinate:CLLocationCoordinate2D, size: CGSize, anchor:ViewAnnotationAnchor, image:UIImage, tpye:OOAnnotationType) {
        let options = ViewAnnotationOptions(
            geometry: Point(coordinate),
            width: size.width,
            height: size.height,
            allowOverlap: true,
            anchor: anchor
        )
        self.options = options
        self.coordinate = coordinate
        self.type = tpye
        super.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        super.image = image
        contentMode = .scaleAspectFit
        isUserInteractionEnabled = true
        visibleSize = size
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(didTapped))
        self.addGestureRecognizer(tap)
        self.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
    }
    
    required init?(coder: NSCoder) {
        self.options = ViewAnnotationOptions()
        self.coordinate = CLLocationCoordinate2D()
        super.init(coder: coder)
        image = UIImage()
    }
    
    public func coordPosition() -> CLLocationCoordinate2D {
        return self.coordinate
    }
    
    public func setVisible(visible:Bool) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.alpha = visible ? 1.0 : 0.0
        }
    }
    
    public func isNormalAnnotation() -> Bool {
        return self.type == .momentsAnnoType || self.type == .inveiteAnnoType;
    }
    
    @objc func didTapped(sender:UITapGestureRecognizer) {
        if self.delegate != nil {
            self.delegate.didTappedAnnotationView(annotationView: self)
        }
    }
}

class HouseAnnotation : OOImageViewAnnotation {
    private var headers:NSMutableArray = NSMutableArray()
    public var cover:UIImageView = UIImageView()
    private var hCenter:CGPoint = CGPointZero
    private var headerShowCenter:NSMutableArray = NSMutableArray()
    private var headerJumpTimer:Timer = Timer()
    
    init(coordinate:CLLocationCoordinate2D) {
        let image:UIImage = UIImage(named: "house")!
        super.init(coordinate: coordinate, size: image.size, anchor: ViewAnnotationAnchor.bottom, image: UIImage(), tpye: .houseAnnoType)
        cover.image = image
        self.setupHeaders()
        cover.layer.anchorPoint = self.layer.anchorPoint
        let imgSize = self.coverImage().size
        let coverOrigin = CGPoint(x: 0, y: 0)
        self.cover.frame = CGRect(origin: coverOrigin, size: imgSize)
    }
    
    override var visibleSize: CGSize {
        set {
            self.cover.frame = self.bounds
            super.visibleSize = newValue
        }
        get {
            return super.visibleSize
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupHeaders() {
        let delta = 10.0;
        for index in 0...4 {
            let imgName:String = "img" + String(index + 1)
            let img:UIImage = UIImage(named: imgName)!
            let imageView:UIImageView = UIImageView(frame: CGRect(origin: CGPointZero, size: img.size))
            hCenter = CGPoint(x: self.bounds.size.width / 2, y:  self.bounds.size.height / 2)
            imageView.center = center
            headers.add(imageView)
            imageView.alpha = 0
            imageView.image = img
            let indexDelta = abs(2 - index);
            let xDelta = indexDelta == 1 ? CGFloat(index - 2) * 6.5 : 0.0
            let headerX = hCenter.x + CGFloat(index -  2) * (delta + img.size.width) + xDelta;
            let ratio:CGFloat = indexDelta == 1 ? (2.0 / 3.0) : CGFloat(indexDelta)
            let headerY = (ratio - 2.3) * img.size.height;
            let centerH = CGPoint(x: headerX, y: headerY);
            headerShowCenter.add(centerH)
            self.addSubview(imageView)
        }
        self.addSubview(self.cover)
    }
    
    public func coverImage() -> UIImage {
        return cover.image!
    }
    
    public func setAllHeadersVisible(visible:Bool) {
        if !visible {self.headerJumpTimer.invalidate()}
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            for imageView in self.headers {
                let v:UIImageView = imageView as! UIImageView
                v.alpha = visible ? 1.0 : 0.0;
                let index = self.headers.index(of: v)
                let scale:CGFloat = (visible ? 1.2 : 1.0)
                let width = v.image!.size.width * scale
                let height = v.image!.size.height * scale
                v.frame.size = CGSize(width:width , height: height)
                v.center = visible ? self.headerShowCenter.object(at: index) as! CGPoint: self.hCenter
                let imgSize = self.coverImage().size
                let coverSize = CGSize(width: imgSize.width * scale, height: imgSize.height * scale)
                let coverOrigin = CGPoint(x: (imgSize.width - coverSize.width) / 2.0, y: imgSize.height - coverSize.height)
                self.cover.frame = CGRect(origin: coverOrigin, size: coverSize)
            }
        } completion: { (finished) in
            if visible && finished {
                self.animateAllHeaders()
            }
        }
    }
    
    private func animateAllHeaders() {
        headerJumpTimer = Timer.scheduledTimer(withTimeInterval: 2.25, repeats: true) { (timer) in
            self.jumpHeaders()
        }
        RunLoop.current.add(headerJumpTimer, forMode: .default)
        // 开始计时
        headerJumpTimer.fire()
    }
    
    private func jumpHeaders() {
        for index in  0...4 {
            let v:UIView = self.headers.object(at: index) as! UIView
            let op:AnimationOptions = [.curveEaseInOut, .autoreverse]
            let vCenter:CGPoint = self.headerShowCenter.object(at: index) as! CGPoint
            let duration = 0.2
            UIView.animate(withDuration: 0.2, delay: duration * CGFloat(2 * index), options: op) {
                let jumpCenter = CGPoint(x:vCenter.x , y: vCenter.y - 5)
                v.center = jumpCenter
            } completion: { (finished) in
                v.center = vCenter
            }
        }
    }
}
