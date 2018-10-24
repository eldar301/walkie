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
}

protocol MapPresenter {
    var view: MapView? { get set }
}

class MapPresenterDefault: MapPresenter {
    
    private let walks: [Walk]
    
    init?(input: MapPresenterInput) {
        guard let inputWalks = input.walksToShow else {
            return nil
        }
        
        self.walks = inputWalks
    }
    
    weak var view: MapView? {
        didSet {
            view?.update(withWalks: walks)
        }
    }
}
