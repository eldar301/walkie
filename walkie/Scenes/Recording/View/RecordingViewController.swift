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

fileprivate struct Constants {
    struct Strings {
        static let moreThanAverage = NSLocalizedString("More than average ", comment: #file)
        static let moveOnAverageIs = NSLocalizedString("Move on! Average is ", comment: #file)
    }
    struct StatisticsView {
        static let cornerRadius: CGFloat = 10.0
        struct BumpAnimation {
            static let property = "transform.scale"
            static let duration = 0.1
            static let desiredScale = 0.95
        }
    }
}

class RecordingViewController: UIViewController {
    
    @IBOutlet weak var graphView: GraphView!
    
    @IBOutlet weak var todayCoveredDistanceView: UIView!
    @IBOutlet weak var todayCoveredDistanceLabel: UILabel!
    @IBOutlet weak var todayComparisonLabel: UILabel!

    @IBOutlet weak var currentWalkDistanceView: UIView!
    @IBOutlet weak var currentWalkDistanceLabel: UILabel!
    
    @IBOutlet weak var recordButton: RecordButton!
    
    var presenter: RecordingPresenter!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        graphView.layer.cornerRadius = Constants.StatisticsView.cornerRadius
        todayCoveredDistanceView.layer.cornerRadius = Constants.StatisticsView.cornerRadius
        currentWalkDistanceView.layer.cornerRadius = Constants.StatisticsView.cornerRadius
        
        let router = Router(viewController: self)
        router.setupRootScene()
        
        for view in [todayCoveredDistanceView, currentWalkDistanceView] {
            let tapGestureRecognier = UITapGestureRecognizer(target: self, action: #selector(showDetails(tapGestureRecognier:)))
            view?.addGestureRecognizer(tapGestureRecognier)
        }
        
        graphView.addTarget(self, action: #selector(showWeekDetails), for: .touchUpInside)
        
        presenter.view = self
    }
    
    @objc func showWeekDetails() {
        guard let index = graphView.pickedIndex else {
            return
        }
        
        presenter.showDetails(ofWalksOfTheWeekdayAtIndex: index)
        
        bumpAnimation(withView: graphView)
    }
    
    @objc func showDetails(tapGestureRecognier: UITapGestureRecognizer) {
        let view = tapGestureRecognier.view!
        
        switch view {
        case todayCoveredDistanceView:
            presenter.showDetailsOfTodayWalks()
            
        case currentWalkDistanceView:
            presenter.showDetailsOfCurrentWalk()
            
        default: return
        }
        
        bumpAnimation(withView: view)
    }
    
    private func bumpAnimation(withView view: UIView) {
        let animation = CABasicAnimation(keyPath: Constants.StatisticsView.BumpAnimation.property)
        animation.fromValue = 1.0
        animation.toValue = Constants.StatisticsView.BumpAnimation.desiredScale
        animation.autoreverses = true
        animation.duration = Constants.StatisticsView.BumpAnimation.duration
        view.layer.add(animation, forKey: nil)
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
    
    func show(error: PresenterError) {
        switch error {
        case .locationAccessNotGranted:
            self.showError(withMessage: "Location access not granted")
            
        case .motionAccessNotGranted:
            graphView.showError(withMessage: "Location access not granted")
        }
    }
    
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
    
    func update(todayTotalDistance: Double) {
        todayCoveredDistanceLabel.text = DistanceToStringCoverter.stringDistance(fromDistance: todayTotalDistance)
    }
    
    func update(weekStatistics: [[Int : Double]], weekAverageDistance: Double, todayTotalDistance: Double) {
        graphView.distancesByDays = weekStatistics
        
        let stringAverageAtWeek = DistanceToStringCoverter.stringDistance(fromDistance: weekAverageDistance)
        if todayTotalDistance > weekAverageDistance {
            todayComparisonLabel.text = "\(Constants.Strings.moreThanAverage)\(stringAverageAtWeek)"
        } else {
            todayComparisonLabel.text = "\(Constants.Strings.moveOnAverageIs)\(stringAverageAtWeek)"
        }

    }
    
}
