//
//  timerPageViewController.swift
//  Proyek_IOS_BP_Jestut
//
//  Created by IOS on 07/12/20.
//  Copyright © 2020 Petra. All rights reserved.
//

import UIKit

class timerPageViewController: UIViewController {
    
    var arrExercise: [Exercise] = []
    var angkaTampil: [Int] = []
    var primKey = ""
    var restTime = ""
    var restInt = 0
    var total = 0
    var counter = 0
    var restt = 0
    var timer = Timer()

    @IBOutlet weak var txtExerciseName: UILabel!
    @IBOutlet weak var txtTime: UILabel!
    
    @IBAction func btnStop(_ sender: UIButton) {
        timer.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TOTAL SEMUA DURASI
        for i in arrExercise {
            total = total + Int(i.duration)! + Int(restTime)!
            angkaTampil.append(Int(i.duration)!)
        }
        total = total - Int(restTime)!
        restInt = Int(restTime)!
        
        //print("TOTAL : \(total)")
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if total > 0 {
            total -= 1
            print("TOTAL : \(total)  DUR: \(Int(arrExercise[counter].duration)!)")
            print("REST : \(restt)")
            //MASUK EXERCISE
            if angkaTampil[counter] >= 0 && restt == 0{
                txtExerciseName.text = arrExercise[counter].title
                txtTime.text = "\(angkaTampil[counter])"
                angkaTampil[counter] -= 1
                
                if angkaTampil[counter] == 0 {
                    restInt = Int(restTime)!
                    restt = 1
                }
            }
            //REST TIME
            else if restInt >= 0 && restt == 1{
                txtExerciseName.text = "REST TIME"
                txtTime.text = "\(restInt)"
                restInt -= 1
                
                if restInt == 0 {
                    restt = 0
                    counter += 1
                }
            }
            
        }
        else{
            txtExerciseName.text =  "WORKOUT COMPLETE"
            txtTime.text = "DONE"
            timer.invalidate()
        }
    }
    
    
    

}
