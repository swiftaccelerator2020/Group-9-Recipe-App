//
//  RecipeCollectionViewCell.swift
//  Recipe App
//
//  Created by Lim Meng Shin on 26/11/20.
//

import UIKit

class RecipeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var recipeLabel: UILabel!
    @IBOutlet weak var recipeImageView: UIImageView!
    
    override func layoutSubviews() {
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor.gray.cgColor
    }
    
    override func prepareForReuse() {
        recipeImageView.image = nil
    }
}
