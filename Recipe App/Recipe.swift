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
