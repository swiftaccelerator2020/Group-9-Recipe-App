//
//  RecipeIngredientsViewController.swift
//  Recipe App
//
//  Created by Lim Meng Shin on 4/12/20.
//

import UIKit

class IngredientTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ingredientNameLabel: UILabel!
    @IBOutlet weak var ingredientUnitLabel: UILabel!
    @IBOutlet weak var ingredientButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkboxTapped(_:))))
    }
    
    @objc func checkboxTapped(_ sender: UITapGestureRecognizer) {
        self.ingredientButton.isSelected = !self.ingredientButton.isSelected
    }
}

class EquipmentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var equipmentNameLabel: UILabel!
    @IBOutlet weak var equipmentButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkboxTapped(_:))))
    }
    
    @objc func checkboxTapped(_ sender: UITapGestureRecognizer) {
        self.equipmentButton.isSelected = !self.equipmentButton.isSelected
    }
}

class RecipeIngredientsViewController: UIViewController {
    
    var recipes: RecipesInfo?
    
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var equipmentTableView: UITableView!
    
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var equipmentLabel: UILabel!
    
    @IBOutlet weak var ingredientsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var equipmentTableViewHeightConstraint: NSLayoutConstraint!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Ingredients & Equipment"
        
        for tableView in [ingredientsTableView, equipmentTableView] {
            if let tableView = tableView {
                tableView.delegate = self
                tableView.dataSource = self
                
                tableView.rowHeight = UITableView.automaticDimension
                tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
            }
        }
        
        if let recipes = recipes {
            if let nutrition = recipes.nutrition {
                if let ingredients = nutrition.ingredients {
                    if ingredients.count == 1 {
                        self.ingredientsLabel.text = "\(ingredients.count) Ingredient"
                    } else {
                        self.ingredientsLabel.text = "\(ingredients.count) Ingredients"
                    }
                }
            }
            self.equipmentLabel.text = "\(recipes.equipments.count) Equipment"
        }
    }
    
    @IBAction func cookButtonPressed(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "RecipeStepsViewController") as? RecipeStepsViewController
        vc?.recipes = recipes
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let recipes = recipes, let nutrition = recipes.nutrition, let ingredients = nutrition.ingredients {
            ingredientsTableViewHeightConstraint.constant = CGFloat(60 * ingredients.count)
        }
        if let recipes = recipes {
            let equipment = recipes.equipments
            equipmentTableViewHeightConstraint.constant = CGFloat(50 * equipment.count)
        }
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension RecipeIngredientsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == ingredientsTableView {
            if let recipes = recipes, let nutrition = recipes.nutrition, let ingredients = nutrition.ingredients {
                return ingredients.count
            }
            return 0
        } else if tableView == equipmentTableView {
            if let recipes = recipes {
                let equipment = recipes.equipments
                return equipment.count
            }
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == ingredientsTableView {
            if let recipes = recipes, let nutrition = recipes.nutrition, let ingredients = nutrition.ingredients {
                let ingredient = ingredients[indexPath.row]
                let cell = ingredientsTableView.dequeueReusableCell(withIdentifier: "ingredientCell") as! IngredientTableViewCell
                cell.ingredientNameLabel.text = "\(ingredient.name?.capitalizingFirstLetter() ?? "")"
                cell.ingredientUnitLabel.text = "\(ingredient.amount ?? 0.0) \(ingredient.unit ?? "")"
                cell.ingredientButton.addTarget(self, action: #selector(checkboxTapped(_ :)), for: .touchUpInside)
                return cell
            }
            return IngredientTableViewCell()
        } else if tableView == equipmentTableView {
            if let recipes = recipes {
                let equipment = recipes.equipments[indexPath.row]
                let cell = equipmentTableView.dequeueReusableCell(withIdentifier: "equipmentCell") as! EquipmentTableViewCell
                cell.equipmentNameLabel.text = "\(equipment.name?.capitalizingFirstLetter() ?? "")"
                cell.equipmentButton.addTarget(self, action: #selector(checkboxTapped(_ :)), for: .touchUpInside)
                return cell
            }
            return EquipmentTableViewCell()
        }
        return UITableViewCell()
    }
    
    @objc func checkboxTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
}
