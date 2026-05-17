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
        
        // Thêm ad blocker
        setupAdBlocker(configuration: configuration)
        
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
    
    // MARK: - Ad Blocker
    private func setupAdBlocker(configuration: WKWebViewConfiguration) {
        let blockRules = """
        [
            {
                "trigger": {
                    "url-filter": ".*",
                    "resource-type": ["script", "image"],
                    "if-domain": ["*doubleclick.net", "*googlesyndication.com", "*googleadservices.com", "*google-analytics.com", "*googletagmanager.com", "*facebook.net", "*facebook.com", "*ads*.com", "*adservice*", "*advertising*", "*analytics*", "*tracker*", "*banner*", "*popup*"]
                },
                "action": {
                    "type": "block"
                }
            },
            {
                "trigger": {
                    "url-filter": ".*",
                    "resource-type": ["popup"]
                },
                "action": {
                    "type": "block"
                }
            },
            {
                "trigger": {
                    "url-filter": ".*",
                    "if-domain": ["*ad-*.com", "*ads-*.com", "*adserver*.com", "*adsystem*.com"]
                },
                "action": {
                    "type": "block"
                }
            }
        ]
        """
        
        WKContentRuleListStore.default().compileContentRuleList(
            forIdentifier: "ContentBlockingRules",
            encodedContentRuleList: blockRules
        ) { contentRuleList, error in
            if let contentRuleList = contentRuleList {
                configuration.userContentController.add(contentRuleList)
            }
            if let error = error {
                print("Error compiling content blocking rules: \(error.localizedDescription)")
            }
        }
        
        // Thêm CSS để ẩn các element quảng cáo phổ biến
        let cssHideAds = """
        var style = document.createElement('style');
        style.innerHTML = `
            [class*="ad-"], [class*="ads-"], [id*="ad-"], [id*="ads-"],
            [class*="banner"], [id*="banner"],
            [class*="popup"], [id*="popup"],
            [class*="sponsor"], [id*="sponsor"],
            iframe[src*="ads"], iframe[src*="doubleclick"],
            .advertisement, .ad-container, .ads-container,
            .google-ad, .adsbygoogle {
                display: none !important;
                visibility: hidden !important;
                opacity: 0 !important;
                height: 0 !important;
                width: 0 !important;
            }
        `;
        document.head.appendChild(style);
        """
        
        let hideAdsScript = WKUserScript(
            source: cssHideAds,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        configuration.userContentController.addUserScript(hideAdsScript)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
