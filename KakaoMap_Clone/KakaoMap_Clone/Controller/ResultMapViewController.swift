//
//  ResultMapViewController.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/25.
//

import UIKit
import CoreLocation
import JGProgressHUD

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
    
    private let progressHud = JGProgressHUD(style: .dark)
    
    weak var delegate: ResultMapViewControllerDelegate?
    
    private let mapView: MTMapView = {
        let mapView = MTMapView()
        mapView.baseMapType = .standard
        mapView.backgroundColor = .black
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
        button.tintColor = .darkGray
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        return button
    }()
    
    private let accuracyAlignmentButton: UIButton = {
        let button = UIButton(type: .system)
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
        [placeNameLabel, placeCategoryLabel, reviewView, addressLabel, navigationButton, distanceLabel].forEach { view.addSubview($0) }
        return view
    }()
    
    private let placeNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black.withAlphaComponent(0.8)
        label.text = "카페 건"
        label.font = UIFont.systemFont(ofSize: 17.5, weight: .medium)
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
    
    private let navigationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "uTernIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = #colorLiteral(red: 0.03529411765, green: 0.5176470588, blue: 0.8901960784, alpha: 1)
        label.text = "1123m"
        return label
    }()
    
    // MARK: - Lifecycle
    
    init(title: String, viewModel: SearchResultViewModel, place: KeywordDocument? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        searchBarView.getSearchBar().text = title
        viewModel.targetPlace = place
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
        setSearchBarAndAlignmentButtons()
        
        checkIfTargetPlaceExists()
        
        footerContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                     action: #selector(footerViewTapped)))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for item in mapView.poiItems {
            mapView.remove(item as? MTMapPOIItem)
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
        let firstButtonTapped = centerAlignmentButton.titleLabel?.text != "지도중심 ▾" ? true : false
        let alertVC = CustomAlignmentAlertViewController(isCenterAlignment: true,
                                                         firstButtonTapped: firstButtonTapped)
        //        alertVC.delegate = self
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
        //        alertVC.delegate = self
        alertVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alertVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        present(alertVC, animated: true)
        print(#function)
    }
    
    @objc private func footerViewTapped() {
        guard let url = viewModel.targetPlace?.placeURL else { return }
        let webVC = DetailViewController(url: url)
        print(url)
        present(webVC, animated: true)
    }
    
    @objc private func navigationButtonTapped() {
        guard let target = viewModel.targetPlace else { return }
        print("\(target)으로 가는 네비게이션 view 띄워야함")
    }
    
    // MARK: - Helpers
    /// 장소 선택 유무에 따라 다른 UI를 띄우기
    private func checkIfTargetPlaceExists() {
        guard let targetPlace = viewModel.targetPlace else {
            viewModel.targetPlace = viewModel.getResults[0]
            checkIfTargetPlaceExists()
            return
        }
        configureUIwithData(place: targetPlace)
        setMapView(with: targetPlace)
    }
    
    /// FooterView의 UI를 선택된 장소 유무에 따라 다르게 띄우기
    private func configureUIwithData(place: KeywordDocument?) {
        guard let place = place,
              let distance = place.distance else { return }
        placeNameLabel.text = place.placeName
        placeCategoryLabel.text = place.categoryGroupName
        addressLabel.text = place.roadAddressName
        distanceLabel.text = MeasureFormatter.measureDistance(distance: distance)
    }
    
    private func setAutolayout() {
        view.addSubview(headerContainerView)
        headerContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 46 + 46 + 60)
        
        searchBarView.anchor(top: headerContainerView.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 60, paddingLeft: 15, paddingRight: 15, height: 46)
        
        buttonsView.anchor(top: searchBarView.bottomAnchor, left: headerContainerView.leftAnchor, right: headerContainerView.rightAnchor, paddingBottom: 10, height: 46)
        
        view.addSubview(footerContainerView)
        footerContainerView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, height: 160)
        
        placeNameLabel.anchor(top: footerContainerView.topAnchor, left: footerContainerView.leftAnchor, paddingTop: 16, paddingLeft: 16)
        placeCategoryLabel.anchor(left: placeNameLabel.rightAnchor, bottom: placeNameLabel.bottomAnchor, paddingLeft: 5)
        
        reviewView.anchor(top: placeNameLabel.bottomAnchor, left: placeNameLabel.leftAnchor, paddingTop: 5, width: 100)
        addressLabel.anchor(top: reviewView.bottomAnchor, left: placeNameLabel.leftAnchor, paddingTop: 7)
        
        navigationButton.anchor(top: footerContainerView.topAnchor, right: footerContainerView.rightAnchor, paddingTop: 12, paddingRight: 16, width: 50, height: 50)
        
        distanceLabel.anchor(top: navigationButton.bottomAnchor, paddingTop: 4)
        distanceLabel.centerX(inView: navigationButton)
    }
    
    private func setActions() {
        searchBarView.getMenuButton().addTarget(self, action: #selector(listButtonTapped), for: .touchUpInside)
        searchBarView.getSearchBar().searchTextField.addTarget(self, action: #selector(searchBarTapped), for: .editingDidBegin)
        searchBarView.getCancelButton().addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        centerAlignmentButton.addTarget(self, action: #selector(centerAlignmentButtonTapped), for: .touchUpInside)
        accuracyAlignmentButton.addTarget(self, action: #selector(accuracyAlignmentButtonTapped), for: .touchUpInside)
        
        navigationButton.addTarget(self, action: #selector(navigationButtonTapped), for: .touchUpInside)
    }
    
    private func setSearchBarAndAlignmentButtons() {
        searchBarView.getSearchBar().showsCancelButton = false
        
        if viewModel.isMapBasedData {
            centerAlignmentButton.setTitle("지도중심 ▾", for: .normal)
        } else {
            centerAlignmentButton.setTitle("내위치중심 ▾", for: .normal)
        }
        
        if viewModel.isAccuracyAlignment {
            accuracyAlignmentButton.setTitle("정확도순 ▾", for: .normal)
        } else {
            accuracyAlignmentButton.setTitle("거리순 ▾", for: .normal)
        }
    }
    /// mapView 세팅 - 선택된 장소 유무에 따라 맵뷰의 중심점 세팅하기
    private func setMapView(with place: KeywordDocument?) {
        mapView.delegate = self
        mapView.currentLocationTrackingMode = .off
        
        makeMarker()
        
        guard let place = place,
              let stringLon = place.x,
              let stringLat = place.y,
              let lon = Double(stringLon),
              let lat = Double(stringLat),
              let placeId = place.id,
              let poiItems = mapView.poiItems as? [MTMapPOIItem]
        else { return }
        mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: lat, longitude: lon)), zoomLevel: .min, animated: true)
        
        let targetPoi = poiItems.filter({ $0.tag == Int(placeId) })[0]
        mapView.select(targetPoi, animated: true)
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
                  let lon = Double(stringLon),
                  let stringID = item.id,
                  let placeID = Int(stringID) else {
                print("마커 좌표값 옵셔널 벗기기 실패")
                return
            }
            self.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: lat, longitude: lon))
            
            let customPoiImage = UIImage(named: "bluePoint")?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25))
            let selectedPoiImage = UIImage(named: "selectedBluePoint")?.scalePreservingAspectRatio(targetSize: CGSize(width: 35, height: 35))
            
            poiItem = MTMapPOIItem()
            poiItem?.markerType = .customImage
            poiItem?.customImage = customPoiImage
            
            poiItem?.markerSelectedType = .customImage
            poiItem?.customSelectedImage = selectedPoiImage
            
            poiItem?.mapPoint = mapPoint
            poiItem?.itemName = item.placeName
            poiItem?.tag = placeID
            mapView.add(poiItem)
            
            count += 1
        }
    }
    
    func mapView(_ mapView: MTMapView!, selectedPOIItem poiItem: MTMapPOIItem!) -> Bool {
        let targetPlace = viewModel.filterResults(with: poiItem.tag)
        configureUIwithData(place: targetPlace)
        return false
    }
    
}
