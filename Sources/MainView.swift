//
//  MainView.swift
//  SparseBoxPlus
//
//  Created by Main on 1/8/26.
//

import SwiftUI

// thanks for the christmas present skadz108

internal enum SelectableTab: Int, CaseIterable {
    case apply, tweaks, appList
}

struct MainView: View {
    @EnvironmentObject var appData: AppData
    @State public var selectedTab: SelectableTab = .apply
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ApplyView()
                .tabItem { Label("Apply", systemImage: "house") }
                .tag(SelectableTab.apply)
            TweaksView()
                .tabItem { Label("Tweaks", systemImage: "wrench.and.screwdriver")}
                .tag(SelectableTab.tweaks)
            AppListView()
                .tabItem { Label("Applist", systemImage: "checklist")}
                .tag(SelectableTab.appList)
        }
        .overlay(alignment: .bottom) {
            if doubleSystemVersion() < 26.0 {
                let color = Color.accentColor
                GeometryReader { geometry in
                    let aThird = geometry.size.width / 3
                    VStack {
                        Spacer()
                        Circle()
                            .background(color.blur(radius: 20))
                            .frame(width: aThird, height: 30)
                            .shadow(color: color, radius: 40)
                            .offset(
                                x: CGFloat(selectedTab.rawValue) * aThird,
                                y: 30
                            )
                    }
                    .animation(.spring(response: 0.45, dampingFraction: 0.6), value: selectedTab)
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    MainView()
        .environmentObject(AppData())
}
