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
    
    private let centerAlignmentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("지도중심 ▾", for: .normal)
        button.tintColor = .darkGray
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        return button
    }()
    
    private let accuracyAlignmentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("정확도순 ▾", for: .normal)
        button.tintColor = .darkGray
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        return button
    }()
    
    private lazy var buttonsView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 46))
        [centerAlignmentButton, accuracyAlignmentButton].forEach { view.addSubview($0) }
        centerAlignmentButton.anchor(left: view.leftAnchor, paddingLeft: 15)
        centerAlignmentButton.centerY(inView: view)
        
        accuracyAlignmentButton.anchor(left: centerAlignmentButton.rightAnchor, paddingLeft: 7)
        accuracyAlignmentButton.centerY(inView: view)
        return view
    }()
    
    private let borderLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .white
        tv.rowHeight = (view.frame.height / 5) - 10
        tv.register(SearchResultTableViewCell.self, forCellReuseIdentifier: "resultCell")
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    // MARK: - Lifecycle
    
    init(keyword: String, results: [KeywordDocument]) {
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
        // ResultMapView에 정보 전달 및 띄우기
        guard let title = searchBarView.getSearchBar().text else { return }
        let resultMapVC = ResultMapViewController(title: title, results: viewModel.getResults)
        resultMapVC.delegate = self
        navigationController?.pushViewController(resultMapVC, animated: false)
    }
    
    @objc private func searchBarTapped() {
        // 선택했던 cell에 해당되는 장소의 정보를 SearchVC에 전달 필요
        delegate?.passTappedHistory(newHistories: viewModel.getTappedHistory)
        navigationController?.popViewController(animated: false)
    }
    
    @objc private func cancelButtonTapped() {
        // 선택했던 cell에 해당되는 장소의 정보를 SearchVC에 전달 필요
        delegate?.passTappedHistory(newHistories: viewModel.getTappedHistory)
        navigationController?.popViewController(animated: false)
        delegate?.needToPresentMainView()
    }
    
    @objc private func centerAlignmentButtonTapped() {
        // 정렬 옵션 선택할 view push 하기  >  정렬 옵션 변경 된 경우 버튼 글자 변경 및 테이블뷰 정렬 변경
        let alertVC = CustomAlignmentAlertViewController(isCenterAlignment: true)
        alertVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alertVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        present(alertVC, animated: true)
        print(#function)
    }
    
    @objc private func accuracyAlignmentButtonTapped() {
        // 정렬 옵션 선택할 view push 하기  >  정렬 옵션 변경 된 경우 버튼 글자 변경 및 테이블뷰 정렬 변경
        let alertVC = CustomAlignmentAlertViewController(isCenterAlignment: false)
        alertVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alertVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        present(alertVC, animated: true)
        print(#function)
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
        searchBarView.getCancelButton().addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        centerAlignmentButton.addTarget(self, action: #selector(centerAlignmentButtonTapped), for: .touchUpInside)
        accuracyAlignmentButton.addTarget(self, action: #selector(accuracyAlignmentButtonTapped), for: .touchUpInside)
    }
    
    private func setSearchBar() {
        searchBarView.getSearchBar().showsCancelButton = false
    }
}


// MARK: - UITableViewDelegate & UITableViewDataSource

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! SearchResultTableViewCell
        cell.configureUIwithData(data: viewModel.getResults[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("선택된 장소의 상세 페이지 보여주기")
        tableView.deselectRow(at: indexPath, animated: true)
        let result = viewModel.getResults[indexPath.row]
        guard let placeName = result.placeName else {
            print("SearchResultVC - placeName error")
            return
        }
        viewModel.updateNewTappedHistory(location: placeName)
    }
    
}

// MARK: - ResultMapViewControllerDelegate

extension SearchResultViewController: ResultMapViewControllerDelegate {
    func needToShowSearchVC() {
        searchBarTapped()
    }
    
    func needToShowMainVC() {
        cancelButtonTapped()
    }
    
}
