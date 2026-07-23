//
//  AboutView.swift
//  DayBar
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 64, height: 64)
                
                Image(systemName: "calendar")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .foregroundColor(.accentColor)
            }
            
            VStack(spacing: 4) {
                Text("DayBar")
                    .font(.system(size: 18, weight: .bold))
                
                Text("Version 1.0.0")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Text("A clean, compact macOS menu-bar clock and calendar replacement.")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
            
            Divider()
            
            Text("© 2026 Stephen M. Walker II")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .frame(width: 280)
    }
}
