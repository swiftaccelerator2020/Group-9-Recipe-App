//
//  UIPreferenceButton.swift
//  Recipe App
//
//  Created by Lim Meng Shin on 25/11/20.
//

import UIKit

let defaults = UserDefaults.standard

class UIPreferenceButton: UIButton {
    var pressed = false
    var diets = [
        "Gluten Free",
        "Ketogenic",
        "Vegetarian",
        "Lacto-Vegetarian",
        "Ovo-Vegetarian",
        "Vegan",
        "Pescetarian",
        "Paleo",
        "Primal",
        "Whole30"
    ]
    let intolerences = [
        "Dairy",
        "Egg",
        "Gluten",
        "Grain",
        "Peanut",
        "Seafood",
        "Sesame",
        "Shellfish",
        "Soy",
        "Sulfite",
        "Tree Nut",
        "Wheat"
    ]
    var listKey = ""
    var name: String?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 10
        self.backgroundColor = UIColor.white
        self.setTitleColor(blue, for: .normal)
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowOpacity = 1
        self.layer.masksToBounds = false
        
        self.name = self.titleLabel?.text
        if intolerences.contains(self.name!) {
            self.listKey = "intolerences"
        } else if diets.contains(self.name!) {
            self.listKey = "diets"
        } else {
            print("Error")
        }
        
        if let preference = defaults.object(forKey: self.listKey) as? [String] {
            if preference.contains(self.name!) {
                self.pressed = true
                self.backgroundColor = orange
                self.setTitleColor(UIColor.white, for: .normal)
            }
        } else {
            defaults.set([], forKey: self.listKey)
        }
        
        self.addTarget(self, action: #selector(updateButton), for: .touchUpInside)
    }
    
    @objc func updateButton() {
        
        self.pressed = !self.pressed
        
        if self.pressed {
            self.backgroundColor = orange
            self.setTitleColor(UIColor.white, for: .normal)
            
            if var preference = defaults.object(forKey: self.listKey) as? [String] {
                if !(preference.contains(self.name!)) {
                    preference.append(self.name!)
                    defaults.set(preference, forKey: self.listKey)
                }
            } else {
                defaults.set([], forKey: self.listKey)
            }
            
        } else {
            self.backgroundColor = UIColor.white
            self.setTitleColor(blue, for: .normal)
            
            if var preference = defaults.object(forKey: self.listKey) as? [String] {
                if (preference.contains(self.name!)) {
                    if let index = preference.firstIndex(of: self.name!) {
                        preference.remove(at: index)
                        defaults.set(preference, forKey: self.listKey)
                    }
                }
            } else {
                defaults.set([], forKey: self.listKey)
            }
            
        }
        
        //print("\(self.listKey): \(defaults.object(forKey: self.listKey) as? [String] ?? [])")
    }
}
