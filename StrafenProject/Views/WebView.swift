//
//  WebView.swift
//  StrafenProject
//
//  Created by Steven on 02.07.23.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    
    private let url: URL
    
    init(url: URL ) {
        self.url = url
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.load(URLRequest(url: self.url))
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}
}
