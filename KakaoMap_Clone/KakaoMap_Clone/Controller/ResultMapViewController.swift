//
//  ResultMapViewController.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/25.
//

import UIKit
import CoreLocation

protocol ResultMapViewControllerDelegate: AnyObject {
    func needToShowSearchVC()
    func needToShowMainVC()
}

class ResultMapViewController: UIViewController {
    // MARK: - Properties
    
    private var locationManager = CLLocationManager()
    
    private var mapPoint: MTMapPoint?
    private var poiItem: MTMapPOIItem?

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
        view.setupShadow(opacity: 0.3, radius: 1.5, offset: CGSize(width: 0, height: 2.0), color: .black)
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
    
    private lazy var footerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setupShadow(opacity: 0.3, radius: 1.5, offset: CGSize(width: 0, height: -2.0), color: .black)
        [placeNameLabel, placeCategoryLabel, reviewView, addressLabel].forEach { view.addSubview($0) }
        return view
    }()
    
    private let placeNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black.withAlphaComponent(0.8)
        label.text = "카페 건"
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textAlignment = .left
        return label
    }()
    
    private let placeCategoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray.withAlphaComponent(0.8)
        label.text = "카테고리"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .left
        return label
    }()
    
    private let reviewView = ReviewStarView()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .darkGray
        label.text = "인천 중구 하늘달빛로2번길 8 씨사이드파크"
        label.numberOfLines = 1
        return label
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
        
        configureUIwithData()
        
        setMapView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for item in mapView.poiItems {
            mapView.remove(item as! MTMapPOIItem)
        }
    }
    
    // MARK: - Actions
    
    @objc private func listButtonTapped() {
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
    
    private func configureUIwithData() {
        guard let firstItem = viewModel.getResults.first else { return }
        placeNameLabel.text = firstItem.placeName
        placeCategoryLabel.text = firstItem.categoryGroupName
        addressLabel.text = firstItem.roadAddressName
    }
    
    private func setAutolayout() {
        view.addSubview(headerContainerView)
        headerContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 46 + 46 + 60)
        
        searchBarView.anchor(top: headerContainerView.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 60, paddingLeft: 15, paddingRight: 15, height: 46)
        
        buttonsView.anchor(top: searchBarView.bottomAnchor, left: headerContainerView.leftAnchor, right: headerContainerView.rightAnchor, paddingBottom: 10, height: 46)
        
        view.addSubview(footerContainerView)
        footerContainerView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, height: 160)
        
        placeNameLabel.anchor(top: footerContainerView.topAnchor, left: footerContainerView.leftAnchor, paddingTop: 16, paddingLeft: 14)
        placeCategoryLabel.anchor(left: placeNameLabel.rightAnchor, bottom: placeNameLabel.bottomAnchor, paddingLeft: 5)
        
        reviewView.anchor(top: placeNameLabel.bottomAnchor, left: placeNameLabel.leftAnchor, paddingTop: 5, width: 100)
        addressLabel.anchor(top: reviewView.bottomAnchor, left: placeNameLabel.leftAnchor, paddingTop: 7)
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
    
    private func setMapView() {
        mapView.delegate = self
        makeMarker()
        
        guard let firstItem = viewModel.getResults.first,
              let stringLon = firstItem.x,
              let stringLat = firstItem.y,
              let lon = Double(stringLon),
              let lat = Double(stringLat) else { return }
        mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: lat, longitude: lon)), zoomLevel: .min, animated: true)
        print("맵뷰 중심 세팅 - \(firstItem.placeName)")
    }
}

// MARK: - MTMapViewDelegate

extension ResultMapViewController: MTMapViewDelegate {
    
    private func makeMarker() {
        var count = 0
        
        for item in viewModel.getResults {
            guard let stringLon = item.x,
                  let stringLat = item.y,
                  let lat = Double(stringLat),
                  let lon = Double(stringLon) else {
                print("마커 좌표값 옵셔널 벗기기 실패")
                return
            }
            self.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: lat, longitude: lon))
            
            poiItem = MTMapPOIItem()
            
            poiItem?.markerType = MTMapPOIItemMarkerType.bluePin
            poiItem?.mapPoint = mapPoint
            
            poiItem?.itemName = item.placeName
            poiItem?.tag = count
            mapView.add(poiItem)
            
            count += 1
        }
    }
    
    func mapView(_ mapView: MTMapView!, touchedCalloutBalloonOf poiItem: MTMapPOIItem!) {
        // 태그를 활용하여 장소 구분짓기
        let index = poiItem.tag
        
    }
}
