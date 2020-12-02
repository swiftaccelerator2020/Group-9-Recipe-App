//
//  RecipeDetailsViewController.swift
//  Recipe App
//
//  Created by Lim Meng Shin on 28/11/20.
//

import UIKit

class StepTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var stepNumberLabel: UILabel!
    @IBOutlet weak var stepInstructionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView.layer.shadowColor = UIColor.gray.cgColor
        cellView.layer.shadowOpacity = 1
        cellView.layer.shadowOffset = CGSize(width: 1, height: 1)
        cellView.layer.cornerRadius = 15
        cellView.clipsToBounds = false
    }
}

class IngredientTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ingredientNameLabel: UILabel!
    @IBOutlet weak var ingredientUnitLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
}

class NutritionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nutritionNameLabel: UILabel!
    @IBOutlet weak var nutritionUnitLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class RecipeDetailsViewController: UIViewController {
    
    var recipes: RecipesInfo?
    
    @IBOutlet weak var stepsTableView: UITableView!
    @IBOutlet weak var nutritionTableView: UITableView!
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeUIView: UIView!
    
    @IBOutlet weak var likesUIView: UIView!
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var servingsLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for tableview in [ingredientsTableView, nutritionTableView, stepsTableView] {
            if let tableview = tableview {
                tableview.delegate = self
                tableview.dataSource = self
            }
        }
        
        for uiview in [recipeUIView] {
            if let uiview = uiview {
                uiview.layer.shadowColor = UIColor.gray.cgColor
                uiview.layer.shadowOpacity = 1
                uiview.layer.shadowOffset = CGSize(width: 1, height: 1)
                uiview.layer.cornerRadius = 15
                uiview.clipsToBounds = false
            }
        }
        
        recipeImageView.layer.cornerRadius = 15
        recipeImageView.clipsToBounds = true
        
        
        self.recipeImageView.downloaded(from: recipes?.image ?? "https://i.stack.imgur.com/Vkq2a.png")
        
        if let recipes = recipes {
            if let title = recipes.title {
                self.title = title
            }
            if let likes = recipes.aggregateLikes {
                self.likesLabel.text = formatLikesNumber(likes)
            }
            if let time = recipes.readyInMinutes {
                self.timeLabel.text = "\(time) min"
            }
            if let servings = recipes.servings {
                self.servingsLabel.text = "\(servings) servings"
            }
            if let nutrition = recipes.nutrition {
                if let ingredients = nutrition.ingredients {
                    self.ingredientsLabel.text = "\(ingredients.count) Ingredients"
                }
            }
            if let analyzedInstructions = recipes.analyzedInstructions, let steps = analyzedInstructions[0].steps {
                self.stepsLabel.text = "\(steps.count) Steps"
            }
        }
    }
    
    func formatLikesNumber(_ n: Int) -> String {
        let num = abs(Double(n))
        let sign = (n < 0) ? "-" : ""

        switch num {
        case 1_000_000_000...:
            var formatted = num / 1_000_000_000
            formatted = formatted.reduceScale(to: 1)
            return "\(sign)\(formatted)B"

        case 1_000_000...:
            var formatted = num / 1_000_000
            formatted = formatted.reduceScale(to: 1)
            return "\(sign)\(formatted)M"

        case 1_000...:
            var formatted = num / 1_000
            formatted = formatted.reduceScale(to: 1)
            return "\(sign)\(formatted)K"

        case 0...:
            return "\(n)"

        default:
            return "\(sign)\(n)"
        }
    }
}

extension Double {
    func reduceScale(to places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        let newDecimal = multiplier * self
        let truncated = Double(Int(newDecimal))
        let originalDecimal = truncated / multiplier
        return originalDecimal
    }
}

extension RecipeDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == ingredientsTableView {
            if let recipes = recipes, let nutrition = recipes.nutrition, let ingredients = nutrition.ingredients {
                return ingredients.count
            }
            return 0
        } else if tableView == nutritionTableView {
            if let recipes = recipes {
                let nutrition = recipes.caloriesCarbFatsProteins
                return nutrition.count
            }
            return 0
        } else if tableView == stepsTableView {
            if let recipes = recipes, let analyzedInstructions = recipes.analyzedInstructions, let steps = analyzedInstructions[0].steps {
                return steps.count
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
                cell.ingredientNameLabel.text = "\(ingredient.name ?? "")"
                cell.ingredientUnitLabel.text = "\(ingredient.amount ?? 0.0) \(ingredient.unit ?? "")"
                return cell
            }
            return IngredientTableViewCell()
        } else if tableView == nutritionTableView {
            if let recipes = recipes {
                let nutrition = recipes.caloriesCarbFatsProteins[indexPath.row]
                let cell = nutritionTableView.dequeueReusableCell(withIdentifier: "nutritionCell") as! NutritionTableViewCell
                cell.nutritionNameLabel.text = "\(nutrition.title ?? "")"
                cell.nutritionUnitLabel.text = "\(nutrition.amount ?? 0) \(nutrition.unit ?? "")"
                return cell
            }
            return NutritionTableViewCell()
        } else if tableView == stepsTableView {
            if let recipes = recipes, let analyzedInstructions = recipes.analyzedInstructions, let steps = analyzedInstructions[0].steps {
                let step = steps[indexPath.row]
                let cell = stepsTableView.dequeueReusableCell(withIdentifier: "stepCell") as! StepTableViewCell
                cell.stepNumberLabel.text = "Step \(indexPath.row + 1)"
                cell.stepInstructionLabel.text = "\(step.step ?? "")"
                return cell
            }
            return StepTableViewCell()
        }
        return UITableViewCell()
    }
}
