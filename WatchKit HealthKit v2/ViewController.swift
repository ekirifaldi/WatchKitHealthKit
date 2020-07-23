//
//  ViewController.swift
//  WatchKit HealthKit v2
//
//  Created by Eki Rifaldi on 23/07/20.
//  Copyright © 2020 Eki Rifaldi. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    let healthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let allTypes = Set([HKObjectType.workoutType(),
                            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                            HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                            HKObjectType.quantityType(forIdentifier: .heartRate)!])

        healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
            if !success {
                // Handle the error here.
            }
        }
    }


}

