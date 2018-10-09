//
//  RecordingPresenter.swift
//  walkie
//
//  Created by Eldar Goloviznin on 09/10/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation

protocol RecordingView: class {
    func didStartRecording()
    func didStopRecording()
    func update(currentWalkDistance: Double)
    func update(todayTotalDistance: Double, whenAverage: Double)
    func update(weekStatistics: [[String: Double]])
}

protocol RecordingPresenter {
    var view: RecordingView? { get set }
    
    func startRecording()
    func stopRecording()
    func showDetailsOfCurrentWalk()
    func showDetailsOfTodayWalks()
    func showDetails(ofWalksOfTheWeekdayAtIndex: Int)
}

class RecordingPresenterDefault: RecordingPresenter {
    
    private let locationInteractor: LocationInteractor
    private let walksInteractor: WalksInteractor
    
    init(locationInteractor: LocationInteractor, walksInteractor: WalksInteractor) {
        self.locationInteractor = locationInteractor
        self.walksInteractor = walksInteractor
        
        locationInteractor.delegate = self
    }
    
    weak var view: RecordingView? {
        didSet {
            fetchAndUpdateStatistics()
        }
    }
    
    private var currentWalk: Walk?
    
    func startRecording() {
        currentWalk = walksInteractor.createWalk(withDate: Date())
        locationInteractor.startUpdate()
    }
    
    func stopRecording() {
        locationInteractor.stopUpdate()
        walksInteractor.save()
    }
    
    func showDetailsOfCurrentWalk() {
        
    }
    
    func showDetailsOfTodayWalks() {
        
    }
    
    func showDetails(ofWalksOfTheWeekdayAtIndex: Int) {
        
    }
    
    private func fetchAndUpdateStatistics() {
        let calendar = Calendar.current
        let currentDate = Date()
        let fromDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -7, to: currentDate)!)
        let toDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: currentDate)!)
        
        let statistics = walksInteractor.fetchDistances(atDates: fromDate...toDate)
        
    }
    
    deinit {
        walksInteractor.save()
    }
    
}

extension RecordingPresenterDefault: LocationInteractorDelegate {
    
    func locationProviderDidStartUpdate() {
        view?.didStartRecording()
    }
    
    func locationProviderDidStopUpdate() {
        view?.didStopRecording()
    }
    
    func update(withNewLatitude latitude: Double, longitude: Double, distanceDifference: Double) {
        let coordinate = walksInteractor.createCoordinate(atLatitude: latitude, longitude: longitude)
        currentWalk?.addToCoordinates(coordinate)
        currentWalk?.distance += distanceDifference
        view?.update(currentWalkDistance: currentWalk!.distance)
    }
    
}
