//
//  RecipeSearchViewController.swift
//  Recipe App
//
//  Created by Lim Meng Shin on 28/11/20.
//

import UIKit

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

let apiKeys = [
    "d7541b406f7e43d5a82c7755e35bf508",
    "0404847ae765463abf4f329add9c3f04",
    "db676e137b8a425c8a670e3b268d2f81",
    "fb4f7b804e6b4aff854fad632c57169b",
    "0a87a598474744d9998db8d7583442a0"
]

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
        urlString = "https://api.spoonacular.com/recipes/complexSearch?apiKey=\(apiKey!)&query=\(query!)&addRecipeNutrition=true&sort=popularity&limitLicense=true&number=12"
    } else {
        urlString = "https://api.spoonacular.com/recipes/complexSearch?apiKey=\(apiKey!)&addRecipeNutrition=true&sort=popularity&limitLicense=true&number=12"
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

private let reuseIdentifier = "recipeCell"

class RecipeSearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    var recipes: [RecipesInfo]?
    var searchBarText: String = ""
    
    @IBOutlet weak var recipeSearchBar: UISearchBar!
    @IBOutlet weak var recipeCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        recipeSearchBar.text = searchBarText
        searchRecipes(query: searchBarText.replacingOccurrences(of: " ", with: "%20")) {
            self.recipeCollectionView.reloadData()
        }

        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
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
            searchRecipes(query: recipeSearchBar.text!.replacingOccurrences(of: " ", with: "%20")) {
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
