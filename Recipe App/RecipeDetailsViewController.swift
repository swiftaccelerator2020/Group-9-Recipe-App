//
//  RecipeDetailsViewController.swift
//  Recipe App
//
//  Created by Lim Meng Shin on 28/11/20.
//

import TTGTagCollectionView
import UIKit

class RecipeDetailsViewController: UIViewController {
    
    var recipes: RecipesInfo?
    
    @IBOutlet weak var cuisinesTagLabel: UILabel!
    @IBOutlet weak var dietsTagLabel: UILabel!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeUIView: UIView!
    @IBOutlet weak var dietsTagCollectionUIView: UIView!
    @IBOutlet weak var cuisinesTagCollectionUIView: UIView!
    
    let dietsTagCollectionView = TTGTextTagCollectionView()
    let cuisinesTagCollectionView = TTGTextTagCollectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let recipes = recipes {
            if var diets = recipes.diets {
                diets = diets.map({$0.capitalized})
                if diets.count == 0 {
                    dietsTagCollectionUIView.isHidden = true
                    dietsTagLabel.isHidden = true
                } else {
                    dietsTagLabel.isHidden = false
                    dietsTagCollectionUIView.isHidden = false
                    dietsTagCollectionView.alignment = .left
                    dietsTagCollectionView.delegate = self
                    dietsTagCollectionView.enableTagSelection = false
                    
                    dietsTagCollectionUIView.addSubview(dietsTagCollectionView)
                    
                    let config = TTGTextTagConfig()
                    config.backgroundColor = orange
                    config.textColor = .white
                    
                    dietsTagCollectionView.addTags(diets, with: config)
                }
            }
            if var cuisines = recipes.cuisines {
                cuisines = cuisines.map({$0.capitalized})
                if cuisines.count == 0 {
                    cuisinesTagLabel.isHidden = true
                    cuisinesTagCollectionUIView.isHidden = true
                } else {
                    cuisinesTagLabel.isHidden = false
                    cuisinesTagCollectionUIView.isHidden = false
                    cuisinesTagCollectionView.alignment = .left
                    cuisinesTagCollectionView.delegate = self
                    cuisinesTagCollectionView.enableTagSelection = false
                    
                    cuisinesTagCollectionUIView.addSubview(cuisinesTagCollectionView)
                    
                    let config = TTGTextTagConfig()
                    config.backgroundColor = orange
                    config.textColor = .white
                    
                    cuisinesTagCollectionView.addTags(cuisines, with: config)
                }
            }
        }
        
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dietsTagCollectionView.frame = CGRect(x:0, y:0, width: dietsTagCollectionUIView.frame.size.width, height: dietsTagCollectionUIView.frame.size.height)
        cuisinesTagCollectionView.frame = CGRect(x:0, y:0, width: cuisinesTagCollectionUIView.frame.size.width, height: cuisinesTagCollectionUIView.frame.size.height)
    }
}

extension RecipeDetailsViewController: TTGTextTagCollectionViewDelegate {
    
}
