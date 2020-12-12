//
//  GetStartedViewController.swift
//  Recipe App
//
//  Created by Johansan on 27/11/20.
//

import UIKit

class GetStartedViewController: UIViewController {

    @IBOutlet weak var appIconImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appIconImageView.layer.cornerRadius = 30
    }
    
    @IBAction func getStartedPressed(_ sender: Any) {
        let defaults = UserDefaults.standard
        if let isNewUser = defaults.object(forKey: "isNewUser") as? Bool {
            if isNewUser {
                defaults.set(false, forKey: "isNewUser")
            }
        }
    }
}
