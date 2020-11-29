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
        
        for view in [recipeImageView, recipeUIView] {
            view!.layer.shadowColor = UIColor.gray.cgColor
            view!.layer.shadowOpacity = 1
            view!.layer.shadowOffset = CGSize(width: 1, height: 1)
            view!.layer.cornerRadius = 15
            view!.clipsToBounds = false
        }
        
        
        self.recipeImageView.downloaded(from: recipes?.image ?? "https://i.stack.imgur.com/Vkq2a.png")
        if let recipes = recipes {
            if let title = recipes.title {
                self.title = title
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
