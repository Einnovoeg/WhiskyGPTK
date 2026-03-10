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

enum WhiskyBrandPalette {
    static let amber = Color(red: 0.95, green: 0.63, blue: 0.24)
    static let copper = Color(red: 0.79, green: 0.30, blue: 0.15)
    static let gold = Color(red: 0.98, green: 0.81, blue: 0.49)
    static let smoke = Color(red: 0.07, green: 0.08, blue: 0.10)
    static let slate = Color(red: 0.15, green: 0.17, blue: 0.21)
    static let mist = Color(red: 0.94, green: 0.97, blue: 1.00)
}

struct WhiskyBrandIcon: View {
    var size: CGFloat = 64

    var body: some View {
        Image("BrandMark")
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.26), radius: size * 0.18, x: 0, y: size * 0.09)
    }
}

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
                .minimumScaleFactor(0.8)
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
                    .overlay {
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        WhiskyBrandPalette.gold.opacity(0.08),
                                        Color.clear,
                                        WhiskyBrandPalette.copper.opacity(0.12)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
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
                                        WhiskyBrandPalette.smoke,
                                        WhiskyBrandPalette.slate,
                                        Color(red: 0.27, green: 0.14, blue: 0.11)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .ignoresSafeArea()

                        LinearGradient(
                            colors: [
                                WhiskyBrandPalette.gold.opacity(0.20),
                                Color.clear,
                                WhiskyBrandPalette.copper.opacity(0.24)
                            ],
                            startPoint: .top,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()

                        Circle()
                            .fill(WhiskyBrandPalette.gold.opacity(0.16))
                            .frame(width: 520, height: 520)
                            .blur(radius: 72)
                            .offset(x: -240, y: -220)

                        Circle()
                            .fill(WhiskyBrandPalette.copper.opacity(0.28))
                            .frame(width: 420, height: 420)
                            .blur(radius: 72)
                            .offset(x: 260, y: 200)

                        Circle()
                            .fill(WhiskyBrandPalette.amber.opacity(0.14))
                            .frame(width: 320, height: 320)
                            .blur(radius: 56)
                            .offset(x: -280, y: 240)

                        RoundedRectangle(cornerRadius: 90, style: .continuous)
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 520, height: 180)
                            .blur(radius: 32)
                            .rotationEffect(.degrees(-18))
                            .offset(x: 170, y: -150)

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
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    WhiskyBrandPalette.gold.opacity(0.10),
                                    Color.clear,
                                    WhiskyBrandPalette.copper.opacity(0.10)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .overlay(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.18),
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
