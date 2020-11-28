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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        recipeSearchBar.text = searchBarText
        searchRecipes(query: searchBarText.replacingOccurrences(of: " ", with: "%20")) {
            self.recipeCollectionView.reloadData()
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return recipes?.count ?? 0
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
            searchRecipes(query: recipeSearchBar.text!.replacingOccurrences(of: " ", with: "%20")) {
                self.recipeCollectionView.reloadData()
            }
        }
    }
    
    
    func searchRecipes(query: String, completed: @escaping () -> ()) {
        
        var urlString = "https://api.spoonacular.com/recipes/complexSearch?apiKey=d7541b406f7e43d5a82c7755e35bf508&query=\(query)&addRecipeNutrition=true&sort=popularity&limitLicense=true&number=12"
        
        let diets = defaults.object(forKey: "diets") as? [String]
        let intolerences = defaults.object(forKey: "intolerences") as? [String]
        if diets!.count != 0 {
            let filter = diets?.joined(separator: ",").replacingOccurrences(of: " ", with: "%20")
            urlString += "&diet=\(filter!)"
        }
        if intolerences!.count != 0 {
            let filter = intolerences?.joined(separator: ",").replacingOccurrences(of: " ", with: "%20")
            urlString += "&intolerances=\(filter!)"
        }
        
        let url = URL(string: urlString)
        
        guard url != nil else { return }
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url!) { (data, response, error) in
            if error == nil && data != nil {
                do {
                    let jsonDecoder = JSONDecoder()
                    let data = try jsonDecoder.decode(Recipe.self, from: data!)
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
