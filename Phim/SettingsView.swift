//
//  SettingsView.swift
//  Phim
//
//  Created on 2026
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("adBlockEnabled") private var adBlockEnabled = true
    @AppStorage("autoPlayEnabled") private var autoPlayEnabled = true
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Tính năng")) {
                    Toggle(isOn: $adBlockEnabled) {
                        HStack {
                            Image(systemName: "shield.fill")
                                .foregroundColor(.blue)
                            Text("Chặn quảng cáo")
                        }
                    }
                    
                    Toggle(isOn: $autoPlayEnabled) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .foregroundColor(.green)
                            Text("Tự động phát video")
                        }
                    }
                }
                
                Section(header: Text("Thông tin")) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.orange)
                        Text("Phiên bản")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Image(systemName: "link.circle.fill")
                            .foregroundColor(.purple)
                        Text("Website")
                        Spacer()
                        Text("tvhayd.pro")
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Hỗ trợ")) {
                    Button(action: {
                        if let url = URL(string: "https://github.com/duynguyendao/Phim") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Đánh giá trên GitHub")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://github.com/duynguyendao/Phim/issues") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "exclamationmark.bubble.fill")
                                .foregroundColor(.red)
                            Text("Báo lỗi")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Cài đặt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Xong") {
                        dismiss()
                    }
                }
            }
        }
    }
}
