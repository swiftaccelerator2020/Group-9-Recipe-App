//
//  GetStartedViewController.swift
//  Recipe App
//
//  Created by Johansan on 27/11/20.
//

import UIKit

class GetStartedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func getStartedPressed(_ sender: Any) {
        let defaults = UserDefaults.standard
        if let isNewUser = defaults.object(forKey: "isNewUser") as? Bool {
            if isNewUser {
                defaults.set(false, forKey: "isNewUser")
            }
        }
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
