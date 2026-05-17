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
    @State private var showSettings = false
    @State private var showMenu = false
    @AppStorage("adBlockEnabled") private var adBlockEnabled = true
    
    var body: some View {
        NavigationView {
            ZStack {
                // WebView
                WebView(
                    url: URL(string: "https://tvhayd.pro/")!,
                    isLoading: $isLoading,
                    canGoBack: $canGoBack,
                    canGoForward: $canGoForward,
                    adBlockEnabled: $adBlockEnabled
                )
                
                // Loading indicator
                if isLoading {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Text("Đang tải...")
                            .foregroundColor(.white)
                            .padding(.top, 10)
                    }
                    .padding(30)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(15)
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.spring()) {
                                showMenu.toggle()
                            }
                        }) {
                            Image(systemName: showMenu ? "xmark" : "line.3.horizontal")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.red, Color.purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                }
                
                // Menu overlay
                if showMenu {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            VStack(spacing: 15) {
                                MenuButton(icon: "house.fill", title: "Trang chủ", color: .blue) {
                                    NotificationCenter.default.post(name: NSNotification.Name("WebViewGoHome"), object: nil)
                                    showMenu = false
                                }
                                
                                MenuButton(icon: "arrow.clockwise", title: "Tải lại", color: .green) {
                                    NotificationCenter.default.post(name: NSNotification.Name("WebViewReload"), object: nil)
                                    showMenu = false
                                }
                                
                                MenuButton(icon: "safari", title: "Safari", color: .orange) {
                                    if let url = URL(string: "https://tvhayd.pro/") {
                                        UIApplication.shared.open(url)
                                    }
                                    showMenu = false
                                }
                                
                                MenuButton(icon: "gearshape.fill", title: "Cài đặt", color: .gray) {
                                    showSettings = true
                                    showMenu = false
                                }
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 170)
                        }
                    }
                    .transition(.scale)
                }
            }
            .navigationTitle("🎬 Phim")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    HStack(spacing: 15) {
                        Button(action: {
                            NotificationCenter.default.post(name: NSNotification.Name("WebViewGoBack"), object: nil)
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(canGoBack ? .primary : .gray)
                        }
                        .disabled(!canGoBack)
                        
                        Button(action: {
                            NotificationCenter.default.post(name: NSNotification.Name("WebViewGoForward"), object: nil)
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(canGoForward ? .primary : .gray)
                        }
                        .disabled(!canGoForward)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}

struct MenuButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(color)
                    .clipShape(Circle())
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(20)
            }
            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var adBlockEnabled: Bool
    
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
        
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.goHome),
            name: NSNotification.Name("WebViewGoHome"),
            object: nil
        )
        
        context.coordinator.webView = webView
        context.coordinator.homeURL = url
        
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
        var homeURL: URL?
        
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
        
        @objc func goHome() {
            if let homeURL = homeURL {
                let request = URLRequest(url: homeURL)
                webView?.load(request)
            }
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
