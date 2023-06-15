//
//  DetailViewController.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/28.
//

import UIKit
import WebKit
import JGProgressHUD

final class DetailViewController: UIViewController {

    // MARK: - Properties
    
    private let webView = WKWebView()
    
    private let url: URL?
    
    private let progressHud = JGProgressHUD(style: .dark)
    
    // MARK: - Lifecycle
    
    init(url: String) {
        self.url = URL(string: url)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setAutolayout()
        configureWebview()
    }
    
    // MARK: - Helpers
    
    private func setAutolayout() {
        view.addSubview(webView)
        webView.setDimensions(height: view.frame.height, width: view.frame.width)
    }

    private func configureWebview() {
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        guard let url = url else { return }
        
        let request = URLRequest(url: url)
        webView.load(request)
        progressHud.show(in: webView)
    }
}

// MARK: - WKUIDelegate & WKNavigationDelegate

extension DetailViewController: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressHud.dismiss()
    }
}
