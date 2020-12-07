//
//  Recipe.swift
//  Recipe App
//
//  Created by Lim Meng Shin on 29/11/20.
//

struct Recipe: Decodable {
    let results: [RecipesInfo]?
}

struct RecipesInfo: Decodable, Equatable {
    let title: String?
    let image: String?
    let id: Int?
    let readyInMinutes: Int?
    let servings: Int?
    let aggregateLikes: Int?
    let sourceName: String?
    let sourceUrl: String?
    let summary: String?
    let cuisines: [String]?
    let dishTypes: [String]?
    let diets: [String]?
    let nutrition: RecipeNutrition?
    let analyzedInstructions: [RecipeInstructions]?
    
    var caloriesCarbFatsProteins: [RecipeNutrients] {
        var nutrientArray: [RecipeNutrients] = []
        if let nutrition = nutrition, let nutrients = nutrition.nutrients {
            for nutrient in nutrients {
                if ["Calories", "Fat", "Carbohydrates", "Protein"].contains(nutrient.title) {
                    nutrientArray.append(nutrient)
                }
            }
        }
        return nutrientArray
    }
    
    var equipments: [RecipeStepEquipment] {
        var equipmentsArray: [RecipeStepEquipment] = []
        if let analyzedInstructions = analyzedInstructions {
            for analyzedInstruction in analyzedInstructions {
                if let steps = analyzedInstruction.steps {
                    for step in steps {
                        if let equipment = step.equipment {
                            equipmentsArray += equipment
                        }
                    }
                }
            }
        }
        return equipmentsArray.unique()
    }

    static func ==(lhs: RecipesInfo, rhs: RecipesInfo) -> Bool {
        return lhs.title == rhs.title && lhs.image == rhs.image && lhs.id == rhs.id && lhs.readyInMinutes == rhs.readyInMinutes && lhs.servings == rhs.servings && lhs.aggregateLikes == rhs.aggregateLikes && lhs.sourceName == rhs.sourceName && lhs.sourceUrl == rhs.sourceUrl && lhs.summary == rhs.summary && lhs.cuisines == rhs.cuisines && lhs.dishTypes == rhs.dishTypes && lhs.diets == rhs.diets && lhs.nutrition == rhs.nutrition && lhs.analyzedInstructions == rhs.analyzedInstructions && lhs.caloriesCarbFatsProteins == rhs.caloriesCarbFatsProteins && lhs.equipments == rhs.equipments
    }
}

// Nutrition and Ingredients
struct RecipeNutrition: Decodable, Equatable {
    let nutrients: [RecipeNutrients]?
    let ingredients: [RecipeIngredients]?

    static func ==(lhs: RecipeNutrition, rhs: RecipeNutrition) -> Bool {
        return lhs.nutrients == rhs.nutrients && lhs.ingredients == rhs.ingredients
    }
}

struct RecipeNutrients: Decodable, Equatable {
    let title: String?
    let amount: Double?
    let unit: String?
    let percentOfDailyNeeds: Double?

    static func ==(lhs: RecipeNutrients, rhs: RecipeNutrients) -> Bool {
        return lhs.title == rhs.title && lhs.amount == rhs.amount && lhs.unit == rhs.unit && lhs.percentOfDailyNeeds == rhs.percentOfDailyNeeds
    }
}

struct RecipeIngredients: Decodable, Equatable {
    let name: String?
    let amount: Double?
    let unit: String?

    static func ==(lhs: RecipeIngredients, rhs: RecipeIngredients) -> Bool {
        return lhs.name == rhs.name && lhs.amount == rhs.amount && lhs.unit == rhs.unit
    }
}

// Instructions
struct RecipeInstructions: Decodable, Equatable {
    let steps: [RecipeSteps]?

    static func ==(lhs: RecipeInstructions, rhs: RecipeInstructions) -> Bool {
        return lhs.steps == rhs.steps
    }
}

struct RecipeSteps: Decodable, Equatable {
    let step: String?
    let ingredients: [RecipeStepIngredients]?
    let equipment: [RecipeStepEquipment]?
    let length: RecipeStepLength?

    static func ==(lhs: RecipeSteps, rhs: RecipeSteps) -> Bool {
        return lhs.step == rhs.step && lhs.ingredients == rhs.ingredients && lhs.equipment == rhs.equipment && lhs.length == rhs.length
    }
}

struct RecipeStepIngredients: Decodable, Equatable {
    let id: Int?
    let name: String?
    let image: String?

    static func ==(lhs: RecipeStepIngredients, rhs: RecipeStepIngredients) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.image == rhs.image
    }
}

struct RecipeStepEquipment: Decodable, Hashable, Equatable {
    let id: Int?
    let name: String?
    let image: String?

    static func ==(lhs: RecipeStepEquipment, rhs: RecipeStepEquipment) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.image == rhs.image
    }
}

struct RecipeStepLength: Decodable, Equatable {
    let number: Int?
    let unit: String?

    static func ==(lhs: RecipeStepLength, rhs: RecipeStepLength) -> Bool {
        return lhs.number == rhs.number && lhs.unit == rhs.unit
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
