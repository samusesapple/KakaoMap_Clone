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
        button.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
        button.setImage(UIImage(systemName: "chevron.left"), for: .selected)
        return button
    }()
    
    private let searchBar: UISearchBar = {
       let sb = UISearchBar()
        sb.searchBarStyle = .minimal
        sb.autocapitalizationType = .none
        sb.autocorrectionType = .no
        sb.setImage(UIImage(), for: .search, state: .normal)
        sb.searchTextField.borderStyle = .line
        sb.searchTextField.textAlignment = .left
        sb.searchTextField.backgroundColor = .white
        sb.searchTextField.textColor = .black
        sb.searchTextField.tintColor = .systemBlue
        return sb
    }()
    
    // MARK: - Lifecycle
    
    init(placeholder: String) {
        super.init(frame: .zero)
        
        self.layer.cornerRadius = 4
        
        backgroundColor = .white
        setupShadow(opacity: 0.2, radius: 1.5, offset: CGSize(width: 1.0, height: 0.5), color: .black)
        searchBar.placeholder = placeholder
        
        setAutolayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func setAutolayout() {
        addSubview(menuButton)
        menuButton.anchor(left: self.leftAnchor, paddingLeft: 10)
        menuButton.centerY(inView: self)
        
        addSubview(searchBar)
        searchBar.anchor(left: menuButton.rightAnchor, right: self.rightAnchor, paddingLeft: 0, paddingRight: 10)
        searchBar.centerY(inView: self)
    }
    
    func getMenuButton() -> UIButton {
        return menuButton
    }
    
    func getSearchBar() -> UISearchBar {
        return searchBar
    }
}
