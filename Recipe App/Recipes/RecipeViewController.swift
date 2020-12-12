//
//  RecipeViewController.swift
//  Recipe App
//
//  Created by Lim Meng Shin on 25/11/20.
//

import UIKit

private let reuseIdentifier = "recipeCell"

class TabViewController: UITabBarController {
    
    @IBAction func backToEntry(with segue: UIStoryboardSegue) {
        //just for unwind segue; no func
    }
}

class RecipeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    var recipes: [RecipesInfo]?
    
    @IBOutlet weak var recipeSearchBar: UISearchBar!
    @IBOutlet weak var recipeCollectionView: UICollectionView!
    
    var previousDiets: [String] = []
    var previousIntolerences: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        
        if let isNewUser = defaults.object(forKey: "isNewUser") as? Bool {
            if isNewUser {
                perform(#selector(presentGetStartedViewController), with: nil, afterDelay: 0)
            }
        } else {
            defaults.set(true, forKey: "isNewUser")
            perform(#selector(presentGetStartedViewController), with: nil, afterDelay: 0)
        }
        
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        savePreviousPreferences()
        
        getRecipes {
            self.recipeCollectionView.reloadData()
        }
        
    }
    
    func savePreviousPreferences() {
        if let diets = defaults.object(forKey: "diets") as? [String] {
            previousDiets = diets
        } else {
            previousDiets = []
            defaults.set([], forKey: "diets")
        }
        if let intolerences = defaults.object(forKey: "intolerences") as? [String] {
            previousIntolerences = intolerences
        } else {
            previousIntolerences = []
            defaults.set([], forKey: "intolerences")
        }
    }
    
    @objc private func presentGetStartedViewController() {
        let vc = storyboard?.instantiateViewController(identifier: "getStarted") as! GetStartedViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recipeSearchBar.text = nil
        
        if let diets = defaults.object(forKey: "diets") as? [String] {
            if previousDiets != diets {
                savePreviousPreferences()
                recipes = nil
                recipeCollectionView.reloadData()
                getRecipes {
                    self.recipeCollectionView.reloadData()
                }
            }
        }
        
        if let intolerences = defaults.object(forKey: "intolerences") as? [String] {
            if previousIntolerences != intolerences {
                savePreviousPreferences()
                recipes = nil
                recipeCollectionView.reloadData()
                getRecipes {
                    self.recipeCollectionView.reloadData()
                }
            }
        }

    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if let recipes = recipes {
            if recipes.count == 0 {
                self.recipeCollectionView.setEmptyMessage("No results found. Try searching something.")
            } else {
                self.recipeCollectionView.restore()
            }
            return recipes.count
        } else {
            self.recipeCollectionView.setEmptyMessage("Loading...")
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RecipeCollectionViewCell
        
        // Configure the cell
        cell.recipeLabel.textColor = blue
        cell.recipeLabel.text = recipes?[indexPath.row].title
        cell.recipeImageView.downloaded(from: (recipes?[indexPath.row].image ?? "https://i.stack.imgur.com/Vkq2a.png"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "RecipeDetailsViewController") as? RecipeDetailsViewController
        vc?.recipes = recipes?[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if (!(recipeSearchBar.text?.isEmpty)!) {
            recipeSearchBar.resignFirstResponder()
            guard let searchBarText = recipeSearchBar.text else { return }
            let vc = storyboard?.instantiateViewController(identifier: "RecipeSearchViewController") as? RecipeSearchViewController
            vc?.searchBarText = searchBarText
            self.navigationController?.pushViewController(vc!, animated: false)
        }
    }
    
    
    func getRecipes(completed: @escaping () -> ()) {
        
        let url = URL(string: getURL(query: nil))
        
        guard url != nil else { return }
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url!) { (data, response, error) in
            if error == nil && data != nil {
                do {
                    let jsonDecoder = JSONDecoder()
                    let data = try jsonDecoder.decode(Recipe.self, from: data!)
                    guard data.results != nil else {
                        let defaults = UserDefaults.standard
                        if let tries = (defaults.object(forKey: "connectionTries") as? Int) {
                            let newTries = tries + 1
                            if newTries == apiKeys.count {
                                let alert = UIAlertController(title: "AppError", message: "The app has run out of Recipe API requests. Wait until tomorrow, sorry for the inconvenience.", preferredStyle: .alert)
                                let action = UIAlertAction(title: "Close App", style: .default, handler: { _ in
                                    UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
                                })
                                alert.addAction(action)
                                return
                            } else {
                                defaults.set(newTries, forKey: "connectionTries")
                            }
                        } else {
                            defaults.set(1, forKey: "connectionTries")
                        }
                        if let index = defaults.object(forKey: "apiKeyIndex") as? Int {
                            let newIndex = index + 1
                            if newIndex > (apiKeys.count-1) {
                                defaults.set(0, forKey: "apiKeyIndex")
                            } else {
                                defaults.set(newIndex, forKey: "apiKeyIndex")
                            }
                            self.getRecipes(completed: completed)
                            return
                        }
                        return
                    }

                    self.recipes = data.results
                    for recipe in self.recipes! {
                        if let analyzedInstructions = recipe.analyzedInstructions {
                            if analyzedInstructions.count == 0 {
                                if let index = self.recipes!.firstIndex(of: recipe) {
                                    self.recipes!.remove(at: index)
                                }
                            } else {
                                if let steps = analyzedInstructions[0].steps {
                                    for step in steps {
                                        if let instructions = step.step {
                                            let words = instructions.lowercased().split(separator: " ")
                                            if words.contains("subscribe") || words.contains("email") {
                                                if let index = self.recipes!.firstIndex(of: recipe) {
                                                    self.recipes!.remove(at: index)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    let defaults = UserDefaults.standard
                    defaults.set(0, forKey: "connectionTries")
                    
                    DispatchQueue.main.async {
                        completed()
                    }
                    
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        dataTask.resume()
    }
}

func getURL(query: String?) -> String {
    
    let defaults = UserDefaults.standard
    var apiKey: String?
    if let index = defaults.object(forKey: "apiKeyIndex") as? Int {
        apiKey = apiKeys[index]
    } else {
        defaults.set(0, forKey: "apiKeyIndex")
        apiKey = apiKeys[0]
    }
    var urlString: String?
    if query != nil {
        urlString = "https://api.spoonacular.com/recipes/complexSearch?apiKey=\(apiKey!)&query=\(query!.replacingOccurrences(of: " ", with: "%20"))&addRecipeNutrition=true&sort=popularity&limitLicense=true&number=20"
    } else {
        urlString = "https://api.spoonacular.com/recipes/complexSearch?apiKey=\(apiKey!)&addRecipeNutrition=true&limitLicense=true&number=20"
        let hour = Calendar.current.component(.hour, from: Date())
        if hour > 5 && hour < 12 {
            urlString! += "&type=breakfast,bread,"
        } else if hour > 11 && hour < 17 {
            urlString! += "&type=main course,appetizer".replacingOccurrences(of: " ", with: "%20")
        } else if hour > 16 && hour < 24 {
            urlString! += "&type=salad,side dish,dessert".replacingOccurrences(of: " ", with: "%20")
        } else if hour > 0 && hour < 6 {
            urlString! += "&type=snack,fingerfood"
        }
        
        let sortingOptions = ["", "meta-score", "popularity", "healthiness", "random"]
        urlString! += "&sort=\(sortingOptions.randomElement() ?? "popularity")"
    }
    
    
    if let diets = defaults.object(forKey: "diets") as? [String] {
        if diets.count != 0 {
            let filter = diets.joined(separator: ",").replacingOccurrences(of: " ", with: "%20")
            urlString! += "&diet=\(filter)"
        }
    }
    if let intolerences = defaults.object(forKey: "intolerences") as? [String] {
        if intolerences.count != 0 {
            let filter = intolerences.joined(separator: ",").replacingOccurrences(of: " ", with: "%20")
            urlString! += "&intolerances=\(filter)"
        }
    }
    
    return urlString!
    
}

extension UIImageView {
    func downloaded(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url)
    }
}

extension UICollectionView {
    func setEmptyMessage(_ message: String) {
        let msgLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        msgLabel.text = message
        msgLabel.textAlignment = .center
        msgLabel.font = UIFont(name: "System", size: 20)
        msgLabel.sizeToFit()
        
        self.backgroundView = msgLabel
    }
    
    func restore() {
        self.backgroundView = nil
    }
}
