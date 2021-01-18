//
//  RecipeStepDetailsViewController.swift
//  Recipe App
//
//  Created by Lim Meng Shin on 8/12/20.
//

import UIKit
import AVKit
import UserNotifications

class RecipeStepDetailsViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    var stepNumber: Int?
    var stepInstructions: String?
    var ingredients: [RecipeStepIngredients]?
    var equipment: [RecipeStepEquipment]?
    var hasTimer: Bool?
    var timerLength: Int?
    
    var seconds: Int = 60
    var timer = Timer()
    var isTimerRunning = false
    var resumeTapped = false
    
    var audioPlayer = AVAudioPlayer()
    let center = UNUserNotificationCenter.current()
    
    @IBOutlet weak var stepInstructionsLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var equipmentLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var equipmentTableView: UITableView!
    
    @IBOutlet weak var theTimerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    
    @IBOutlet weak var ingredientsLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var equipmentLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var ingredientsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var equipmentTableViewHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        center.delegate = self
        
        title = "Step \(stepNumber ?? 0)"
        
        stepInstructionsLabel.text = stepInstructions?.replacingOccurrences(of: ".", with: ". ").replacingOccurrences(of: "!", with: "! ").replacingOccurrences(of: ",", with: ", ").replacingOccurrences(of: "[\\s\n]+", with: " ", options: .regularExpression, range: nil)
        
        for tableView in [ingredientsTableView, equipmentTableView] {
            if let tableView = tableView {
                tableView.delegate = self
                tableView.dataSource = self
                
                tableView.rowHeight = UITableView.automaticDimension
                tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
            }
        }
        
        if ingredients?.count == 0 {
            self.ingredientsLabel.isHidden = true
            self.ingredientsTableViewHeightConstraint.constant = 0
            self.ingredientsLabelHeightConstraint.constant = 0
        } else if ingredients?.count == 1 {
            self.ingredientsLabel.text = "\(ingredients?.count ?? 1) Ingredient"
        } else {
            self.ingredientsLabel.text = "\(ingredients?.count ?? 2) Ingredients"
        }
        if equipment?.count == 0 {
            self.equipmentLabel.isHidden = true
            self.equipmentTableViewHeightConstraint.constant = 0
            self.equipmentLabelHeightConstraint.constant = 0
        } else {
            self.equipmentLabel.text = "\(equipment?.count ?? 3) Equipment"
        }
        
        pauseButton.isEnabled = false
        pauseButton.alpha = 0.7
        resetButton.isEnabled = false
        resetButton.alpha = 0.5
        
        if hasTimer == false {
            timerLabel.isHidden = true
            theTimerLabel.isHidden = true
            startButton.isHidden = true
            pauseButton.isHidden = true
            resetButton.isHidden = true
        } else {
            timerLabel.isHidden = false
            theTimerLabel.isHidden = false
            startButton.isHidden = false
            pauseButton.isHidden = false
            resetButton.isHidden = false
            seconds = timerLength! * 60
            theTimerLabel.text = timeString(time: TimeInterval(seconds))
        }
        
        let sound = Bundle.main.path(forResource: "timer", ofType: "mp3")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
        } catch {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let ingredients = ingredients {
            ingredientsTableViewHeightConstraint.constant = CGFloat(50 * ingredients.count)
        }
        if let equipment = equipment {
            equipmentTableViewHeightConstraint.constant = CGFloat(50 * equipment.count)
        }
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print(error)
            }
        }
        if isTimerRunning == false {
            runTimer()
            startButton.isEnabled = false
            startButton.alpha = 0.7
            resetButton.isEnabled = true
            resetButton.alpha = 1
        }
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
        if self.resumeTapped == false {
            timer.invalidate()
            self.resumeTapped = true
            self.pauseButton.setTitle("Resume",for: .normal)
        } else {
            runTimer()
            self.resumeTapped = false
            self.pauseButton.setTitle("Pause",for: .normal)
        }
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        timer.invalidate()
        seconds = timerLength! * 60
        theTimerLabel.text = timeString(time: TimeInterval(seconds))
        isTimerRunning = false
        pauseButton.setTitle("Pause", for: .normal)
        resumeTapped = false
        pauseButton.isEnabled = false
        pauseButton.alpha = 0.7
        startButton.isEnabled = true
        startButton.alpha = 1
        resetButton.isEnabled = false
        resetButton.alpha = 0.5
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(RecipeStepDetailsViewController.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
        pauseButton.isEnabled = true
        pauseButton.alpha = 1
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            
            timer.invalidate()
            pauseButton.isEnabled = false
            pauseButton.alpha = 0.7
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            audioPlayer.play()
            
            let alert = UIAlertController(title: "Time's up!", message: "You can proceed to the next step.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { (action: UIAlertAction) in
                self.audioPlayer.stop()
            }))
            self.present(alert, animated: true, completion: nil)

            center.getNotificationSettings { settings in
                guard (settings.authorizationStatus == .authorized) else { return }
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
                if settings.soundSetting == .enabled && settings.alertSetting == .enabled {
                    let content = UNMutableNotificationContent()
                    content.title = "Time's Up!"
                    content.body = "You can proceed to the next step."
                    content.sound = .defaultCritical
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(1), repeats: false)
                    let request = UNNotificationRequest(identifier: "timesUp", content: content, trigger: trigger)
                    self.center.add(request, withCompletionHandler: nil)
                } else {
                    let content = UNMutableNotificationContent()
                    content.title = "Time's Up!"
                    content.body = "You can proceed to the next step."
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(1), repeats: false)
                    let request = UNNotificationRequest(identifier: "timesUp", content: content, trigger: trigger)
                    self.center.add(request, withCompletionHandler: nil)
                }
            }
            

        } else {
            seconds -= 1
            theTimerLabel.text = timeString(time: TimeInterval(seconds))
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}

extension RecipeStepDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == ingredientsTableView {
            if let ingredients = ingredients {
                return ingredients.count
            }
            return 0
        } else if tableView == equipmentTableView {
            if let equipment = equipment {
                return equipment.count
            }
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == ingredientsTableView {
            if let ingredients = ingredients {
                let ingredient = ingredients[indexPath.row]
                let cell = ingredientsTableView.dequeueReusableCell(withIdentifier: "ingredientCell") as! IngredientTableViewCell
                cell.ingredientNameLabel.text = "\(ingredient.name ?? "")"
                cell.ingredientButton.addTarget(self, action: #selector(checkboxTapped(_ :)), for: .touchUpInside)
                return cell
            }
            return IngredientTableViewCell()
        } else if tableView == equipmentTableView {
            if let equipment = equipment {
                let equipment = equipment[indexPath.row]
                let cell = equipmentTableView.dequeueReusableCell(withIdentifier: "equipmentCell") as! EquipmentTableViewCell
                cell.equipmentNameLabel.text = "\(equipment.name ?? "")"
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
