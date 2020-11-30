//
//  InterfaceController.swift
//  WatchKit HealthKit v2 WatchKit Extension
//
//  Created by Eki Rifaldi on 23/07/20.
//  Copyright © 2020 Eki Rifaldi. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var button: WKInterfaceButton!
    @IBOutlet weak var label: WKInterfaceLabel!
    
    var isRecording = false
    
    //For workout session
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var currentQuery: HKQuery?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        //Check HealthStore
        guard HKHealthStore.isHealthDataAvailable() == true else {
            print("Health Data Not Avaliable")
            return
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func btnPressed() {
                if(!isRecording){
                    let stopTitle = NSMutableAttributedString(string: "Stop Recording")
                    stopTitle.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], range: NSMakeRange(0, stopTitle.length))
                    button.setAttributedTitle(stopTitle)
                    isRecording = true
                    startWorkout() //Start workout session/healthkit streaming
                }else{
                    let exitTitle = NSMutableAttributedString(string: "Start Recording")
                    exitTitle.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.green], range: NSMakeRange(0, exitTitle.length))
                    button.setAttributedTitle(exitTitle)
                    isRecording = false
        //            healthStore.end(session!)
                    session?.stopActivity(with: Date())
                    label.setText("Heart Rate")
                    
                }
    }
}

extension InterfaceController: HKWorkoutSessionDelegate{
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("State: \(toState.rawValue)")
        switch toState {
        case .running:
            if let query = heartRateQuery(date){
                self.currentQuery = query
                healthStore.execute(query)
            }
        //Execute Query
        case .stopped: //sebelumnya .ended
            //Stop Query
            healthStore.stop(self.currentQuery!)
            session?.end()
            session = nil
        default:
            print("Unexpected state: \(toState.rawValue)")
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        //Do Nothing
    }
    
    func startWorkout(){
        // If a workout has already been started, do nothing.
        if (session != nil) {
            return
        }
        // Configure the workout session.
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .badminton
        workoutConfiguration.locationType = .indoor
        
        do {
//            session = try HKWorkoutSession(configuration: workoutConfiguration)
            session = try HKWorkoutSession(healthStore: healthStore, configuration: workoutConfiguration)
            session?.delegate = self
        } catch {
            fatalError("Unable to create workout session")
        }
        
        
//        healthStore.start(self.session!)
        session?.startActivity(with: Date())
    }
    
    func heartRateQuery(_ startDate: Date) -> HKQuery? {
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictEndDate)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate])
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType!, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            //Do nothing
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            guard let samples = samples as? [HKQuantitySample] else {return}
            DispatchQueue.main.async {
                guard let sample = samples.first else { return }
                let value = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                self.label.setText(String(UInt16(value))) //Update label
            }
            
        }
        
        return heartRateQuery
    }
    
}
