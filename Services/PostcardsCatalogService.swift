//
//  PostcardsCatalogService.swift
//  PostcardsTiles
//
//  Created by n3deep on 27.06.2021.
//

import Foundation

protocol PostcardsCatalogServiceType {
    
    func fetchCategories(onSuccess: @escaping (PostcardCategoryResponse) -> Void, onFailure: @escaping (String) -> Void)
    func fetchPostcards(categoryId: Int, page: Int, onSuccess: @escaping (PostcardResponse) -> Void, onFailure: @escaping (String) -> Void) 
}


class PostcardsCatalogService: PostcardsCatalogServiceType {
    
    let apiURL: String = "http://wizl.itech-mobile.ru/api/v2"
    let uploadBaseURL: String = "http://static.wizl.itech-mobile.ru"
    
    let acceptLanguage: String = "ru_RU"
    let authorizationToken: String  = "Basic bW9iaWxlY2xpZW50OkxXdzhudzRjdlNvN0tkQlNWZ0Fq"
    let contentType: String = "application/json"
    
    func fetchCategories(onSuccess: @escaping (PostcardCategoryResponse) -> Void, onFailure: @escaping (String) -> Void) {
        
        let url = URL(string: apiURL + "/lifestyle/addressists")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(authorizationToken, forHTTPHeaderField: "Authorization")
        request.setValue(acceptLanguage, forHTTPHeaderField: "Accept-Language")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, error == nil {
                let jsonDecoder = JSONDecoder()
                do {
                    let parsedJSON = try jsonDecoder.decode(PostcardCategoryResponse.self, from: data)
                    //let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                    //print(json)
                    onSuccess(parsedJSON)
                } catch {
                    onFailure(error.localizedDescription)
                }
            }
       }.resume()
    }
    
    func fetchPostcards(categoryId: Int, page: Int, onSuccess: @escaping (PostcardResponse) -> Void, onFailure: @escaping (String) -> Void) {

        let url = URL(string: apiURL + "/lifestyle/feed?addresist_id=\(categoryId)&addressist_id=\(categoryId)&page=\(page)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(authorizationToken, forHTTPHeaderField: "Authorization")
        request.setValue(acceptLanguage, forHTTPHeaderField: "Accept-Language")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, error == nil {
                let jsonDecoder = JSONDecoder()
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                    //print(json)
                    let parsedJSON = try jsonDecoder.decode(PostcardResponse.self, from: data)
                    //print(parsedJSON)
                    onSuccess(parsedJSON)
                } catch {
                    onFailure(error.localizedDescription)
                }
            }
       }.resume()
    }
}
