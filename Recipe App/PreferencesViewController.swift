//
//  ProfileViewController.swift
//  Recipe App
//
//  Created by Johansan on 27/11/20.
//

import UIKit

class PreferencesViewController: UIViewController {

    @IBOutlet weak var dietsTableView: UITableView!
    
    @IBOutlet weak var intolerencesTableView: UITableView!
    
    var diets = defaults.object(forKey: "diets") as? [String]
    
    var intolerences = defaults.object(forKey: "intolerences") as? [String]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dietsTableView.delegate = self
        dietsTableView.dataSource = self
        
        intolerencesTableView.delegate = self
        intolerencesTableView.dataSource = self
        

        // Do any additional setup after loading the view.
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
    

    @IBAction func resetButtonPressed(_ sender: Any) {
        defaults.set(true, forKey: "isNewUser")
        defaults.set([], forKey: "diets")
        defaults.set([], forKey: "intolerences")
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
        if tableView == dietsTableView {
            return diets!.count
        } else if tableView == intolerencesTableView {
            return intolerences!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == dietsTableView {
            let cell = dietsTableView.dequeueReusableCell(withIdentifier: "dietCell", for: indexPath)
            cell.textLabel?.text = diets![indexPath.row]
            cell.textLabel?.textColor = blue
            cell.textLabel?.font = UIFont(name: "System", size: 20)
            return cell
        } else if tableView == intolerencesTableView {
            let cell = intolerencesTableView.dequeueReusableCell(withIdentifier: "intolerenceCell", for: indexPath)
            cell.textLabel?.text = intolerences![indexPath.row]
            cell.textLabel?.textColor = blue
            cell.textLabel?.font = UIFont(name: "System", size: 20)
            return cell
        }
        return UITableViewCell()
        
    }
    
    
}
