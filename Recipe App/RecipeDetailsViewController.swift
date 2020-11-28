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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recipeImageView.downloaded(from: recipes?.image ?? "https://i.stack.imgur.com/Vkq2a.png")
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
