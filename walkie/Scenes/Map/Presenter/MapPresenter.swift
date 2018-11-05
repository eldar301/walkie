//
//  MapPresenter.swift
//  walkie
//
//  Created by Eldar Goloviznin on 16/10/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation

protocol MapPresenterInput {
    var walksToShow: [Walk]? { get }
}

protocol MapView: class {
    func update(withWalks: [Walk])
    func update(currentWalk: Walk, withNewCoordinate: Coordinate)
}

protocol MapPresenter {
    var view: MapView? { get set }
}

class MapPresenterStatic: MapPresenter {
    
    private let walks: [Walk]
    
    init?(input: MapPresenterInput) {
        guard let inputWalks = input.walksToShow else {
            return nil
        }
        
        let walks = inputWalks.filter { !($0.coordinates?.array.isEmpty ?? false) }
        
        guard !walks.isEmpty else {
            return nil
        }
        
        self.walks = walks
    }
    
    weak var view: MapView? {
        didSet {
            view?.update(withWalks: walks)
        }
    }
    
}

class MapPresenterDynamic: MapPresenterStatic {
    
    override init?(input: MapPresenterInput) {
        super.init(input: input)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didAddLocationForCurrentWalk), name: .currentWalkDidUpdate, object: nil)
    }
    
    @objc func didAddLocationForCurrentWalk(notification: Notification) {
        guard notification.name == .currentWalkDidUpdate else {
            return
        }
        
        guard let currentWalk = notification.object as? Walk else {
            return
        }
        
        self.view?.update(currentWalk: currentWalk, withNewCoordinate: currentWalk.coordinates!.lastObject as! Coordinate)
    }
    
}
