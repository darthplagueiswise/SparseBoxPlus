//
//  FilesystemView.swift
//  SparseBoxPlus
//
//  Created by Main on 1/14/26.
//

import SwiftUI
import PartyUI

struct FilesystemView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "Tools", icon: "wrench.and.screwdriver")) {
                    NavigationLink(destination: AppListView()) {
                        ButtonLabel(text: "List Installed Apps", icon: "app")
                    }
                    NavigationLink(destination: BrowseFSView()) {
                        ButtonLabel(text: "Browse Photos Domain", icon: "camera")
                    }
                    NavigationLink(destination: GestaltDataView()) {
                        ButtonLabel(text: "View MobileGestalt Data", icon: "doc")
                    }
                }
            }
            .navigationTitle("Filesystem")
        }
    }
}
