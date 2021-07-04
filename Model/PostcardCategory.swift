//
//  PostcardCategory.swift
//  PostcardsTiles
//
//  Created by n3deep on 27.06.2021.
//

import Foundation

struct PostcardCategoryResponse: Codable {
    
    let categories: [PostcardCategory]
    
    enum CodingKeys: String, CodingKey {
        
        case categories = "data"
    }
}

struct PostcardCategory: Codable {
    
    let name: String
    let id: Int
}
