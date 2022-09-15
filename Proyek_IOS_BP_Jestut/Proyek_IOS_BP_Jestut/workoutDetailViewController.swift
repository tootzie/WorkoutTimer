//
//  workoutDetailViewController.swift
//  Proyek_IOS_BP_Jestut
//
//  Created by IOS on 06/12/20.
//  Copyright © 2020 Petra. All rights reserved.
//

import UIKit
import Firebase

class workoutDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: DatabaseReference!
    var titleWorkout = ""
    var primKey = ""
    var restTime = "0"
    var arrExercises : [Exercise] = []
    var defaults = UserDefaults.standard
    
    @IBOutlet weak var txtTitleWorkout: UILabel!
    @IBOutlet weak var txtRestTime: UILabel!
    @IBOutlet weak var tableViewDetail: UITableView!
    
    @IBAction func btnStart(_ sender: UIButton) {
        performSegue(withIdentifier: "toTimerPage", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! timerPageViewController
        vc.primKey = primKey
        vc.arrExercise = arrExercises
        vc.restTime = restTime
    }
    
    
    
    @IBAction func btnAddExercise(_ sender: UIButton) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Add Exercise", message: "", preferredStyle: .alert)
        //2. Add the text field
        alert.addTextField { (textField) in
            textField.placeholder = "Exercise Name"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Duration(s)"
        }
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
            let textFieldTitle = alert?.textFields![0]
            let textFieldDuration = alert?.textFields![1]
            let val = [ "name": textFieldTitle?.text, "duration": textFieldDuration?.text ]
            self.ref.child("Workouts").child(self.primKey).childByAutoId().setValue(val)
            
            //ADD DATA TO ARRAY
            let addArray = Exercise(title: (textFieldTitle?.text)!, duration: (textFieldDuration?.text)!)
            self.arrExercises.append(addArray)
            self.arrExercises = []
        }))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func btnRestTime(_ sender: UIButton) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Rest Time(s)", message: "", preferredStyle: .alert)
        //2. Add the text field
        alert.addTextField { (textField) in
            textField.placeholder = "30"
        }
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            //EDIT REST TIME
            self.ref.child("Workouts").child(self.primKey).updateChildValues(["rest":textField?.text ?? ""])
            self.txtRestTime.text = "Rest Time: \(textField?.text ?? "0")s"
            self.restTime = "\(textField?.text ?? "0")"
        }))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        arrExercises = []
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TITLE WORKOUT : \(titleWorkout)")

        //DATABASE SETUP
        ref = Database.database().reference()
        
        //TABLEVIEW SETUP
        tableViewDetail.delegate = self
        tableViewDetail.dataSource = self
        
        //SAVE PRIMARY KEY TO USERDEFAULTS
        ref.child("Workouts").queryOrdered(byChild: "title").queryEqual(toValue: self.titleWorkout).observe(.value, with:{ (snapshot: DataSnapshot) in
            for snap in snapshot.children {
                let idkey = (snap as! DataSnapshot).key
                //print("IDKEY DALAM: \(self.idkey)")
                //DispatchQueue.main.async {
                self.defaults.set(idkey, forKey: "primaryKey")
                //}
            }
            
        })
        
        //LOAD LABEL
        txtTitleWorkout.text = titleWorkout
        ref.child("Workouts").queryOrdered(byChild: "title").queryEqual(toValue: self.titleWorkout).observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let dictionary = snapshot.value as? [String:Any] else {return}
                    dictionary.forEach({ (key , value) in
                        for (m,n) in value as! NSDictionary{
                            if(m as! String == "rest"){
                                self.txtRestTime.text = "Rest Time: \(n as! String)s"
                            }
                        }
                    })
                }) { (Error) in
                    print("Failed to fetch: ", Error)
                }
    }
    
    override func viewDidAppear(_ animated: Bool) {
            self.primKey = self.defaults.string(forKey: "primaryKey") ?? "kosong"
            self.updateTable()
    }
    
    
    func updateTable(){
        var titleIn = ""
        var durationIn = ""
        
        arrExercises = []
        ref.child("Workouts").child(primKey).observe(.value, with: { (snapshot) in
            if let v = snapshot.value as? NSDictionary {
                print("V : ===========")
                print(v as Any)
                for (i,j) in v {
                    let i1 = i as! String
                    if (i1 != "rest" && i1 != "title") {
                        print("I : \(i)")
                        for (m,n) in j as! NSDictionary {
                            let m1 = m as! String
                            let n1 = n as! String
                            if (m1 == "name"){
                                titleIn = n1
                            }else{
                                durationIn = n1
                            }
                        }
                        let data = Exercise(title: titleIn, duration: durationIn)
                        self.arrExercises.append(data)
                    }
                    if (i1 == "rest"){
                        self.restTime = j as! String
                    }
                }
                self.tableViewDetail.reloadData()
            }
          }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    //TABLE VIEW SECTION ============================================
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let edit = self.arrExercises[indexPath.row]
        self.arrExercises = []
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Edit Exercise", message: "", preferredStyle: .alert)
        //2. Add the text field
        alert.addTextField { (textField) in
            textField.placeholder = "\(edit.title)"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "\(edit.duration)"
        }
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak alert] (_) in
            let textFieldTitle = alert?.textFields![0]
            let textFieldDuration = alert?.textFields![1]
            //AMBIL PRIMARY KEY
            var keyy = ""
            self.ref.child("Workouts").child(self.primKey).queryOrdered(byChild: "name").queryEqual(toValue: edit.title).observe(.value, with:{ (snapshot: DataSnapshot) in
                for snap in snapshot.children {
                    keyy = (snap as! DataSnapshot).key
                    //EDIT EXERCISE
                    DispatchQueue.main.async{
                        self.ref.child("Workouts").child(self.primKey).child(keyy).updateChildValues(["name":textFieldTitle?.text ?? "", "duration":textFieldDuration?.text ?? ""])
                    }
                }
            })
           
        }))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrExercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let exercise = arrExercises[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "workoutDetailCell") as! workoutDetailCell
        cell.setExercise(exercise: exercise)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    //SWIPE TO DELETE
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            let hapus = self.arrExercises[indexPath.row]
            self.arrExercises = []
            print(hapus)
            self.ref.child("Workouts").child(self.primKey).queryOrdered(byChild: "name").queryEqual(toValue: hapus.title).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String:Any] else {return}
                dictionary.forEach({ (key , _) in
                    self.ref.child("Workouts/\(self.primKey)/\(key)").removeValue()
                })
            }) { (Error) in
                print("Failed to fetch: ", Error)
            }
            completion(true)
        }
        return action
    }
}
