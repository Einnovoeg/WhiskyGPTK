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

struct WhiskyGlassBadge: View {
    @AppStorage("useGlassUI") private var useGlassUI = true
    let icon: String
    let title: String
    var tint: Color = .accentColor

    var body: some View {
        Label {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
        } icon: {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(tint)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            if useGlassUI {
                Capsule(style: .continuous)
                    .fill(.thinMaterial)
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    }
            } else {
                Capsule(style: .continuous)
                    .fill(Color.secondary.opacity(0.10))
            }
        }
    }
}

private struct WhiskyWindowBackground: ViewModifier {
    @AppStorage("useGlassUI") private var useGlassUI = true

    func body(content: Content) -> some View {
        if useGlassUI {
            content
                .background {
                    ZStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.10, green: 0.11, blue: 0.14),
                                        Color(red: 0.19, green: 0.22, blue: 0.28),
                                        Color(red: 0.13, green: 0.16, blue: 0.20)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .ignoresSafeArea()

                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.10),
                                Color.clear,
                                Color.accentColor.opacity(0.20)
                            ],
                            startPoint: .top,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()

                        Circle()
                            .fill(Color.white.opacity(0.14))
                            .frame(width: 520, height: 520)
                            .blur(radius: 72)
                            .offset(x: -240, y: -220)

                        Circle()
                            .fill(Color.accentColor.opacity(0.26))
                            .frame(width: 420, height: 420)
                            .blur(radius: 72)
                            .offset(x: 260, y: 200)

                        RoundedRectangle(cornerRadius: 42, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                            .padding(16)
                            .ignoresSafeArea()
                    }
                }
        } else {
            content
        }
    }
}

private struct WhiskyGlassCard: ViewModifier {
    @AppStorage("useGlassUI") private var useGlassUI = true
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if useGlassUI {
            content
                .padding(16)
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
                }
                .overlay(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.16),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                        .blendMode(.screen)
                }
                .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 16)
        } else {
            content
        }
    }
}
