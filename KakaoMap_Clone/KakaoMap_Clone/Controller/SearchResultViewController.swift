//
//  SearchResultViewController.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/24.
//

import Foundation

protocol SearchResultViewControllerDelegate: AnyObject {
    func needToPresentMainView()
    func passTappedHistory(newHistories: [SearchHistory])
}

class SearchResultViewController: UIViewController {
    // MARK: - Properties
    
    private var viewModel = SearchResultViewModel()
    weak var delegate: SearchResultViewControllerDelegate?
    
    private let searchBarView = CustomSearchBarView(placeholder: "장소 및 주소 검색",
                                                    needBorderLine: true,
                                                    needCancelButton: true)
    
    private let buttonsView = UIView()
    
    private let borderLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .white
        tv.rowHeight = view.frame.height / 15
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    // MARK: - Lifecycle
    
    init(keyword: String, results: [Any]) {
        super.init(nibName: nil, bundle: nil)
        let viewModel = SearchResultViewModel(keyword: keyword, results: results)
        self.viewModel = viewModel
        searchBarView.getSearchBar().searchTextField.text = keyword
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setAutolayout()
        setActions()
        setSearchBar()
    }

    // MARK: - Actions
    
    @objc private func mapButtonTapped() {
        // 하단의 tableview를 지도 뷰로 교체해야함
    }
    
    @objc private func searchBarTapped() {
        // 선택했던 cell에 해당되는 장소의 정보를 SearchVC에 전달 필요
        delegate?.passTappedHistory(newHistories: viewModel.getTappedHistory)
        navigationController?.popViewController(animated: false)
    }
    
    @objc private func cancelButtonTapped() {
        // 선택했던 cell에 해당되는 장소의 정보를 SearchVC에 전달 필요
        delegate?.passTappedHistory(newHistories: viewModel.getTappedHistory)
        delegate?.needToPresentMainView()
        navigationController?.popViewController(animated: false)
    }
    
    // MARK: - Helpers
    
    private func setAutolayout() {
        view.addSubview(searchBarView)
        searchBarView.setDimensions(height: 46, width: view.frame.width - 30)
        searchBarView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 10)
        searchBarView.centerX(inView: view)
        
        view.addSubview(buttonsView)
        buttonsView.setDimensions(height: 46, width: view.frame.width)
        buttonsView.anchor(top: searchBarView.bottomAnchor)
        
        view.addSubview(borderLineView)
        borderLineView.setDimensions(height: 1, width: view.frame.width)
        borderLineView.anchor(top: buttonsView.bottomAnchor)
        
        view.addSubview(tableView)
        tableView.anchor(top: borderLineView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    private func setActions() {
        searchBarView.getMenuButton().addTarget(self, action: #selector(mapButtonTapped), for: .touchUpInside)
        searchBarView.getSearchBar().searchTextField.addTarget(self, action: #selector(searchBarTapped), for: .editingDidBegin)
    }
    
    private func setSearchBar() {
        searchBarView.getSearchBar().showsCancelButton = false
    }
}


// MARK: - UITableViewDelegate & UITableViewDataSource

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(viewModel.getResults.count)
        return viewModel.getResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
//        cell.textLabel?.text = viewModel.getResults[indexPath.row].searchText
//        cell.imageView?.image = viewModel.getResults[indexPath.row].type
        
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        cell.selectedBackgroundView = backgroundColorView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("선택된 장소의 상세 페이지 보여주기")
        tableView.deselectRow(at: indexPath, animated: true)
        let result = viewModel.getResults[indexPath.row] as? KeywordDocument
        guard let placeName = result?.placeName else {
            print("SearchResultVC - placeName error")
            return
        }
        viewModel.updateNewTappedHistory(location: placeName)
    }
    
}
