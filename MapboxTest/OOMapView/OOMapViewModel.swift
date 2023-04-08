//
//  OOMapViewModel.swift
//  MapboxTest
//
//  Created by Ruiqing Wan on 2023/3/4.
//

import MapboxMaps

let accessToken: String = "pk.eyJ1Ijoiam9uZXgiLCJhIjoiY2xlODYxeDV5MDQwYzN5cGJvYWV6Y29jaCJ9.93pAnkG6382zyJSyhHp1bw"

protocol OOMapViewDelegate : AnyObject {
    func didSelectAnnotaion(annotation:OOImageViewAnnotation, index:NSInteger)
    func didDeselectAnnotaion(annotation:OOImageViewAnnotation, index:NSInteger)
    func didSelectHouse()
    func didDeselectHouse()
}

class OOMapViewModel: OOAnnotationViewDelegate {
    internal var ooMapView:OOMapView!
    private let styleURI:String = "mapbox://styles/jonex/clfo9was6000301o7zni3ye8y"
    
    public weak var delegate:OOMapViewDelegate!
    
    internal var uCoord:CLLocationCoordinate2D!
    private var annotationAnimationStartTime:TimeInterval = 0
    private var annotationAnimationDuration = 0.25
    private let normalAnnotations:NSMutableArray = NSMutableArray()
    private let normalBearing:CGFloat = 45
    private let minZoom:CGFloat = 12
    private let normalZoom:CGFloat = 16
    private let houseZoom:CGFloat = 15
    
    private var pucking: Bool = false
    
    /// 界面上普通标注的数量
    public var normalAnnoCount:NSInteger = 4
    private var userAnno:OOImageViewAnnotation!
    private var houseAnno:HouseAnnotation!
    
    public func onViewDidLoad(vc:UIViewController) {
        let screenBounds:CGRect = UIScreen.main.bounds;
        ooMapView = OOMapView(frame: screenBounds, accessToken: accessToken, styleURI: styleURI)
        ooMapView.mapView.location.addLocationConsumer(newConsumer: self)
        
        ooMapView.mapView.mapboxMap.onNext(event: .mapLoaded) { [unowned self] _ in
            ooMapView.mapView.location.requestTemporaryFullAccuracyPermissions(withPurposeKey: accessToken)
        }
                
        ooMapView.mapView.mapboxMap.onNext(event: .styleLoaded) { [unowned self] _ in
            onMapStyleLoaded()
            ooMapView.fixBuildingExtrusions()
        }
        
        ooMapView.mapView.mapboxMap.onEvery(event: .cameraChanged) { [unowned self] _ in
            ooMapView.cameraChanged()
        }
        
        vc.view .addSubview(ooMapView)
    }
    
    public func onViewDidAppear(vc:UIViewController) {}
    
    public func onMapStyleLoaded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { // 暂停
            self.flyCurrentLocation(pucking: false)
            self.updateMapZoomLevel(false) { [unowned self] position in // zoom to 12
                if position == .end {
                    self.updateMapBearingLevel() { [unowned self] position in // bearing to 45
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { // 暂停
                            self.updateMapZoomLevel(true) { [unowned self] position in // zoom to 16
                                if position == .end {
                                    self.addFourRandomViewAnnotations()
                                }
                            }
                        })
                    }
                }
            }
        })
    }
    
    public func selectAnnotationAtIndex(index:NSInteger) {
        let v:OOImageViewAnnotation = normalAnnotations.object(at: index) as! OOImageViewAnnotation
        self.didTappedAnnotationView(annotationView: v)
    }
    
    public func selectHouse() {
        self.didTappedAnnotationView(annotationView: self.houseAnno)
    }
    
    public func deselectHouseOrAnnotaion() {
//        self.didTappedAnnotationView(annotationView: self.userAnno)
    }
    
    public func setHouseVisible(visible:Bool) {
        houseAnno.setVisible(visible: visible)
    }
    
    public func setCurrentUserAnnoVisible(visible:Bool) {
//        userAnno.setVisible(visible: visible)
    }
    
    public func setAnnotationVisible(visible:Bool, index:NSInteger) {
        let v:OOImageViewAnnotation = self.normalAnnotations.object(at: index) as! OOImageViewAnnotation
        v.setVisible(visible: visible)
    }
    
    public func setAllAnnotationsVisible(visible:Bool) {
        for anno in self.normalAnnotations {
            let v = anno as! OOImageViewAnnotation
            v.setVisible(visible: visible)
        }
    }
    
    private func updateMapZoomLevel (_ normal: Bool, _ completion: @escaping AnimationCompletion) {
        let animator = ooMapView.mapView.camera.makeAnimator(duration: 0.5, curve: .easeInOut) { (transition) in
            transition.zoom.toValue = normal ? self.normalZoom : self.minZoom
        }
        animator.addCompletion(completion)
        animator.startAnimation()
    }
    
    private func updateMapBearingLevel (_ completion: @escaping AnimationCompletion) {
        let animator = ooMapView.mapView.camera.makeAnimator(duration: 0.5, curve: .easeInOut) { (transition) in
            transition.bearing.toValue = self.normalBearing
        }
        animator.addCompletion(completion)
        animator.startAnimation()
    }
    
    private func addFourRandomViewAnnotations() {
        let mapView:MapView = self.ooMapView.mapView
        let pointCenter:CGPoint = mapView.center
        let pointStart:CGPoint = mapView.frame.origin
        let xVar:Double = (pointCenter.x - pointStart.x) * 0.7;
        let yVar:Double = (pointCenter.y - pointStart.y) * 0.7;
        let randomCoords = NSMutableArray(object: CLLocationCoordinate2D());
        for index in 1...normalAnnoCount  {
            let posX:Bool = arc4random() % 2 == 0;
            let posY:Bool = arc4random() % 2 == 0;
            let x = (Double)(arc4random() % 101) / 100 * xVar * (posX ? 1 : -1) + pointCenter.x;
            let y = (Double)(arc4random() % 101) / 100 * yVar * (posY ? 1 : -1) + pointCenter.y;
            let p:CGPoint = CGPoint(x: x, y: y)
            let coord = mapView.mapboxMap.coordinate(for: p);
            randomCoords.add(coord);
            let type:OOAnnotationType = index % 2 == 0 ? .momentsAnnoType : .inveiteAnnoType;
            let img:UIImage = type == .momentsAnnoType ? self.momentsImage() : self.invitesImage()
            
            let view:OOImageViewAnnotation = OOImageViewAnnotation(coordinate: coord, size: img.size, anchor: ViewAnnotationAnchor.bottom, image: img, tpye: type)
            view.delegate = self
            try?mapView.viewAnnotations.add(view, options: view.options)
            normalAnnotations.add(view)
        }
        
        let housePoint = CGPoint(x: mapView.bounds.size.width / 4 * 3, y: mapView.bounds.size.height / 8 * 3)
        let houseCoord = mapView.mapboxMap.coordinate(for: housePoint)
        self.houseAnno = HouseAnnotation(coordinate: houseCoord)
        self.houseAnno.delegate = self
//        ooMapView.addViewAnnotation(view: self.houseAnno)
    }
    
    private func momentsImage() -> UIImage {
        return UIImage(named: "moments")!
    }
    
    private func invitesImage() -> UIImage {
        return UIImage(named: "invites")!
    }
    
    private func houseImage() -> UIImage {
        return UIImage(named: "house")!
    }
    
    internal func didTappedAnnotationView(annotationView: OOImageViewAnnotation) {
        if annotationView.seleced {return}
        if annotationView.type == .houseAnnoType {
            houseAnno.setAllHeadersVisible(visible: true)
        } else {
            houseAnno.setAllHeadersVisible(visible: false)
        }
        let viewAnnos = self.ooMapView.mapView.viewAnnotations.annotations.keys
        for aView in viewAnnos {
            if aView is OOImageViewAnnotation {
                let v:OOImageViewAnnotation = aView as! OOImageViewAnnotation
                if v == annotationView {
                    let animator = ooMapView.mapView.camera.makeAnimator(duration: annotationAnimationDuration, curve: .easeIn) {(transition) in
                        transition.center.toValue = v.coordPosition()
                        if self.houseAnno == annotationView {
                            transition.zoom.toValue = self.houseZoom
                        } else {
                            transition.zoom.toValue = self.normalZoom
                        }
                    }
                    animator.startAnimation()
                    v.seleced = true
                    if self.delegate != nil {
                        if v.isNormalAnnotation() {
                            let index:NSInteger = normalAnnotations.index(of: v)
                            self.delegate.didSelectAnnotaion(annotation: v, index: index)
                        }
                        if v.type == .houseAnnoType {
                            self.delegate.didSelectHouse()
                        }
                    }
                } else {
                    if v.seleced && self.delegate != nil {
                        if v.isNormalAnnotation() {
                            let index:NSInteger = normalAnnotations.index(of: v)
                            self.delegate.didDeselectAnnotaion(annotation: v, index: index)
                        }
                        if v.type == .houseAnnoType {
                            self.delegate.didDeselectHouse()
                        }
                    }
                    v.seleced = false
                }
            }
        }
//        self.animateViewAnnotations()
    }
    
    private func animateViewAnnotations() {
        annotationAnimationStartTime = CACurrentMediaTime()
        let link = CADisplayLink(target: self, selector: #selector(animateAnnosNextStep))
        link.add(to: .main, forMode: .default)
    }
    
    @objc private func animateAnnosNextStep(_ displayLink:CADisplayLink) {
        let progress = (CACurrentMediaTime() - annotationAnimationStartTime) / annotationAnimationDuration
        defer {
            if progress >= 1 {
                displayLink.invalidate()
            }
        }
        let viewAnnos = ooMapView.mapView.viewAnnotations.annotations.keys
        for aView in viewAnnos {
            if aView is OOImageViewAnnotation {
                let v:OOImageViewAnnotation = aView as! OOImageViewAnnotation
                let originSize:CGSize = v.type == .houseAnnoType ? self.houseAnno.coverImage().size : v.image!.size
                var targetSize:CGSize = originSize
                if v.seleced {
                    if !v.isNormalAnnotation(){ continue }
                    let tagertProgress = 1 + progress * 0.5;
                    targetSize = CGSize(width: originSize.width * tagertProgress , height: originSize.height * tagertProgress)
                    let options = ViewAnnotationOptions(width:targetSize.width, height: targetSize.height)
                    try! ooMapView.mapView.viewAnnotations.update(v, options: options)
                    v.visibleSize = targetSize
                } else {
                    if !v.isNormalAnnotation(){ continue }
                    let currentSize:CGSize = v.visibleSize
                    if !CGSizeEqualToSize(currentSize, targetSize) {
                        let delta = max((currentSize.width - originSize.width) / originSize.width, 0);
                        let tagertProgress = 1 + min(delta, 0.5 - 0.5 * progress);
                        targetSize = CGSize(width: originSize.width * tagertProgress , height: originSize.height * tagertProgress)
                        let options = ViewAnnotationOptions(width:targetSize.width, height: targetSize.height)
                        try! ooMapView.mapView.viewAnnotations.update(v, options: options)
                        v.visibleSize = targetSize
                    }
                }
            }
        }
    }
    
    private func updateCurrentUserAnno(coord:CLLocationCoordinate2D) {
        if(self.userAnno == nil) {
            let uImage:UIImage = UIImage(named: "current_user_anno")!
            userAnno = OOImageViewAnnotation(coordinate: coord, size: uImage.size, anchor: ViewAnnotationAnchor.bottom, image: uImage, tpye: .currentUserAnnoType)
            userAnno.delegate = self
            ooMapView.addViewAnnotation(view: userAnno)
        }
    }
    
    func changePitch(processor: Double) {
        ooMapView.changePitch(processor: processor)
    }
    
    func changeZoom(processor: Double) {
        ooMapView.changeZoom(processor: processor)
    }
    
}


extension OOMapViewModel: LocationConsumer {
    
    func locationUpdate(newLocation: Location) {
        uCoord = newLocation.coordinate
        if !pucking { return }
        ooMapView.mapView.camera.ease(
            to: CameraOptions(center: newLocation.coordinate),
            duration: 0.25,
            curve: .linear)
//        self.updateCurrentUserAnno(coord: newLocation.coordinate)
    }
    
    func flyCurrentLocation(pucking: Bool) {
        let options = CameraOptions(center: uCoord)
        ooMapView.mapView.camera.ease(to: options, duration: 0.25, curve: .linear)
        ooMapView.showBearing(pucking)
        usePucking(pucking)
    }
    
    func usePucking(_ pucking: Bool) {
        self.pucking = pucking
        ooMapView.showBearing(pucking)
    }
    
}
