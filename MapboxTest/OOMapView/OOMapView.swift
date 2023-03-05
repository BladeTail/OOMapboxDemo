//
//  OOMapView.swift
//
//  Created by Ruiqing Wan on 2023/3/4.
//

import UIKit
import MapboxMaps

class OOMapView : UIView {
    public var mapView: MapView!
    
    init(frame:CGRect, accessToken:String, styleURI:String) {
        super.init(frame: frame)
        let myResourceOptions = ResourceOptions(accessToken: accessToken)
        let styleURI = StyleURI(rawValue: styleURI)!
        let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions, styleURI: styleURI)
        mapView = MapView(frame: self.bounds, mapInitOptions: myMapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(mapView)
        
        mapView.ornaments.logoView.isHidden = true
        mapView.ornaments.compassView.isHidden = true
        mapView.ornaments.scaleBarView.isHidden = true
        mapView.ornaments.attributionButton.isHidden = true
        mapView.gestures.options.pitchEnabled = false
        mapView.gestures.options.pinchZoomEnabled = true
        mapView.gestures.options.quickZoomEnabled = false
        mapView.gestures.options.doubleTapToZoomInEnabled = false
        mapView.gestures.options.doubleTouchToZoomOutEnabled = false
        mapView.gestures.options.pinchEnabled = true
        mapView.gestures.options.rotateEnabled = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func addViewAnnotation(view:OOImageViewAnnotation) {
        try? mapView.viewAnnotations.add(view, options: view.options)
    }
}
