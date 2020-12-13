//
//  ProfileViewController.swift
//  Recipe App
//
//  Created by Johansan on 27/11/20.
//

import UIKit

class PreferencesViewController: UIViewController {

    @IBOutlet weak var dietsTableView: UITableView!
    @IBOutlet weak var dietsView: UIView!
    
    @IBOutlet weak var intolerencesView: UIView!
    @IBOutlet weak var intolerencesTableView: UITableView!
    
    var diets = defaults.object(forKey: "diets") as? [String]
    
    var intolerences = defaults.object(forKey: "intolerences") as? [String]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for tableView in [dietsTableView, intolerencesTableView] {
            if let tableView = tableView {
                tableView.delegate = self
                tableView.dataSource = self
                
                tableView.rowHeight = UITableView.automaticDimension
                tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
            }
        }
        
        dietsView.layer.shadowColor = UIColor.gray.cgColor
        dietsView.layer.shadowOpacity = 1
        dietsView.layer.shadowOffset = CGSize(width: 1, height: 1)
        dietsView.clipsToBounds = false
        dietsView.layer.cornerRadius = 20
        
        intolerencesView.layer.shadowColor = UIColor.gray.cgColor
        intolerencesView.layer.shadowOpacity = 1
        intolerencesView.layer.shadowOffset = CGSize(width: 1, height: 1)
        intolerencesView.clipsToBounds = false
        intolerencesView.layer.cornerRadius = 20
    }
    
    @IBAction func backToPreferencesViewController(with segue: UIStoryboardSegue) {
        if segue.identifier == "unwindDiets" {
            diets = defaults.object(forKey: "diets") as? [String]
            dietsTableView.reloadData()
        } else if segue.identifier == "unwindIntolerences" {
            intolerences = defaults.object(forKey: "intolerences") as? [String]
            intolerencesTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dietsTableView.reloadData()
        intolerencesTableView.reloadData()
    }

    @IBAction func resetButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Reset Preferences", message: "Are you sure you want to reset your diet and intolerence selection?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            defaults.set([], forKey: "diets")
            defaults.set([], forKey: "intolerences")
            self.dietsTableView.reloadData()
            self.intolerencesTableView.reloadData()
        }
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        present(alert, animated: true, completion: nil)
        

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PreferencesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        diets = defaults.object(forKey: "diets") as? [String]
        intolerences = defaults.object(forKey: "intolerences") as? [String]
        if tableView == dietsTableView {
            if diets!.count == 0 {
                return 1
            }
            return diets!.count
        } else if tableView == intolerencesTableView {
            if intolerences!.count == 0 {
                return 1
            }
            return intolerences!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == dietsTableView {
            let cell = dietsTableView.dequeueReusableCell(withIdentifier: "dietCell", for: indexPath)
            if diets!.count == 0 {
                cell.textLabel?.text = "None"
            } else {
                cell.textLabel?.text = diets![indexPath.row]
            }
            cell.textLabel?.textColor = blue
            cell.textLabel?.font = UIFont(name: "System", size: 20)
            return cell
        } else if tableView == intolerencesTableView {
            let cell = intolerencesTableView.dequeueReusableCell(withIdentifier: "intolerenceCell", for: indexPath)
            if intolerences!.count == 0 {
                cell.textLabel?.text = "None"
            } else {
                cell.textLabel?.text = intolerences![indexPath.row]
            }
            cell.textLabel?.textColor = blue
            cell.textLabel?.font = UIFont(name: "System", size: 20)
            return cell
        }
        return UITableViewCell()
        
    }
    
    
}
