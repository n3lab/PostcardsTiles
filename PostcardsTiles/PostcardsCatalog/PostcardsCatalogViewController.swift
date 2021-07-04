//
//  PostcardsCatalogViewController.swift
//  PostcardsTiles
//
//  Created by n3deep on 27.06.2021.
//

import UIKit
import Combine

import MaterialComponents.MaterialTabs_TabBarView
import MaterialComponents.MaterialAppBar
import Kingfisher

class PostcardsCatalogViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    lazy var appBar: MDCAppBarViewController = setupAppBar()
    lazy var tabBar: MDCTabBarView = setupTabBar()

    let postcardsCatalogService = PostcardsCatalogService()
    
    var viewModel: PostcardsCatalogViewModelType!
    private var subscriptions = Set<AnyCancellable>()
        
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupUI()
                        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        viewModel = PostcardsCatalogViewModel()
        bindViewModel()
        
        viewModel.fetchCategories()
    }
    
    func bindViewModel() {
        
        // binding
        viewModel.categoriesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] categories in
                self?.updateTabBar()
             }
            .store(in: &subscriptions)
        
        viewModel.postcardsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] categories in
                self?.collectionView.reloadData()
                
                if self?.viewModel.page == 0 {
                    self?.collectionView.setContentOffset(.zero, animated: false)
                }
             }
            .store(in: &subscriptions)
    }
    
    func setupUI() {
        view.addSubview(appBar.view)
        appBar.didMove(toParent: self)
        
        self.navigationItem.title = "Открытки"
        
        setupCollectionView()
        
        let attributes = [NSAttributedString.Key.font: UIFont.navbarTitleFont!]
        UINavigationBar.appearance().titleTextAttributes = attributes
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupAppBar() -> MDCAppBarViewController {
        let appBarViewController = MDCAppBarViewController()
        addChild(appBarViewController)
 
        appBarViewController.headerView.minMaxHeightIncludesSafeArea = false
        appBarViewController.inferTopSafeAreaInsetFromViewController = true
        appBarViewController.headerView.sharedWithManyScrollViews = true
        appBarViewController.headerView.minimumHeight = 90
        appBarViewController.headerView.maximumHeight = 128

        appBarViewController.headerView.backgroundColor = UIColor.navbarBackgroundColor
        
        appBarViewController.headerView.visibleShadowOpacity = 0.5

        appBarViewController.navigationBar.tintColor = UIColor.navbarFontColor
        appBarViewController.navigationBar.backgroundColor = UIColor.navbarBackgroundColor
        appBarViewController.navigationBar.titleTextColor = UIColor.navbarFontColor
        appBarViewController.navigationBar.titleAlignment = .leading

        //appBarViewController.headerView.shiftBehavior = .hideable

        return appBarViewController
    }
    
    override var childForStatusBarStyle: UIViewController? {
      return appBar
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            //appBar.headerView.shiftHeaderOffScreen(animated: true)
        } else {
            //appBar.headerView.shiftHeaderOnScreen(animated: true)
        }
    }
    
    func setupTabBar() -> MDCTabBarView {
        let tabBarView = MDCTabBarView()
        tabBarView.tabBarDelegate = self
        tabBarView.preferredLayoutStyle = .scrollableCentered
        tabBarView.barTintColor = UIColor.navbarBackgroundColor
        tabBarView.setTitleColor(UIColor.navbarFontColor, for: .normal)
        tabBarView.selectionIndicatorStrokeColor = UIColor.navbarFontColor
        
        return tabBarView
    }
    
    func setupCollectionView() {
                
        let layout = CollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.headerInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        layout.headerHeight = 0
        layout.footerHeight = 0
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView.collectionViewLayout = layout
    }
    
    
    func updateTabBar() {

        var tabs: [UITabBarItem] = []
        for category in viewModel.categories {
            tabs.append(UITabBarItem(title: category.name.uppercased(), image: nil, tag: category.id))
        }
        guard let selectedCategoryTag = tabs.first?.tag else {
            print("error")
            return
        }
        viewModel.selectedCategoryID = selectedCategoryTag
        DispatchQueue.main.async {
            self.tabBar.items = tabs
            self.tabBar.selectedItem = self.tabBar.items[0]
            self.appBar.headerStackView.bottomBar = self.tabBar
        }
    }
}

extension PostcardsCatalogViewController: MDCTabBarViewDelegate {
    
    func tabBarView(_ tabBarView: MDCTabBarView, didSelect item: UITabBarItem) {
        //selectedCategoryTag = item.tag

        viewModel.selectedCategoryID = item.tag
        viewModel.page = 0
        viewModel.fetchPostcards()
    }
}

// MARK: - UICollectionViewDataSource
extension PostcardsCatalogViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.postcards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostcardCell", for: indexPath) as! PostcardCell
        
        let url = URL(string: "http://static.wizl.itech-mobile.ru" + viewModel.postcards[indexPath.row].image.preview)
        cell.imageView.kf.setImage(with: url)
        
        return cell
    }
}

// MARK: - CollectionViewWaterfallLayoutDelegate
extension PostcardsCatalogViewController: CollectionViewWaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let postcardSize = CGSize(width: viewModel.postcards[indexPath.row].image.dimentions.width, height: viewModel.postcards[indexPath.row].image.dimentions.height)
        
        return postcardSize
    }
}

extension PostcardsCatalogViewController: UIScrollViewDelegate {
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            if !viewModel.isLoading {
                viewModel.page = viewModel.page + 1
                viewModel.fetchPostcards()
            }
        }
    }
}
