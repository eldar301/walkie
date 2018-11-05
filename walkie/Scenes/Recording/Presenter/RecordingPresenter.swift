//
//  RecordingPresenter.swift
//  walkie
//
//  Created by Eldar Goloviznin on 09/10/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let currentWalkDidUpdate = Notification.Name("currentWalkDidAddCoordinate")
}

enum PresenterError {
    case locationAccessNotGranted
    case motionAccessNotGranted
}


protocol RecordingView: class {
    func didStartRecording()
    func didStopRecording()
    func show(error: PresenterError)
    func update(currentWalkDistance: Double)
    func update(todayTotalDistance: Double)
    func update(weekStatistics: [[Int: Double]], weekAverageDistance: Double, todayTotalDistance: Double)
}

protocol RecordingPresenter {
    var view: RecordingView? { get set }
    
    func startRecording()
    func stopRecording()
    func showDetailsOfCurrentWalk()
    func showDetailsOfTodayWalks()
    func showDetails(ofWalksOfTheWeekdayAtIndex: Int)
}

class RecordingPresenterDefault: RecordingPresenter, MapPresenterInput {
    
    private let router: Router
    
    private let locationInteractor: LocationInteractor
    private let movementInteractor: MovementInteractor
    private let walksInteractor: WalksInteractor
    
    init(router: Router, locationInteractor: LocationInteractor, movementInteractor: MovementInteractor, walksInteractor: WalksInteractor) {
        self.router = router
        self.locationInteractor = locationInteractor
        self.movementInteractor = movementInteractor
        self.walksInteractor = walksInteractor
        
        self.movementInteractor.delegate = self
        self.locationInteractor.delegate = self
    }
    
    private var fetchedWeekStatistics: [[Date: Double]] = []
    private var todayCoveredDistance: Double = 0
    private var currentWalkDistance: Double = 0
    
    private var isRecording = false
    
    var walksToShow: [Walk]?
    
    weak var view: RecordingView? {
        didSet {
            fetchStatistics()
        }
    }
    
    private var currentWalk: Walk?
    
    func startRecording() {
        currentWalkDistance = 0
        currentWalk = walksInteractor.createWalk(withDate: Date())
        
        movementInteractor.startUpdate()
        locationInteractor.startUpdate()
        
        view?.update(currentWalkDistance: currentWalkDistance)
    }
    
    func stopRecording() {
        if let currentWalk = currentWalk {
            if (currentWalk.coordinates?.count ?? 0) < 2 {
                walksInteractor.delete(walk: currentWalk)
            }
        }
        
        movementInteractor.stopUpdate()
        locationInteractor.stopUpdate()
    }
    
    func showDetailsOfCurrentWalk() {
        guard let currentWalk = currentWalk else {
            return
        }
        
        walksToShow = [currentWalk]
        
        router.showMapScene(input: self, autoupdates: true)
    }
    
    func showDetailsOfTodayWalks() {
        walksToShow = walksInteractor.fetchWalks(withDateComponents: Calendar.current.dateComponents([.year, .month, .day], from: Date()))
        
        router.showMapScene(input: self, autoupdates: isRecording)
    }
    
    func showDetails(ofWalksOfTheWeekdayAtIndex index: Int) {
        guard let date = fetchedWeekStatistics[index].first?.key else {
            return
        }
        
        walksToShow = walksInteractor.fetchWalks(withDateComponents: Calendar.current.dateComponents([.year, .month, .day], from: date))
        
        router.showMapScene(input: self, autoupdates: index == 6)
    }
    
    private func fetchStatistics() {
        movementInteractor.fetchLastWeekStatistics()
    }
    
}

extension RecordingPresenterDefault: LocationInteractorDelegate {

    func didStartUpdateLocation(atLatitude latitude: Double?, longitude: Double?) {
        isRecording = true
        
        if let latitude = latitude, let longitude = longitude {
            let coordinate = walksInteractor.createCoordinate(atLatitude: latitude, longitude: longitude)
            currentWalk?.addToCoordinates(coordinate)
        }
        
        view?.didStartRecording()
    }
    
    func didStopUpdateLocation() {
        isRecording = false
        
        view?.didStopRecording()
    }
    
    func update(withNewLatitude latitude: Double, longitude: Double, distance: Double, accuracy: Double) {
        guard 0 ... 30.0 ~= accuracy else {
            return
        }
        
        print(latitude, longitude, distance, accuracy)
        
        let coordinate = walksInteractor.createCoordinate(atLatitude: latitude, longitude: longitude)
        currentWalk?.addToCoordinates(coordinate)
        
        currentWalkDistance += distance
        todayCoveredDistance += distance
        
        view?.update(currentWalkDistance: currentWalkDistance)
        view?.update(todayTotalDistance: todayCoveredDistance)
        
        NotificationCenter.default.post(name: .currentWalkDidUpdate, object: currentWalk!)
    }
    
    func locationAccessNotGranted() {
        view?.show(error: .locationAccessNotGranted)
    }
    
}

extension RecordingPresenterDefault: MovementInteractorDelegate {
    
    func liveUpdate(distance: Double) {
        currentWalkDistance = distance
        fetchStatistics()
        
        view?.update(currentWalkDistance: currentWalkDistance)
    }
    
    func update(withLastWeekStatistics weekStatistics: [[Date : Double]]) {
        fetchedWeekStatistics = weekStatistics
        
        let weekStatisticsGroupedByWeekday = fetchedWeekStatistics.map { dict -> [Int: Double] in
            let pair = dict.first!
            return [Calendar.current.component(.weekday, from: pair.key) - 1: pair.value]
        }
        
        if let todayStatistics = fetchedWeekStatistics.last?.first, todayStatistics.key == Calendar.current.startOfDay(for: Date()) {
            todayCoveredDistance = todayStatistics.value
            view?.update(todayTotalDistance: todayCoveredDistance)
        }
        
        let weekAverage = fetchedWeekStatistics.reduce(0) { $0 + $1.first!.value } / Double(fetchedWeekStatistics.count)
        
        view?.update(weekStatistics: weekStatisticsGroupedByWeekday, weekAverageDistance: weekAverage, todayTotalDistance: todayCoveredDistance)
    }
    
    func motionAccessNotGranted() {
        view?.show(error: .motionAccessNotGranted)
    }
    
}
