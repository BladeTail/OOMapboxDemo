//
//  OOMapView.swift
//
//  Created by Ruiqing Wan on 2023/3/4.
//

import UIKit
import MapboxMaps

//       2s          0.5s
// zoom 0.36  -0.5s-  12   -0.5s-  22

class OOMapView : UIView {
    public var mapView: MapView!
    
    typealias Action = (_ type: MapboxMaps.GestureType) -> Void
    private var _gestureHandler: Action!
    var gestureHandler: Action {
        get {
            _gestureHandler
        }
        set {
            _gestureHandler = newValue
        }
    }
        
    private var animationStartTime: TimeInterval = 0
    private let zoomThreshold = 16.5
    private var heightChanged: Bool = false
    private var animating: Bool = false
    private var light = Light()
    
    init(frame:CGRect, accessToken:String, styleURI:String) {
        super.init(frame: frame)
        let myResourceOptions = ResourceOptions(accessToken: accessToken)
        let styleURI = StyleURI(rawValue: styleURI)!
        let camera = CameraOptions(zoom: 0.36, pitch: 45)
        let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions, cameraOptions: camera, styleURI: styleURI)
        mapView = MapView(frame: self.bounds, mapInitOptions: myMapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(mapView)
        
        ///puckUI()
        
        mapView.gestures.delegate = self
                
        mapView.ornaments.logoView.isHidden = true
        mapView.ornaments.compassView.isHidden = true
        mapView.ornaments.scaleBarView.isHidden = true
        mapView.ornaments.attributionButton.isHidden = true
        mapView.gestures.options.pitchEnabled = false
        mapView.gestures.options.pinchZoomEnabled = true
        mapView.gestures.options.quickZoomEnabled = true
        mapView.gestures.options.doubleTapToZoomInEnabled = false
        mapView.gestures.options.doubleTouchToZoomOutEnabled = false
        mapView.gestures.options.pinchEnabled = true
        mapView.gestures.options.rotateEnabled = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func addViewAnnotation(view:OOImageViewAnnotation) {
        try? mapView.viewAnnotations.add(view, options: view.options)
    }
    
}


// MARK: - 建筑高度变化
extension OOMapView {
    
    func cameraChanged() {
        if self.mapView.cameraState.zoom >= zoomThreshold, !heightChanged, !animating {
            changeFillExtrusionHeight()
        }
        if self.mapView.cameraState.zoom < zoomThreshold, heightChanged, !animating {
            changeFillExtrusionHeight()
        }
    }
    
    // 0 - 85
    func changePitch(processor: Double, startPitch:Double) {
        let toValue = startPitch + processor * 90;
        mapView.mapboxMap.setCamera(to: CameraOptions(pitch: toValue))
    }
    
    // 10 - 20
    func changeZoom(processor: Double, startZoom:Double) {
        let toValue = startZoom + processor * 10;
        mapView.mapboxMap.setCamera(to: CameraOptions(zoom: toValue))
    }
    
    private func changeFillExtrusionHeight() {
        animating = true
        let link = CADisplayLink(target: self, selector: #selector(animateNextStep(_:)))
        link.add(to: .main, forMode: .default)
        animationStartTime = CACurrentMediaTime()
    }
    
    @objc private func animateNextStep(_ displayLink: CADisplayLink) {
        let animationDuration: TimeInterval = 0.25
        
        var progress = 0.0
        if heightChanged {
            progress = (CACurrentMediaTime() - animationStartTime) / animationDuration
        } else {
            progress = 1 - (CACurrentMediaTime() - animationStartTime) / animationDuration
        }
        
        defer {
            if progress <= 0 || progress >= 1 {
                displayLink.invalidate()
                heightChanged.toggle()
                animating = false
            }
        }
        
        let exp = Exp(.interpolate) {
            Exp(.linear)
            Exp(.zoom)
            15
            0
            16
            Exp(.product) {
                Exp(.get) { "height" }
                max(progress, 0.1)
            }
        }
        if let data = try? JSONEncoder().encode(exp.self),
           let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
            try? mapView.mapboxMap.style.setLayerProperty(for: "building-extrusion",
                                                          property: "fill-extrusion-height",
                                                          value: jsonObject)
        }
        
    }

    func fixBuildingExtrusions() {
        try? mapView.mapboxMap.style.setLayerProperty(for: "building-extrusion",
                                                      property: "fill-extrusion-ambient-occlusion-intensity",
                                                      value: 0.3)

        try? mapView.mapboxMap.style.setLayerProperty(for: "building-extrusion",
                                                      property: "fill-extrusion-ambient-occlusion-radius",
                                                      value: 3.0)
    }

}

// MARK: - 导航
extension OOMapView {
    
    private func puckUI() {
        let config = Puck2DConfiguration.makeDefault(showBearing: false)
        mapView.location.options.puckType = .puck2D(config)
    }
    
    func showBearing(_ visible: Bool) {
        let config = Puck2DConfiguration.makeDefault(showBearing: visible)
        mapView.location.options.puckType = .puck2D(config)
        mapView.location.options.puckBearingSource = .heading
        light.colorTransition = StyleTransition(duration: 0.35, delay: 0)
        if visible { // white
            light.color = StyleColor(red: 22, green: 60, blue: 131, alpha: 1)
        } else { // dark
            light.color = StyleColor(red: 229, green: 235, blue: 255, alpha: 1)
        }
        try? mapView.mapboxMap.style.setLight(light)
    }
    
}


extension OOMapView: LocationPermissionsDelegate {

    func locationManager(_ locationManager: LocationManager, didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization) {
        if accuracyAuthorization == .reducedAccuracy {
         // Perform an action in response to the new change in accuracy
        }
    }
    
}


extension OOMapView: GestureManagerDelegate {
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didBegin gestureType: MapboxMaps.GestureType) {
        _gestureHandler(gestureType)
    }
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEnd gestureType: MapboxMaps.GestureType, willAnimate: Bool) {
        
    }
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEndAnimatingFor gestureType: MapboxMaps.GestureType) {
        
    }
    
}
