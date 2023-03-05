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
        
        homeView = DemoHomeView(frame: CGRect(origin: CGPointZero, size: UIScreen.main.bounds.size))
        homeView.touchDelegate = mapViewModel.ooMapView
        homeView.isUserInteractionEnabled = true
        self.view.addSubview(homeView)

        homeView.callback { action in
//            if action == "ispace" {
//                self.present(DemoHouseController(), animated: true)
//            } else {
//                self.present(DemoCardController(), animated: true)
//            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapViewModel.onViewDidAppear(vc: self)
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
