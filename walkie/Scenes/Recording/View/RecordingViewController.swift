//
//  ViewController.swift
//  walkie
//
//  Created by Eldar Goloviznin on 05/10/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class RecordingViewController: UIViewController {
    
    @IBOutlet weak var graphView: GraphView!
    
    @IBOutlet weak var todayCoveredDistanceView: RoundedView!
    @IBOutlet weak var todayCoveredDistanceLabel: UILabel!
    @IBOutlet weak var todayComparisonLabel: UILabel!

    @IBOutlet weak var currentWalkDistanceView: RoundedView!
    @IBOutlet weak var currentWalkDistanceLabel: UILabel!
    
    @IBOutlet weak var recordButton: RecordButton!
    
    private let presenter = RecordingPresenterDefault(locationInteractor: LocationInteractorDefault(), walksInteractor: WalksInteractorDefault())
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for view in [graphView, todayCoveredDistanceView, currentWalkDistanceView] {
            let tapGestureRecognier = UITapGestureRecognizer(target: self, action: #selector(showDetails(tapGestureRecognier:)))
            view?.addGestureRecognizer(tapGestureRecognier)
        }
        
        presenter.view = self
    }
    
    @objc func showDetails(tapGestureRecognier: UITapGestureRecognizer) {
        let view = tapGestureRecognier.view
        
        switch view {
        case graphView:
            presenter.showDetails(ofWalksOfTheWeekdayAtIndex: 0)
            
        case todayCoveredDistanceView:
            presenter.showDetailsOfTodayWalks()
            
        case currentWalkDistanceView:
            presenter.showDetailsOfCurrentWalk()
            
        default: fatalError()
        }
        
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1.0
        animation.toValue = 0.95
        animation.autoreverses = true
        animation.duration = 0.1
        view?.layer.add(animation, forKey: nil)
    }
    
    @IBAction func record(_ sender: RecordButton) {
        if recordButton.recording {
            presenter.stopRecording()
        } else {
            presenter.startRecording()
        }
    }
    
}

extension RecordingViewController: RecordingView {
    
    func didStartRecording() {
        currentWalkDistanceView.isHidden = false
        recordButton.recording = true
    }
    
    func didStopRecording() {
        currentWalkDistanceView.isHidden = true
        recordButton.recording = false
    }
    
    func update(currentWalkDistance: Double) {
        currentWalkDistanceLabel.text = DistanceToStringCoverter.stringDistance(fromDistance: currentWalkDistance)
    }
    
    func update(todayTotalDistance: Double, whenAverage averageAtWeek: Double) {
        todayCoveredDistanceLabel.text = DistanceToStringCoverter.stringDistance(fromDistance: todayTotalDistance)
        let stringAverageAtWeek = DistanceToStringCoverter.stringDistance(fromDistance: averageAtWeek)
        if todayTotalDistance > averageAtWeek {
            todayComparisonLabel.text = "More than average \(stringAverageAtWeek)"
        } else {
            todayComparisonLabel.text = "Move on! Average is \(stringAverageAtWeek)"
        }
    }
    
    func update(weekStatistics: [[Date : Double]]) {
        graphView.update(withDistancesByDays: weekStatistics)
    }
    
}
