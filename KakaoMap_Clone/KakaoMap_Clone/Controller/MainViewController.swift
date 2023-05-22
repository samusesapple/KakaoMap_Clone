//
//  ViewController.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/21.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    var longtitude: Double?
    var latitude: Double?
    
    private let mapView: MTMapView = {
        let mapView = MTMapView()
        mapView.baseMapType = .standard
        return mapView
    }()
    
    private let currentLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setImage(UIImage(systemName: "location.north.circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        configureUI()
        setLocationManager()
        
        currentLocationButton.addTarget(self, action: #selector(showCurrentLocation), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func showCurrentLocation() {
        print("현재 위치로 이동")
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            mapView.currentLocationTrackingMode = .onWithHeading
        }
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.addSubview(mapView)
        mapView.setDimensions(height: view.frame.height, width: view.frame.width)
        
        mapView.addSubview(currentLocationButton)
        currentLocationButton.setDimensions(height: 50, width: 50)
        currentLocationButton.anchor(left: mapView.leftAnchor, bottom: mapView.bottomAnchor, paddingLeft: 18, paddingBottom: 40)
        DispatchQueue.main.async { [weak self] in
            self?.currentLocationButton.makeRounded()
        }
    }
    
    func setLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest  // 배터리 최적화
        locationManager.delegate = self
    }
    
    func showRequestLocationServiceAlert() {
        let requestLocationServiceAlert = UIAlertController(title: "위치 정보 이용", message: "위치 서비스를 사용할 수 없습니다.\n디바이스의 '설정 > 개인정보 보호'에서 위치 서비스를 켜주세요.", preferredStyle: .alert)
        let presentSettings = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
            if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSetting)
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        requestLocationServiceAlert.addAction(cancel)
        requestLocationServiceAlert.addAction(presentSettings)
        
        present(requestLocationServiceAlert, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate

extension MainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("GPS 권한설정 허용됨")
            locationManager.startUpdatingLocation()
            mapView.showCurrentLocationMarker = true
            mapView.currentLocationTrackingMode = .onWithHeading
            mapView.showCurrentLocationMarker = true
            mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude ?? 37.576568, longitude: longtitude ?? 127.029148)), animated: true)
            
        case .restricted, .notDetermined:
            print("GPS 권한설정 X")
            locationManager.requestWhenInUseAuthorization()
            
        case .denied:
            print("GPS 권한설정 거부됨")
            showRequestLocationServiceAlert()
        default:
            print("요청")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation: CLLocation = locations[locations.count-1]
        longtitude = currentLocation.coordinate.longitude.significand
        latitude = currentLocation.coordinate.latitude.significand
        mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude ?? 37.576568, longitude: longtitude ?? 127.029148)), animated: true)
    }
    
}

// MARK: - MTMapViewDelegate

extension MainViewController: MTMapViewDelegate {
    
}
