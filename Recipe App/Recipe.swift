//
//  Recipe.swift
//  Recipe App
//
//  Created by Lim Meng Shin on 29/11/20.
//

struct Recipe: Decodable {
    let results: [RecipesInfo]?
}

struct RecipesInfo: Decodable {
    let title: String?
    let image: String?
    let id: Int?
    let readyInMinutes: Int?
    let servings: Int?
    let aggregateLikes: Int?
    let sourceName: String?
    let sourceUrl: String?
    let summary: String?
    let nutrition: [RecipeNutrition]?
    let analyzedInstructions: [RecipeInstructions]?
    
//    var equipments: [RecipeStepEquipment] {
//      var equipmentsArray: [RecipeStepEquipment] = []
//      if let analyzedInstructions = analyzedInstructions {
//        for analyzedInstruction in analyzedInstructions {
//          if let steps = analyzedInstruction.steps {
//            for step in steps {
//              if let equipment = step.equipment {
//                equipmentsArray += equipment
//              }
//            }
//          }
//        }
//      }
//      return equipmentsArray.unique()
//    }

}

// Nutrition and Ingredients
struct RecipeNutrition: Decodable {
    let nutrients: [RecipeNutrients]?
    let ingredients: [RecipeIngredients]?
}

struct RecipeNutrients: Decodable {
    let title: String?
    let amount: Double?
    let unit: String?
    let percentOfDailyNeeds: Double?
}

struct RecipeIngredients: Decodable {
    let name: String?
    let amount: Double?
    let unit: String?
}

// Instructions
struct RecipeInstructions: Decodable {
    let steps: [RecipeSteps]?
}

struct RecipeSteps: Decodable {
    let step: String?
    let ingredients: [RecipeStepIngredients]?
    let equipment: [RecipeStepEquipment]?
    let length: [RecipeStepLength]?
}

struct RecipeStepIngredients: Decodable {
    let id: Int?
    let name: String?
    let image: String?
}

struct RecipeStepEquipment: Decodable, Hashable {
    let id: Int?
    let name: String?
    let image: String?
}

struct RecipeStepLength: Decodable {
    let number: Int?
    let unit: String?
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
