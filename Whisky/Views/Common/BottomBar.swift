//
//  BottomBar.swift
//  Whisky
//
//  This file is part of Whisky.
//
//  Whisky is free software: you can redistribute it and/or modify it under the terms
//  of the GNU General Public License as published by the Free Software Foundation,
//  either version 3 of the License, or (at your option) any later version.
//
//  Whisky is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
//  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//  See the GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along with Whisky.
//  If not, see https://www.gnu.org/licenses/.
//

import SwiftUI

extension View {
    func bottomBar<Content>(
        @ViewBuilder content: () -> Content
    ) -> some View where Content: View {
        modifier(BottomBarViewModifier(barContent: content()))
    }
}

private struct BottomBarViewModifier<BarContent>: ViewModifier where BarContent: View {
    @AppStorage("useGlassUI") private var useGlassUI = true
    var barContent: BarContent

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Group {
                    if useGlassUI {
                        barContent
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                            }
                            .shadow(color: .black.opacity(0.16), radius: 24, x: 0, y: 12)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                    } else {
                        VStack(spacing: 0) {
                            Divider()
                            barContent
                        }
                        .background(.regularMaterial)
                    }
                }
                .buttonStyle(BottomBarButtonStyle())
            }
    }
}

struct BottomBarButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.trigger()
        } label: {
            configuration.label
                .foregroundStyle(.foreground)
        }
    }
}

#Preview {
    Form {
        Text(String("Hello World"))
    }
    .formStyle(.grouped)
    .bottomBar {
        HStack {
            Spacer()
            Button {
            } label: {
                Text(String("Button 1"))
            }
            Button {
            } label: {
                Text(String("Button 2"))
            }
        }
        .padding()
    }
}
