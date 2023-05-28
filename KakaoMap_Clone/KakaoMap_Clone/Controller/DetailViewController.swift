//
//  DetailViewController.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/28.
//

import UIKit
import WebKit
import JGProgressHUD

class DetailViewController: UIViewController {

    // MARK: - Properties
    
    private let webView = WKWebView()
    
    private let request: URLRequest?
    
    private let progressHud = JGProgressHUD(style: .dark)
    
    // MARK: - Lifecycle
    
    init(url: String) {
        let url = URL(string: url)!
        self.request = URLRequest(url: url)
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
        DispatchQueue.main.async { [weak self] in
            guard let request = self?.request,
                  let webView = self?.webView else { return }
            self?.webView.load(request)
            self?.progressHud.show(in: webView)
        }
    }
}

// MARK: - WKUIDelegate

extension DetailViewController: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async { [weak self] in
            self?.progressHud.dismiss()
        }
    }
}
