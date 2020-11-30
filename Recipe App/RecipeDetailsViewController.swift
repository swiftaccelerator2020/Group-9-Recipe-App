//
//  RecipeDetailsViewController.swift
//  Recipe App
//
//  Created by Lim Meng Shin on 28/11/20.
//

import UIKit

class RecipeDetailsViewController: UIViewController {
    
    var recipes: RecipesInfo?
    
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeUIView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipeUIView.layer.shadowColor = UIColor.gray.cgColor
        recipeUIView.layer.shadowOpacity = 1
        recipeUIView.layer.shadowOffset = CGSize(width: 1, height: 1)
        recipeUIView.layer.cornerRadius = 15
        recipeUIView.clipsToBounds = false
        
        recipeImageView.layer.cornerRadius = 15
        recipeImageView.clipsToBounds = true
        
        
        self.recipeImageView.downloaded(from: recipes?.image ?? "https://i.stack.imgur.com/Vkq2a.png")
        if let recipes = recipes {
            if let title = recipes.title {
                self.title = title
            }
        }
    }
}
