//
//  titleWorkoutViewController.swift
//  Proyek_IOS_BP_Jestut
//
//  Created by IOS on 05/12/20.
//  Copyright © 2020 Petra. All rights reserved.
//

import UIKit
import Firebase

class titleWorkoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: DatabaseReference!
    var data : [String] = []
    var titleWorkout = ""
    var defaults = UserDefaults.standard
    
    //ADD WORKOUT
    @IBAction func btnAddWorkout(_ sender: UIButton) {
        self.data = []
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Add Workout", message: "Enter Title", preferredStyle: .alert)
        //2. Add the text field
        alert.addTextField { (textField) in
            textField.placeholder = "Arm Workout"
        }
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            let val = [ "title": textField?.text, "rest": "0" ]
            self.ref.child("Workouts").childByAutoId().setValue(val)
        }))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var tableViewWorkouts: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //DATABASE SETUP
        ref = Database.database().reference()
        
        //TABLE VIEW SETUP
        tableViewWorkouts.delegate = self
        tableViewWorkouts.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //defaults.removeObject(forKey: "primaryKey")
        updateTable()
    }
    
    func updateTable(){
        data = []
        ref.child("Workouts").observe(.value, with: { (snapshot) in
            let v = snapshot.value as! NSDictionary
            print(v as Any)
            for (_,j) in v {
                for (m,n) in j as! NSDictionary {
                    if(m as! String == "title"){
                        self.data += [ "\(n)" ]
                    }
                }
                self.tableViewWorkouts.reloadData()
            }
          }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    //TABLE VIEW SECTIONS ============================================
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataSearch = self.data[indexPath.row]
        titleWorkout = dataSearch
        print("TITLE WORKOUT : \(titleWorkout)")
        performSegue(withIdentifier: "toWorkoutDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! workoutDetailViewController
        vc.titleWorkout = titleWorkout
        //vc.primKey = defaults.string(forKey: "primaryKey") ?? "kosong"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    
    //SWIPE BUTTONS
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = editAction(at: indexPath)
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    func editAction(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            let edit = self.data[indexPath.row]
            //1. Create the alert controller.
            let alert = UIAlertController(title: "Edit Workout", message: "Edit Title", preferredStyle: .alert)
            //2. Add the text field
            alert.addTextField { (textField) in
                textField.placeholder = edit
            }
            // 3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
                
                //AMBIL PRIMARY KEY
                var keyy = ""
                self.ref.child("Workouts").queryOrdered(byChild: "title").queryEqual(toValue: edit).observe(.value, with:{ (snapshot: DataSnapshot) in
                    for snap in snapshot.children {
                        keyy = (snap as! DataSnapshot).key
                        //EDIT TITLE
                        DispatchQueue.main.async{
                            self.ref.child("Workouts").child(keyy).updateChildValues(["title":textField?.text ?? ""])
                            self.data = []
                        }
                    }
                })
                
            }))
            
            // 4. Present the alert.
            self.present(alert, animated: true, completion: nil)
            

            completion(true)
        }
        return action
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            let hapus = self.data[indexPath.row]
            print(hapus)
            self.ref.child("Workouts").queryOrdered(byChild: "title").queryEqual(toValue: hapus).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String:Any] else {return}
                dictionary.forEach({ (key , _) in
                    self.ref.child("Workouts/\(key)").removeValue()
                    self.data = []
                })
            }) { (Error) in
                print("Failed to fetch: ", Error)
            }
            completion(true)
        }
        return action
    }

}
