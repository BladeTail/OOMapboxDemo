//
//  ViewController.swift
//  MapboxTest
//
//  Created by Ruiqing Wan on 2023/2/17.
//

import UIKit


class ViewController: UIViewController {
    
    var homeView: DemoHomeView!
    internal var mapViewModel:OOMapViewModel = OOMapViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapViewModel.onViewDidLoad(vc: self)
        mapViewModel.delegate = self
        mapViewModel.ooMapView.gestureHandler = { [unowned self] _ in
            if self.homeView.puck.isSelected {
                self.homeView.puck.isSelected = false
                openPuking(false)
            }
        }
        
        addHomeView()
        addGestureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapViewModel.onViewDidAppear(vc: self)
    }
    
    private func addHomeView() {
        homeView = DemoHomeView(frame: CGRect(origin: CGPointZero, size: UIScreen.main.bounds.size))
        homeView.touchDelegate = mapViewModel.ooMapView
        homeView.isUserInteractionEnabled = true
        self.view.addSubview(homeView)
        
        homeView.callback { [unowned self] action in
            if action == "open puck" {
                openPuking(true)
            } else if action == "close puck" {
                openPuking(false)
            }
        }
    }
    
    var startPitch:Double = 0;
    var startZoom:Double = 0;
    private func addGestureView() {
        let leftView = OOMapGestureView(frame: CGRect(x: 0, y: 0, width: 20, height: UIScreen.main.bounds.height), position: .left)
        view.addSubview(leftView)
        leftView.processor = { [unowned self] processor, isStarted in
            if isStarted {
                startPitch = self.mapViewModel.ooMapView.mapView.cameraState.pitch;
            } else {
                self.mapViewModel.ooMapView.changePitch(processor: processor, startPitch: startPitch)
            }
        }
        
        let rightView = OOMapGestureView(frame: CGRect(x: UIScreen.main.bounds.width - 20, y: 0, width: 20, height: UIScreen.main.bounds.height), position: .right)
        view.addSubview(rightView)
        rightView.processor = { [unowned self] processor, isStarted in
            
            if isStarted {
                startZoom = self.mapViewModel.ooMapView.mapView.cameraState.zoom;
            } else {
                self.mapViewModel.ooMapView.changeZoom(processor: processor, startZoom: startZoom)
            }
        }
    }
    
    private func openPuking(_ open: Bool) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        if open {
            self.mapViewModel.flyCurrentLocation(pucking: true)
        } else {
            self.mapViewModel.usePucking(false)
        }
    }
    
}


extension ViewController: OOMapViewDelegate {
    
    func didSelectAnnotaion(annotation:OOImageViewAnnotation, index:NSInteger) {
        if let vc = self.presentedViewController as? DemoCardController {
            vc.showCollectionItem(at: index, animated: true)
        } else {
            let vc = DemoCardController()
            vc.callback { index in
                self.mapViewModel.selectAnnotationAtIndex(index: index)
            }
            self.present(vc, animated: true) {
                vc.showCollectionItem(at: index, animated: true)
            }
        }
    }
    
    func didDeselectAnnotaion(annotation:OOImageViewAnnotation, index:NSInteger) {
        
    }
    
    func didSelectHouse() {
        self.present(DemoHouseController(), animated: true)
    }
    
    func didDeselectHouse() {
        
    }
    
}
