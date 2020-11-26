//
//  UIPreferenceButton.swift
//  Recipe App
//
//  Created by Lim Meng Shin on 25/11/20.
//

import UIKit

class UIPreferenceButton: UIButton {
    var pressed = false
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 10
        
        self.backgroundColor = UIColor.white
        self.setTitleColor(UIColor.black, for: .normal)
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowOpacity = 1
        self.layer.masksToBounds = false
        
        self.addTarget(self, action: #selector(onPress), for: .touchUpInside)
    }
    
    @objc func onPress() {
        if self.pressed {
            self.backgroundColor = UIColor.white
            self.setTitleColor(UIColor.black, for: .normal)
        } else {
            self.backgroundColor = UIColor.systemOrange
            self.setTitleColor(UIColor.white, for: .normal)
        }
        self.pressed = !self.pressed
    }
}
