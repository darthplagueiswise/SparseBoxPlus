//
//  SettingsView.swift
//  SparseBoxPlus
//
//  Created by Main on 1/7/26.
//

import SwiftUI
import PartyUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "About", icon: "info.circle")) {
                    VStack(spacing: 12) {
                        AppInfoCell(imageName: "SparseBoxPlus", title: "SparseBox+", subtitle: "Version \(UIApplication.appVersion ?? "0.0") (\(weOnADebugBuild ? "Debug" : "Release"))")
                        Button(action: {
                            Haptic.shared.play(.soft)
                            openURL(URL(string: "https://jailbreak.party")!)
                        }) {
                            ButtonLabel(text: "Website", icon: "globe")
                        }
                        .buttonStyle(GlassyButtonStyle(color: .blue))
                        HStack {
                            Button(action: {
                                Haptic.shared.play(.soft)
                                openURL(URL(string: "https://jailbreak.party/discord")!)
                            }) {
                                ButtonLabel(text: "Discord", icon: "discord", isRegularImage: true)
                            }
                            .buttonStyle(GlassyButtonStyle(color: .discord))
                            Button(action: {
                                Haptic.shared.play(.soft)
                                openURL(URL(string: "https://github.com/jailbreakdotparty/dirtyZero")!)
                            }) {
                                ButtonLabel(text: "GitHub", icon: "github", isRegularImage: true)
                            }
                            .buttonStyle(GlassyButtonStyle(color: .gitHub))
                        }
                    }
                }
                /*
                 A terrible app by @khanhduytran0. Use it at your own risk.
                 Thanks to:
                 @SideStore team: idevice, C bindings from StikDebug
                 @JJTech0130: SparseRestore and backup exploit
                 @hanakim3945: bl_sbx exploit files and writeup
                 @PoomSmart: MobileGestalt dump
                 @Lakr233: BBackupp
                 @libimobiledevice
                 */
                Section(header: HeaderLabel(text: "Credits", icon: "person")) {
                    LinkCreditCell(image: "duyTran", name: "Duy Tran (@khanhduytran0)", text: "Original project creator", link: "https://github.com/khanhduytran0")
                    LinkCreditCell(image: "lunginspector", name: "lunginspector (jbdotparty)", text: "All improvements for SparseBox+", link: "https://github.com/lunginspector")
                    LinkCreditCell(image: "sidestore", name: "SideStore Team", text: "idevice, C bindings from StikDebug", link: "https://github.com/sidestore")
                    LinkCreditCell(image: "jjtech", name: "JJTech", text: "SparseRestore and backup exploit", link: "https://github.com/JJTech0130")
                    LinkCreditCell(image: "hanakim3945", name: "hanakim3945", text: "BookRestore exploit files and writeup", link: "https://github.com/hanakim3945")
                    LinkCreditCell(image: "poomsmart", name: "PoomSmart", text: "MobileGestalt keys dump", link: "https://github.com/poomsmart")
                    LinkCreditCell(image: "lakr233", name: "Lakr233", text: "BBackup", link: "https://github.com/Lakr233")
                    LinkCreditCell(image: "libimobiledevice", name: "libimobileDevice", text: "libimobiledevice", link: "https://github.com/libimobiledevice")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
