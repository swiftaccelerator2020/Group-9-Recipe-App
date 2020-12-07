//
//  RecipeSearchViewController.swift
//  Recipe App
//
//  Created by Lim Meng Shin on 28/11/20.
//

import UIKit

private let reuseIdentifier = "recipeCell"

class RecipeSearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    var recipes: [RecipesInfo]?
    var searchBarText: String = ""
    
    @IBOutlet weak var recipeSearchBar: UISearchBar!
    @IBOutlet weak var recipeCollectionView: UICollectionView!
    
    var previousDiets: [String] = []
    var previousIntolerences: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        savePreviousPreferences()
        
        recipeSearchBar.text = searchBarText
        searchRecipes(query: searchBarText) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let diets = defaults.object(forKey: "diets") as? [String] {
            if previousDiets != diets {
                savePreviousPreferences()
                recipes = nil
                recipeCollectionView.reloadData()
                searchRecipes(query: recipeSearchBar.text!) {
                    self.recipeCollectionView.reloadData()
                }
            }
        }
        
        if let intolerences = defaults.object(forKey: "intolerences") as? [String] {
            if previousIntolerences != intolerences {
                savePreviousPreferences()
                recipes = nil
                recipeCollectionView.reloadData()
                searchRecipes(query: recipeSearchBar.text!) {
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
            recipes = nil
            recipeCollectionView.reloadData()
            searchRecipes(query: recipeSearchBar.text!) {
                self.recipeCollectionView.reloadData()
            }
        }
    }
    
    
    func searchRecipes(query: String, completed: @escaping () -> ()) {

        let url = URL(string: getURL(query: query))
        
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
                            self.searchRecipes(query: query, completed: completed)
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
