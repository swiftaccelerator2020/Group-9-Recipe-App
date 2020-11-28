//
//  RecipeViewController.swift
//  Recipe App
//
//  Created by Lim Meng Shin on 25/11/20.
//

import UIKit

private let reuseIdentifier = "recipeCell"

struct Recipe: Decodable {
    let results: [RecipesInfo]?
}

struct RecipesInfo: Decodable {
    let title: String?
    let image: String?
    let id: Int?
    let readyInMinutes: Int?
    let aggregateLikes: Int?
    let summary: String?
    let analyzedInstructions: [RecipeInstructions]?
}

struct RecipeInstructions: Decodable {
    let steps: [RecipeSteps]?
}

struct RecipeSteps: Decodable {
    let step: String?
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
                getRecipes {
                    self.recipeCollectionView.reloadData()
                }
            }
        }
        
        if let intolerences = defaults.object(forKey: "intolerences") as? [String] {
            if previousIntolerences != intolerences {
                savePreviousPreferences()
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
                self.recipeCollectionView.setEmptyMessage("No results found")
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
        
        var urlString = "https://api.spoonacular.com/recipes/complexSearch?apiKey=d7541b406f7e43d5a82c7755e35bf508&addRecipeNutrition=true&sort=popularity&limitLicense=true&number=12"
        
        if let diets = defaults.object(forKey: "diets") as? [String] {
            if diets.count != 0 {
                let filter = diets.joined(separator: ",").replacingOccurrences(of: " ", with: "%20")
                urlString += "&diet=\(filter)"
            }
        }
        if let intolerences = defaults.object(forKey: "intolerences") as? [String] {
            if intolerences.count != 0 {
                let filter = intolerences.joined(separator: ",").replacingOccurrences(of: " ", with: "%20")
                urlString += "&intolerances=\(filter)"
            }
        }
        
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
