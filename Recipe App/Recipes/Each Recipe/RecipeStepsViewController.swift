//
//  RecipeStepsViewController.swift
//  Recipe App
//
//  Created by Johansan on 5/12/20.
//

import UIKit

class StepsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var timerImage: UIImageView!
    //@IBOutlet weak var checkmarkButton: UIButton!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        timerImage.tintColor = blue
        cellView.layer.shadowColor = UIColor.gray.cgColor
        cellView.layer.shadowOpacity = 1
        cellView.layer.shadowOffset = CGSize(width: 1, height: 1)
        cellView.layer.cornerRadius = 15
        cellView.clipsToBounds = false
        cellView.backgroundColor = blue
    }
    
    func update(steps: [RecipeSteps]?) {
        var index: Int = Int(self.stepLabel.text!.replacingOccurrences(of: "Step ", with: ""))!
        index -= 1
        if let steps = steps {
            let step = steps[index]
            if let length = step.length {
                if let number = length.number {
                    self.timerImage.tintColor = .white
                }
            } else {
                self.timerImage.tintColor = blue
            }
        }
    }
}

class RecipeStepsViewController: UIViewController {
    
    var recipes: RecipesInfo?
    var stepsChecklist: [Bool] = []
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var stepsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Steps"
        
        for tableView in [stepsTableView] {
            if let tableView = tableView {
                tableView.delegate = self
                tableView.dataSource = self
                
                tableView.rowHeight = UITableView.automaticDimension
                tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let recipes = recipes, let analyzedInstructions = recipes.analyzedInstructions, let steps = analyzedInstructions[0].steps {
            for _ in 1...steps.count {
                stepsChecklist.append(false)
            }
        }
    }
    @IBAction func finishButtonPressed(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "FinishRecipeViewController") as? FinishRecipeViewController
        vc?.recipes = recipes
        self.present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func backToStepsViewController(with segue: UIStoryboardSegue) {
        if segue.identifier == "closeOutOfFinish" {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}

extension RecipeStepsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == stepsTableView {
            if let recipes = recipes, let analyzedInstructions = recipes.analyzedInstructions, let steps = analyzedInstructions[0].steps {

                return steps.count
            }
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == stepsTableView {
            if let recipes = recipes, let analyzedInstructions = recipes.analyzedInstructions, let steps = analyzedInstructions[0].steps {
                let step = steps[indexPath.row]
                let cell = stepsTableView.dequeueReusableCell(withIdentifier: "stepsCell") as! StepsTableViewCell
                cell.stepLabel.text = "Step \(indexPath.row + 1)"

                if let instructions = step.step {
                    cell.instructionsLabel.text = instructions.replacingOccurrences(of: ".", with: ". ").replacingOccurrences(of: "!", with: "! ").replacingOccurrences(of: ",", with: ", ").replacingOccurrences(of: "[\\s\n]+", with: " ", options: .regularExpression, range: nil)
                }
//                cell.checkmarkButton.tag = indexPath.row
//                cell.checkmarkButton.isSelected = stepsChecklist[indexPath.row]
//                cell.checkmarkButton.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
                cell.update(steps: steps)
                return cell
            }
            return StepsTableViewCell()
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "RecipeStepDetailsViewController") as? RecipeStepDetailsViewController
        var hasTimer: Bool?
        var timerLength: Int?
        if let recipes = recipes, let analyzedInstructions = recipes.analyzedInstructions, let steps = analyzedInstructions[0].steps {
            let step = steps[indexPath.row]
            if let _ = step.length {
                timerLength = step.length?.number
                hasTimer = true
            } else {
                hasTimer = false
                timerLength = step.length?.number
            }
        }
        vc?.hasTimer = hasTimer
        vc?.timerLength = timerLength
        vc?.stepNumber = indexPath.row + 1
        vc?.stepInstructions = recipes?.analyzedInstructions?[0].steps?[indexPath.row].step
        vc?.ingredients =  recipes?.analyzedInstructions?[0].steps?[indexPath.row].ingredients
        vc?.equipment = recipes?.analyzedInstructions?[0].steps?[indexPath.row].equipment
        self.present(vc!, animated: true, completion: nil)
    }
    
//    @objc func checkboxTapped(_ sender: UIButton) {
//        sender.isSelected = !sender.isSelected
//        stepsChecklist[sender.tag] = sender.isSelected
//        checkStepsCompletion()
//    }
//
//    func checkStepsCompletion() {
//        if stepsChecklist.contains(false) {
//            noticeLabel.isHidden = false
//            finishButton.isHidden = true
//            finishButton.isEnabled = false
//        } else {
//            noticeLabel.isHidden = true
//            finishButton.isEnabled = true
//            finishButton.isHidden = false
//        }
//    }
    
    
}
