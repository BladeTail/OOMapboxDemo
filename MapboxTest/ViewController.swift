//
//  ViewController.swift
//  MapboxTest
//
//  Created by Ruiqing Wan on 2023/2/17.
//

import UIKit


class ViewController: UIViewController {
    
    internal var mapViewModel:OOMapViewModel = OOMapViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapViewModel.onViewDidLoad(vc: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapViewModel.onViewDidAppear(vc: self)
    }
}

