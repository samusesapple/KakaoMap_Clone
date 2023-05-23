//
//  SearchViewController.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/23.
//

import UIKit

class SearchViewController: UIViewController {

    // MARK: - Properties
    
    private let viewModel = SearchViewModel()
    
    private let searchBarView = CustomSearchBarView(placeholder: "장소 및 주소 검색", needBorderLine: true)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isPagingEnabled = false
        cv.showsHorizontalScrollIndicator = false
        cv.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        cv.register(MenuCollectionViewCell.self, forCellWithReuseIdentifier: "menuCell")
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    private let borderLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let header = UIView()
        header.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
    
        let currentLabel = UILabel()
        currentLabel.text = "최근 검색"
        currentLabel.textColor = .black
        currentLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        header.addSubview(currentLabel)
        currentLabel.centerY(inView: header)
        currentLabel.anchor(left: header.leftAnchor, paddingLeft: 20)
        
        let tv = UITableView()
        tv.tableHeaderView = header
        tv.backgroundColor = .white
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setAutolayout()
        setActions()
        
        searchBarView.getSearchBar().searchTextField.becomeFirstResponder()
    }

    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: false)
    }
    
    // MARK: - Helpers
    
    private func setAutolayout() {
        view.addSubview(searchBarView)
        searchBarView.setDimensions(height: 46, width: view.frame.width - 30)
        searchBarView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 10)
        searchBarView.centerX(inView: view)
        
        view.addSubview(collectionView)
        collectionView.setDimensions(height: 46, width: view.frame.width)
        collectionView.anchor(top: searchBarView.bottomAnchor)
        
        view.addSubview(borderLineView)
        borderLineView.setDimensions(height: 1, width: view.frame.width)
        borderLineView.anchor(top: collectionView.bottomAnchor)
        
        view.addSubview(tableView)
        tableView.anchor(top: borderLineView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    private func setActions() {
        searchBarView.getMenuButton().addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource & UICollectionViewDelegateFlowLayout

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.searchOptions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuCell", for: indexPath) as! MenuCollectionViewCell
        cell.contentView.backgroundColor = .clear
        cell.configureUI(with: viewModel.searchOptions[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("선택한 장소 분류해서 보여주기")
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = viewModel.getCellWidth(with: viewModel.searchOptions[indexPath.row])
        return CGSize(width: cellWidth, height: 45)
    }

}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.backgroundColor = .clear
        
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        cell.selectedBackgroundView = backgroundColorView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("선택된 장소의 상세 페이지 보여주기")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
