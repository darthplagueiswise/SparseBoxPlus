//
//  TweaksView.swift
//  SparseBoxPlus
//
//  Created by Main on 1/14/26.
//

import SwiftUI
import PartyUI

// note that this will not be used for the time being.
struct TweaksView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "Tweaks", icon: "wrench.and.screwdriver")) {
                    NavigationLink("MobileGestalt Tweaks", destination: GestaltTweaksView())
                }
            }
        }
    }
}
