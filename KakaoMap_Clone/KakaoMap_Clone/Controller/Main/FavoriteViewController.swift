//
//  FavoriteViewController.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/14.
//

import UIKit

class FavoriteViewController: UIViewController {

    // MARK: - Properties
    
    var viewModel: FavoriteViewModel!
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .white
        tv.rowHeight = view.frame.height / 10
        tv.register(FavoriteViewTableViewCell.self, forCellReuseIdentifier: "favoriteCell")
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "즐겨찾기"
        self.navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.tintColor = .black
        
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor,
                         bottom: view.bottomAnchor,
                         right: view.rightAnchor)
        
        viewModel.needToReloadTableView = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    // MARK: - Actions
    
    @objc private func dismissSelf() {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Helpers
    
}

// MARK: - UITableViewDelegate

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.placeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath) as! FavoriteViewTableViewCell
        cell.viewModel = self.viewModel
        cell.configureUIwithData(viewModel.placeList[indexPath.row])

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}