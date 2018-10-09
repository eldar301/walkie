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

class ViewController: UIViewController {
    
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var todayCoveredDistanceView: RoundedView!
    @IBOutlet weak var currentWalkDistanceView: RoundedView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for view in [graphView, todayCoveredDistanceView, currentWalkDistanceView] {
            let tapGestureRecognier = UITapGestureRecognizer(target: self, action: #selector(showDetails(tapGestureRecognier:)))
            view?.addGestureRecognizer(tapGestureRecognier)
        }
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Walk")
        let delete = NSBatchDeleteRequest(fetchRequest: fetch)
        try! CoreDataStack().persistentContainer.viewContext.execute(delete)
        
        let inter = WalksInteractorDefault()
        let w1 = inter.createWalk(withDate: Date())
        w1.distance = 40
        let w2 = inter.createWalk(withDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        w2.distance = 1002
        let w3 = inter.createWalk(withDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        w3.distance = 21
        inter.save()
        
        let results = inter.fetchDistances(atDates: Calendar.current.date(byAdding: .day, value: -10, to: Date())!...Calendar.current.date(byAdding: .day, value: 5, to: Date())!)
        for result in results {
            print(DateFormatter().weekdaySymbols[Calendar.current.component(.weekday, from: result.startOfDay) - 1])
        }
    }
    
    @objc func showDetails(tapGestureRecognier: UITapGestureRecognizer) {
        let view = tapGestureRecognier.view
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1.0
        animation.toValue = 0.95
        animation.autoreverses = true
        animation.duration = 0.1
        view?.layer.add(animation, forKey: nil)
    }
    
    @IBAction func record(_ sender: RecordButton) {
        sender.recording.toggle()
    }
    
}
