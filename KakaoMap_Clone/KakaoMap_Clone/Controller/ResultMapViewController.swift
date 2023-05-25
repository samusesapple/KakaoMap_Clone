//
//  ResultMapViewController.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/25.
//

import UIKit

protocol ResultMapViewControllerDelegate: AnyObject {
    func needToShowSearchVC()
    func needToShowMainVC()
}

class ResultMapViewController: UIViewController {
    // MARK: - Properties
    
    private var viewModel = SearchResultViewModel()
    
    weak var delegate: ResultMapViewControllerDelegate?
    
    private let mapView: MTMapView = {
        let mapView = MTMapView()
        mapView.baseMapType = .standard
        return mapView
    }()
    
    private lazy var headerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setupShadow(opacity: 0.8, radius: 0.8, offset: CGSize(width: 1.3, height: 0.5), color: .darkGray)
        [searchBarView, buttonsView].forEach { view.addSubview($0) }
        return view
    }()
    
    private let searchBarView = CustomSearchBarView(placeholder: nil,
                                                    needBorderLine: true,
                                                    needCancelButton: true,
                                                    isDetailView: true)
    
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
    
    // MARK: - Lifecycle
    
    init(title: String, results: [KeywordDocument]) {
        super.init(nibName: nil, bundle: nil)
        let viewModel = SearchResultViewModel(keyword: title, results: results)
        self.viewModel = viewModel
        searchBarView.getSearchBar().text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        
        setAutolayout()
        setActions()
        setSearchBar()
    }
    
    // MARK: - Actions
    
    @objc private func listButtonTapped() {
        // self.dismiss, SearchRsultVC 띄우기
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc private func searchBarTapped() {
        // 선택했던 cell에 해당되는 장소의 정보를 SearchVC에 전달 필요 + SearchResultVC dismiss
        navigationController?.popViewController(animated: false)
        delegate?.needToShowSearchVC()
    }
    
    @objc private func cancelButtonTapped() {
        // 선택했던 cell에 해당되는 장소의 정보를 SearchVC에 전달 필요
        navigationController?.popViewController(animated: false)
        delegate?.needToShowMainVC()
    }
    
    @objc private func centerAlignmentButtonTapped() {
        // 정렬 옵션 선택할 view push 하기  >  정렬 옵션 변경 된 경우 버튼 글자 변경 및 테이블뷰 정렬 변경
        let alertVC = CustomAlignmentAlertViewController(isCenterAlignment: true)
        alertVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alertVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        present(alertVC, animated: true)
    }
    
    @objc private func accuracyAlignmentButtonTapped() {
        // 정렬 옵션 선택할 view push 하기  >  정렬 옵션 변경 된 경우 버튼 글자 변경 및 테이블뷰 정렬 변경
        let alertVC = CustomAlignmentAlertViewController(isCenterAlignment: false)
        alertVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alertVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        present(alertVC, animated: true)
    }
    
    // MARK: - Helpers
    
    private func setAutolayout() {
        view.addSubview(headerContainerView)
        headerContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 46 + 46 + 60)
        
        searchBarView.anchor(top: headerContainerView.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 60, paddingLeft: 15, paddingRight: 15, height: 46)
        
        buttonsView.anchor(top: searchBarView.bottomAnchor, left: headerContainerView.leftAnchor, right: headerContainerView.rightAnchor, paddingBottom: 10, height: 46)
    }
    
    private func setActions() {
        searchBarView.getMenuButton().addTarget(self, action: #selector(listButtonTapped), for: .touchUpInside)
        searchBarView.getSearchBar().searchTextField.addTarget(self, action: #selector(searchBarTapped), for: .editingDidBegin)
        searchBarView.getCancelButton().addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        centerAlignmentButton.addTarget(self, action: #selector(centerAlignmentButtonTapped), for: .touchUpInside)
        accuracyAlignmentButton.addTarget(self, action: #selector(accuracyAlignmentButtonTapped), for: .touchUpInside)
    }
    
    private func setSearchBar() {
        searchBarView.getSearchBar().showsCancelButton = false
    }
}
