//
//  PostcardsCatalogViewModel.swift
//  PostcardsTiles
//
//  Created by n3deep on 27.06.2021.
//

import Foundation
import Combine

protocol PostcardsCatalogViewModelType {
    
    var categoriesPublisher: Published<[PostcardCategory]>.Publisher { get }
    var postcardsPublisher: Published<[Postcard]>.Publisher { get }

    var postcards: [Postcard] { get }
    var categories: [PostcardCategory] { get }

    var page: Int  { get  set }
    var selectedCategoryID: Int? { get set }
    var isLoading: Bool  { get  set }
    
    func fetchCategories()
    func fetchPostcards()
}

class PostcardsCatalogViewModel: ObservableObject, PostcardsCatalogViewModelType {
    
    var postcardsPublisher: Published<[Postcard]>.Publisher { $postcards }
    var categoriesPublisher: Published<[PostcardCategory]>.Publisher { $categories }
        
    private let postcardsCatalogService: PostcardsCatalogServiceType?
    
    @Published var postcards: [Postcard] = []
    @Published var categories: [PostcardCategory] = []

    var page: Int = 0
    var selectedCategoryID: Int?
    var isLoading: Bool = false
    
    private var subscriptions = Set<AnyCancellable>()

    init() {
        self.postcardsCatalogService = PostcardsCatalogService()
        
        fetchCategories()
    }
    
    func fetchCategories() {
        postcardsCatalogService?.fetchCategories(onSuccess: { categoriesResponse in
            self.categories = categoriesResponse.categories
            self.selectedCategoryID = categoriesResponse.categories.first!.id
            self.fetchPostcards()
        }, onFailure: { error in
            print(error)
        })
    }
    
    func fetchPostcards() {
        guard let selectedCategoryID = selectedCategoryID  else {
            print("error nil")
            return
        }
        
        isLoading = true
        
        postcardsCatalogService?.fetchPostcards(categoryId: selectedCategoryID, page: page, onSuccess: { postcardsResponse in
            if self.page == 0 {
                self.postcards = postcardsResponse.data.postcards
            } else {
                self.postcards.append(contentsOf: postcardsResponse.data.postcards)
            }
            self.isLoading = false
        }, onFailure: { error in
            print(error)
            self.isLoading = false
        })
    }
}
