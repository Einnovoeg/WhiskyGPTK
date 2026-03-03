//
//  WhiskyGlass.swift
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
    func whiskyWindowBackground() -> some View {
        modifier(WhiskyWindowBackground())
    }

    func whiskyGlassCard(cornerRadius: CGFloat = 22) -> some View {
        modifier(WhiskyGlassCard(cornerRadius: cornerRadius))
    }
}

private struct WhiskyWindowBackground: ViewModifier {
    @AppStorage("useGlassUI") private var useGlassUI = false

    func body(content: Content) -> some View {
        if useGlassUI {
            content
                .background {
                    ZStack {
                        Rectangle()
                            .fill(.regularMaterial)
                            .ignoresSafeArea()

                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.accentColor.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()

                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 400, height: 400)
                            .blur(radius: 60)
                            .offset(x: -180, y: -140)

                        Circle()
                            .fill(Color.accentColor.opacity(0.20))
                            .frame(width: 350, height: 350)
                            .blur(radius: 60)
                            .offset(x: 200, y: 160)
                    }
                }
        } else {
            content
        }
    }
}

private struct WhiskyGlassCard: ViewModifier {
    @AppStorage("useGlassUI") private var useGlassUI = false
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if useGlassUI {
            content
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.20), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 10)
        } else {
            content
        }
    }
}
