//
//  SearchResultViewController.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/24.
//

import Foundation
import JGProgressHUD

protocol SearchResultViewControllerDelegate: AnyObject {
    func needToPresentMainView()
    func passTappedHistory(newHistories: [SearchHistory])
}

class SearchResultViewController: UIViewController {
    // MARK: - Properties
    
    private var viewModel = SearchResultViewModel()
    weak var delegate: SearchResultViewControllerDelegate?
    
    private let progressHud = JGProgressHUD(style: .dark)

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
    
    init(keyword: String, results: [KeywordDocument], lon: String, lat: String) {
        super.init(nibName: nil, bundle: nil)
        let viewModel = SearchResultViewModel(lon: lon,
                                              lat: lat,
                                              keyword: keyword,
                                              results: results)
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
        
        viewModel.loadingStarted = { [weak self] in
            guard let view = self?.view else { return }
            self?.progressHud.show(in: view)
        }
        
        viewModel.finishLoading = { [weak self] in
            self?.tableView.reloadData()
            self?.progressHud.dismiss()
        }
    }
    
    // MARK: - Actions
    
    @objc private func mapButtonTapped() {
        // ResultMapView에 정보 전달 및 띄우기
        guard let title = searchBarView.getSearchBar().text else { return }
        let resultMapVC = ResultMapViewController(title: title,
                                                  viewModel: viewModel)
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
        let firstButtonTapped = centerAlignmentButton.titleLabel?.text != "지도중심 ▾" ? true : false
        let alertVC = CustomAlignmentAlertViewController(isCenterAlignment: true,
                                                         firstButtonTapped: firstButtonTapped)
        alertVC.delegate = self
        alertVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alertVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        present(alertVC, animated: true)
        print(#function)
    }
    
    @objc private func accuracyAlignmentButtonTapped() {
        // 정렬 옵션 선택할 view push 하기  >  정렬 옵션 변경 된 경우 버튼 글자 변경 및 테이블뷰 정렬 변경
        let firstButtonTapped = accuracyAlignmentButton.titleLabel?.text == "정확도순 ▾" ? true : false
        let alertVC = CustomAlignmentAlertViewController(isCenterAlignment: false,
                                                         firstButtonTapped: firstButtonTapped)
        alertVC.delegate = self
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
        tableView.deselectRow(at: indexPath, animated: true)
        let result = viewModel.getResults[indexPath.row]
        guard let placeName = result.placeName else {
            print("SearchResultVC - placeName error")
            return
        }
        // 검색 기록 추가 + 해당되는 셀의 장소 보여주는 mapResultVC push 하기
        viewModel.updateNewTappedHistory(location: placeName)
        let mapResultView = ResultMapViewController(title: searchBarView.getSearchBar().text!,
                                                    viewModel: viewModel,
                                                    place: result)
        self.navigationController?.pushViewController(mapResultView, animated: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.height {
            viewModel.getNextPageResult()
        }
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

// MARK: - CustomAlignmentAlertViewControllerDelegate

extension SearchResultViewController: CustomAlignmentAlertViewControllerDelegate {
    func getCurrentLocationBaseData() {
        print("현재 위치 기준으로 정보 받기")
        centerAlignmentButton.setTitle("내위치중심 ▾", for: .normal)
        viewModel.isMapBasedData = false
    }
    
    func getMapBoundaryBaseData() {
        print("지도상 위치 기준으로 정보 받기")
        centerAlignmentButton.setTitle("지도중심 ▾", for: .normal)
        viewModel.isMapBasedData = true
    }
    
    func correctInfoBaseAlignment() {
        print("정확도 순으로 정렬")
        accuracyAlignmentButton.setTitle("정확도순 ▾", for: .normal)
        viewModel.isAccurancyAlignment = true
    }
    
    func shortDistanceFirstAlignment() {
        print("거리순으로 정렬")
        accuracyAlignmentButton.setTitle("거리순 ▾", for: .normal)
        viewModel.isAccurancyAlignment = false
    }
}
