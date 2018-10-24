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
    func update(weekStatistics: [[Date: Double]])
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
    
    private let locationInteractor: LocationInteractor
    private let walksInteractor: WalksInteractor
    
    private var averageWeekDistance: Double = 0
    private var todayCoveredDistance: Double = 0
    private var fetchedWeekdayDates: [Date] = []
    
    init(locationInteractor: LocationInteractor, walksInteractor: WalksInteractor) {
        self.locationInteractor = locationInteractor
        self.walksInteractor = walksInteractor
        
        locationInteractor.delegate = self
    }
    
    var walksToShow: [Walk]?
    
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
        walksInteractor.save()
        locationInteractor.stopUpdate()
    }
    
    func showDetailsOfCurrentWalk() {
        guard let currentWalk = currentWalk else {
            return
        }
        
        walksToShow = [currentWalk]
    }
    
    func showDetailsOfTodayWalks() {
        walksToShow = walksInteractor.fetchWalks(atDate: Date())
    }
    
    func showDetails(ofWalksOfTheWeekdayAtIndex index: Int) {
        walksToShow = walksInteractor.fetchWalks(atDate: fetchedWeekdayDates[index])
    }
    
    private func fetchAndUpdateStatistics() {
        fetchedWeekdayDates = []
        let currentDate = Date()
        
        let calendar = Calendar.current
        let currentDateStartOfDay = calendar.startOfDay(for: currentDate)
        let fromDate = calendar.date(byAdding: .day, value: -6, to: currentDateStartOfDay)!
        let toDate = calendar.date(byAdding: .day, value: 1, to: currentDateStartOfDay)!
        
        let statistics = walksInteractor.fetchDistances(atDates: fromDate...toDate)
        
        todayCoveredDistance = (statistics[currentDateStartOfDay] ?? 0) + (currentWalk?.distance ?? 0)
        averageWeekDistance = (statistics.reduce(0.0, { $0 + $1.value }) + (currentWalk?.distance ?? 0)) / 7
        
        view?.update(todayTotalDistance: todayCoveredDistance, whenAverage: averageWeekDistance)
        
        var sortedStatistics: [[Date: Double]] = []
        for date in fromDate ..< toDate {
            fetchedWeekdayDates.append(date)
            sortedStatistics.append([date: statistics[date] ?? 0])
        }
        
        view?.update(weekStatistics: sortedStatistics)
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
        
        todayCoveredDistance += distanceDifference
        view?.update(todayTotalDistance: todayCoveredDistance, whenAverage: averageWeekDistance)
    }
    
}
