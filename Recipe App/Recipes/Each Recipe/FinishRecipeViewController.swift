//
//  FinishRecipeViewController.swift
//  Recipe App
//
//  Created by Johansan on 5/12/20.
//

import UIKit
import HealthKit

class FinishRecipeViewController: UIViewController {
    
    var recipes: RecipesInfo?
    
    let healthStore = HKHealthStore()
    let caloriesType = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)
    let fatsType = HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)
    let carbsType = HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)
    let proteinType = HKObjectType.quantityType(forIdentifier: .dietaryProtein)
    
    @IBOutlet weak var recipeLabel: UILabel!
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var nutritionTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for tableView in [nutritionTableView] {
            if let tableView = tableView {
                tableView.delegate = self
                tableView.dataSource = self
                
                tableView.rowHeight = UITableView.automaticDimension
                tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
            }
        }
        
        if let recipes = recipes {
            if let title = recipes.title {
                recipeLabel.text = title
            }
            if let image = recipes.image {
                recipeImage.downloaded(from: image)
            }
        }
    }


    @IBAction func yesButtonPressed(_ sender: Any) {
        
        if HKHealthStore.isHealthDataAvailable() {
            
            let allTypes = Set([caloriesType!, fatsType!, carbsType!, proteinType!])
            healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
                if !success {
                    print("authorisation failed")
                }
            }
            
            if let recipes = recipes {
                for nutrient in recipes.caloriesCarbFatsProteins {
                    var unit: HKUnit?
                    var type: HKObjectType?
                    switch nutrient.title {
                    case "Carbohydrates":
                        unit = HKUnit.gram()
                        type = carbsType
                    case "Fat":
                        unit = HKUnit.gram()
                        type = fatsType
                    case "Protein":
                        unit = HKUnit.gram()
                        type = proteinType
                    case "Calories":
                        unit = HKUnit.kilocalorie()
                        type = caloriesType
                    default:
                        unit = HKUnit.foot()
                        type = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
                    }
                    
                    let nutrientQuantity = HKQuantity(unit: unit!, doubleValue: nutrient.amount!)
                    let nutrientSample = HKQuantitySample(type: type! as! HKQuantityType, quantity: nutrientQuantity, start: Date(), end: Date())
                    
                    healthStore.save(nutrientSample) {
                        (success, error) in if let error = error {
                            print("\n\n\n\(error)\n\n\n")
                        } else {
                            print("success")
                        }
                    }
                }
                performSegue(withIdentifier: "closeOutOfFinish", sender: nil)
            }
        } else {
            performSegue(withIdentifier: "closeOutOfFinish", sender: nil)
        }
    }
}

extension FinishRecipeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == nutritionTableView {
            if let recipes = recipes {
                let nutrition = recipes.caloriesCarbFatsProteins
                return nutrition.count
            }
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == nutritionTableView {
            if let recipes = recipes {
                let nutrition = recipes.caloriesCarbFatsProteins[indexPath.row]
                let cell = nutritionTableView.dequeueReusableCell(withIdentifier: "nutritionCell") as! OverviewNutritionTableViewCell
                cell.nutritionNameLabel.text = "\(nutrition.title?.capitalizingFirstLetter() ?? "")"
                cell.nutritionUnitLabel.text = "\(nutrition.amount ?? 0) \(nutrition.unit ?? "")"
                return cell
            }
            return OverviewNutritionTableViewCell()
        }
        return UITableViewCell()
    }
}
