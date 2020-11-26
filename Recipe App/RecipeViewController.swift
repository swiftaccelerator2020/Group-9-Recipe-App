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

class RecipeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var recipes: [RecipesInfo]?
    
    @IBOutlet weak var recipeSearchBar: UISearchBar!
    @IBOutlet weak var recipeCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getRecipes {
            self.recipeCollectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recipeSearchBar.text = nil
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
        cell.recipeLabel.text = recipes?[indexPath.row].title
        cell.recipeImageView.downloaded(from: (recipes?[indexPath.row].image ?? "https://i.stack.imgur.com/Vkq2a.png"))
        
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let vc = storyboard?.instantiateViewController(identifier: "RecipeDetailsViewController") as? RecipeDetailsViewController
//        vc?.recipes = recipes?[indexPath.row]
//        self.navigationController?.pushViewController(vc!, animated: true)
//    }
    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        if (!(recipeSearchBar.text?.isEmpty)!) {
//            guard let searchBarText = recipeSearchBar.text else { return }
//            let vc = storyboard?.instantiateViewController(identifier: "RecipeSearchViewController") as? RecipeSearchViewController
//            vc?.searchBarText = searchBarText
//            self.navigationController?.pushViewController(vc!, animated: false)
//        }
//    }
    
    
    func getRecipes(completed: @escaping () -> ()) {
        
        let urlString = "https://api.spoonacular.com/recipes/complexSearch?apiKey=038e058ad133420196ef21f8c2dbe3d5&addRecipeNutrition=true&sort=popularity&limitLicense=true&number=12"
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
