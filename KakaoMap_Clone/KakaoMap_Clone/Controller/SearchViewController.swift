//
//  SearchViewController.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/23.
//

import UIKit
import JGProgressHUD

class SearchViewController: UIViewController {
    
    // MARK: - Properties
    
    private var viewModel = SearchViewModel()
    
    private let progressHud = JGProgressHUD(style: .dark)
    
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
        tv.rowHeight = view.frame.height / 15
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    // MARK: - Lifecycle
    
    init(lon: String, lat: String) {
        super.init(nibName: nil, bundle: nil)
        let viewModel = SearchViewModel(lon: lon, lat: lat)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setAutolayout()
        setActions()
        
        searchBarView.getSearchBar().searchTextField.becomeFirstResponder()
        searchBarView.getSearchBar().delegate = self
        
        viewModel.showProgressHUD = { [weak self] in
            self?.progressHud.show(in: (self?.view)!, animated: true)
        }
        
        viewModel.dismissProgressHUD = { [weak self] in
            self?.progressHud.dismiss()
        }
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
        return viewModel.getSearchOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuCell", for: indexPath) as! MenuCollectionViewCell
        cell.contentView.backgroundColor = .clear
        cell.configureUI(with: viewModel.getSearchOptions[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("선택한 장소 분류해서 보여주기")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = viewModel.getCellWidth(with: viewModel.getSearchOptions[indexPath.row])
        return CGSize(width: cellWidth, height: 45)
    }
    
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("SearchVC - TableView.rowsInSection Count: \(viewModel.getSetSearchHistories.count)")
        return viewModel.getSetSearchHistories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.text = viewModel.getSetSearchHistories[indexPath.row].searchText
        cell.imageView?.image = viewModel.getSetSearchHistories[indexPath.row].type
        
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        cell.selectedBackgroundView = backgroundColorView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let cell = tableView.cellForRow(at: indexPath),
        let keyword = cell.textLabel?.text,
        let image = cell.imageView?.image else { return }
        // 1. 장소 정보 없는 검색의 경우 - 현재 위치 기준으로 해당 키워드로 검색 -> SearchResultVC에 결과 띄우기
        if image == UIImage(systemName: "magnifyingglass") {
            viewModel.getKeywordSearchResult(with: keyword) { [weak self] results in
                guard let lon = self?.viewModel.lon,
                      let lat = self?.viewModel.lat else { return }
                self?.tableView.reloadData()
                let searchVC = SearchResultViewController(keyword: keyword,
                                                          results: results,
                                                          lon: lon,
                                                          lat: lat)
                searchVC.delegate = self
                self?.navigationController?.pushViewController(searchVC, animated: false)
            }
        }
        // 2. 장소 정보 있는 경우 - 장소의 상세 페이지 보여주기
    }
    
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //        print("검색중")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        searchBar.resignFirstResponder()
        if text != " " {
            viewModel.getKeywordSearchResult(with: text) { [weak self] results in
                guard let lon = self?.viewModel.lon,
                      let lat = self?.viewModel.lat else { return }
                
                let searchVC = SearchResultViewController(keyword: text,
                                                          results: results,
                                                          lon: lon,
                                                          lat: lat)
                searchVC.delegate = self
                self?.navigationController?.pushViewController(searchVC, animated: false)
            }
        }
    }
}

extension SearchViewController: SearchResultViewControllerDelegate {
    
    func needToPresentMainView() {
        self.navigationController?.popViewController(animated: false)
    }
    
    func passTappedHistory(newHistories: [SearchHistory]) {
        viewModel.updateNewSearchHistory(newHistories)
        searchBarView.getSearchBar().searchTextField.becomeFirstResponder()
        tableView.reloadData()
    }
    
}
