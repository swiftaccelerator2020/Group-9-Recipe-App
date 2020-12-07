//
//  FinishRecipeViewController.swift
//  Recipe App
//
//  Created by Johansan on 5/12/20.
//

import UIKit
import HealthKit

class FinishRecipeViewController: UIViewController {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var recipeLabel: UILabel!
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var fatsLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    
    let healthStore = HKHealthStore()
    let caloriesType = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)
    let fatsType = HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)
    let carbsType = HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)
    let proteinType = HKObjectType.quantityType(forIdentifier: .dietaryProtein)
    
    var recipes: RecipesInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardView.layer.shadowColor = UIColor.gray.cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset = CGSize(width: 1, height: 1)
        cardView.layer.cornerRadius = 15
        cardView.clipsToBounds = false
        
        recipeImage.layer.cornerRadius = 15
        recipeImage.clipsToBounds = true
        
        
        
        if let recipes = recipes {
            if let title = recipes.title {
                recipeLabel.text = title
            }
            if let image = recipes.image {
                recipeImage.downloaded(from: image)
            }
            for nutrient in recipes.caloriesCarbFatsProteins {
                var label: UILabel?
                switch nutrient.title {
                case "Calories":
                    label = caloriesLabel
                case "Fat":
                    label = fatsLabel
                case "Carbohydrates":
                    label = carbsLabel
                case "Protein":
                    label = proteinLabel
                default:
                    label = UILabel()
                }
                label?.text = "\(nutrient.amount ?? 0) \(nutrient.unit ?? "")"
            }
        }
        // Do any additional setup after loading the view.
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
