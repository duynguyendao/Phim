//
//  ContentView.swift
//  Phim
//
//  Created on 2026
//

import SwiftUI
import WebKit

struct ContentView: View {
    @State private var isLoading = true
    @State private var canGoBack = false
    @State private var canGoForward = false
    
    var body: some View {
        NavigationView {
            ZStack {
                WebView(
                    url: URL(string: "https://tvhayd.pro/")!,
                    isLoading: $isLoading,
                    canGoBack: $canGoBack,
                    canGoForward: $canGoForward
                )
                
                if isLoading {
                    ProgressView("Đang tải...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                }
            }
            .navigationTitle("Phim")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        NotificationCenter.default.post(name: NSNotification.Name("WebViewGoBack"), object: nil)
                    }) {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(!canGoBack)
                    
                    Spacer()
                    
                    Button(action: {
                        NotificationCenter.default.post(name: NSNotification.Name("WebViewGoForward"), object: nil)
                    }) {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(!canGoForward)
                    
                    Spacer()
                    
                    Button(action: {
                        NotificationCenter.default.post(name: NSNotification.Name("WebViewReload"), object: nil)
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if let url = URL(string: "https://tvhayd.pro/") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Image(systemName: "safari")
                    }
                }
            }
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        // Đăng ký notifications
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.goBack),
            name: NSNotification.Name("WebViewGoBack"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.goForward),
            name: NSNotification.Name("WebViewGoForward"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.reload),
            name: NSNotification.Name("WebViewReload"),
            object: nil
        )
        
        context.coordinator.webView = webView
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Không cần update
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        weak var webView: WKWebView?
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            parent.canGoBack = webView.canGoBack
            parent.canGoForward = webView.canGoForward
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
        
        @objc func goBack() {
            webView?.goBack()
        }
        
        @objc func goForward() {
            webView?.goForward()
        }
        
        @objc func reload() {
            webView?.reload()
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
