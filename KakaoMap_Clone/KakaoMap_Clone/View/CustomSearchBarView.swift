//
//  CustomSearchBar.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/23.
//

import UIKit

class CustomSearchBarView: UIView {
    
    // MARK: - Properties
    
    private let menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .black
        button.setImage(UIImage(named: "menu")?.withRenderingMode(.alwaysTemplate)
            .resizeImage(targetSize: CGSize(width: 30, height: 30)), for: .normal)
        return button
    }()
    
    private let searchBar: UISearchBar = {
       let sb = UISearchBar()
        sb.searchBarStyle = .minimal
        sb.autocapitalizationType = .none
        sb.autocorrectionType = .no
        sb.setImage(UIImage(), for: .search, state: .normal)
        sb.searchTextField.borderStyle = .none
        sb.searchTextField.textAlignment = .left
        sb.searchTextField.backgroundColor = .white
        sb.searchTextField.textColor = .black
        sb.searchTextField.tintColor = .systemBlue
        return sb
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .black.withAlphaComponent(0.8)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    
    init(placeholder: String?, needBorderLine: Bool, needCancelButton: Bool = false, isDetailView: Bool = false) {
        super.init(frame: .zero)
        
        self.layer.cornerRadius = 4
        
        backgroundColor = .white
        setupShadow(opacity: 0.2, radius: 1.5, offset: CGSize(width: 1.0, height: 0.5), color: .black)
        searchBar.placeholder = placeholder
        
        setAutolayout(needCancelButton: needCancelButton)
        
        if !isDetailView {
            if needBorderLine && !needCancelButton {
                setBorderLine(needCancelButton: needCancelButton, isDetailView: false)
            } else if needBorderLine && needCancelButton {
                setBorderLine(needCancelButton: needCancelButton, isDetailView: false)
            }
        } else {
            setBorderLine(needCancelButton: needCancelButton, isDetailView: isDetailView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func setAutolayout(needCancelButton: Bool) {
        addSubview(menuButton)
        menuButton.centerY(inView: self)
        
        if !needCancelButton {
            menuButton.anchor(left: self.leftAnchor, paddingLeft: 10)
            
            addSubview(searchBar)
            searchBar.anchor(left: menuButton.rightAnchor, right: self.rightAnchor, paddingLeft: 0, paddingRight: 10)
            searchBar.centerY(inView: self)
        } else {
            menuButton.anchor(left: self.leftAnchor, paddingLeft: 0)
            
            addSubview(cancelButton)
            cancelButton.anchor(right: self.rightAnchor, paddingRight: 0)
            cancelButton.centerY(inView: self)
            
            addSubview(searchBar)
            searchBar.anchor(top: topAnchor, left: menuButton.rightAnchor, bottom: bottomAnchor, right: cancelButton.leftAnchor, paddingLeft: 10, paddingRight: 20)
            searchBar.centerY(inView: self)
        }
    }

    private func setBorderLine(needCancelButton: Bool, isDetailView: Bool) {
        if !needCancelButton {
            clipsToBounds = true
            layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
            layer.borderWidth = 1
            menuButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        } else {
            clipsToBounds = true
            searchBar.clipsToBounds = true
            searchBar.layer.cornerRadius = 4
            searchBar.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
            searchBar.layer.borderWidth = 1
            searchBar.searchTextField.clearButtonMode = .never
            menuButton.tintColor = #colorLiteral(red: 0.03529411765, green: 0.5176470588, blue: 0.8901960784, alpha: 1)
            if !isDetailView {
                menuButton.setImage(UIImage(named: "map")?.withRenderingMode(.alwaysTemplate)
                    .resizeImage(targetSize: CGSize(width: 30, height: 30)), for: .normal)
            } else if isDetailView {
                menuButton.setImage(UIImage(named: "menu")?.withRenderingMode(.alwaysTemplate)
                    .resizeImage(targetSize: CGSize(width: 30, height: 30)), for: .normal)
            }
        }
    }
    
    func getMenuButton() -> UIButton {
        return menuButton
    }
    
    func getSearchBar() -> UISearchBar {
        return searchBar
    }
    
    func getCancelButton() -> UIButton {
        return cancelButton
    }
    
}
