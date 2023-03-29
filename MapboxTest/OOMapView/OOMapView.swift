//
//  OOMapView.swift
//
//  Created by Ruiqing Wan on 2023/3/4.
//

import UIKit
import MapboxMaps

class OOMapView : UIView {
    public var mapView: MapView!
        
    private var animationStartTime: TimeInterval = 0
    private let zoomThreshold = 16.5
    private var heightChanged: Bool = false
    private var animating: Bool = false
    
    init(frame:CGRect, accessToken:String, styleURI:String) {
        super.init(frame: frame)
        let myResourceOptions = ResourceOptions(accessToken: accessToken)
        let styleURI = StyleURI(rawValue: styleURI)!
        let camera = CameraOptions(zoom: 15, pitch: 45)
        let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions, cameraOptions: camera, styleURI: styleURI)
        mapView = MapView(frame: self.bounds, mapInitOptions: myMapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(mapView)
        
        puckUI()
        
        mapView.mapboxMap.onNext(event: .mapLoaded) { [unowned self] _ in
            self.mapView.location.requestTemporaryFullAccuracyPermissions(withPurposeKey: accessToken)
        }
                
        mapView.mapboxMap.onNext(event: .styleLoaded) { [unowned self] _ in
            self.fixBuildingExtrusions()
        }
        
        mapView.mapboxMap.onEvery(event: .cameraChanged) { [unowned self] _ in
            self.cameraChanged()
        }
                
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
        print("--- > \(self.mapView.cameraState.zoom)")
        if self.mapView.cameraState.zoom >= zoomThreshold, !heightChanged, !animating {
            changeFillExtrusionHeight()
        }
        if self.mapView.cameraState.zoom < zoomThreshold, heightChanged, !animating {
            changeFillExtrusionHeight()
        }
    }
    
    func changeBearingAndPitch(increase: Bool) {
        var toBearing = self.mapView.cameraState.bearing
        var toPitch = self.mapView.cameraState.pitch
        if increase {
            toBearing += 10
            toPitch += 5
        } else {
            toBearing -= 10
            toPitch -= 5
        }
        let animator = mapView.camera.makeAnimator(duration: 1, curve: .linear) { (transition) in
//            transition.bearing.toValue = toBearing
            transition.pitch.toValue = toPitch
        }
        animator.startAnimation()
    }
    
    private func changeFillExtrusionHeight() {
        animating = true
        let link = CADisplayLink(target: self, selector: #selector(animateNextStep(_:)))
        link.add(to: .main, forMode: .default)
        animationStartTime = CACurrentMediaTime()
    }
    
    @objc private func animateNextStep(_ displayLink: CADisplayLink) {
        let animationDuration: TimeInterval = 4
        
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
        var config = Puck2DConfiguration.makeDefault(showBearing: true)
        mapView.location.options.puckType = .puck2D(config)
        mapView.location.options.puckBearingSource = .heading
    }
    
}

extension OOMapView: LocationPermissionsDelegate {
    func locationManager(_ locationManager: LocationManager, didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization) {
        if accuracyAuthorization == .reducedAccuracy {
         // Perform an action in response to the new change in accuracy
        }
    }
}
