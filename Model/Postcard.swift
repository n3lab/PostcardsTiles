//
//  Postcard.swift
//  PostcardsTiles
//
//  Created by n3deep on 27.06.2021.
//

import Foundation

struct PostcardResponse: Codable {
    
    let data: PostcardData
}

struct PostcardData: Codable {
    
    let postcards: [Postcard]
    
    enum CodingKeys: String, CodingKey {
        
        case postcards = "post_card"
    }
}

struct Postcard: Codable {
    
    let image: PostcardImage
    let name: String
}

struct PostcardImage: Codable {

    let url: String
    var preview: String
    let dimentions: PostcardDimentions
}

struct PostcardDimentions: Codable {
    
    let height: Int
    let width: Int
}

