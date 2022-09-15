//
//  workoutDetailCell.swift
//  Proyek_IOS_BP_Jestut
//
//  Created by IOS on 07/12/20.
//  Copyright © 2020 Petra. All rights reserved.
//

import UIKit

class workoutDetailCell: UITableViewCell {
    
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtDuration: UILabel!
    
    func setExercise (exercise: Exercise){
        txtTitle.text = exercise.title
        txtDuration.text = "\(exercise.duration) seconds"
    }
}
