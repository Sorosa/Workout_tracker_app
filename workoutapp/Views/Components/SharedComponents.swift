//
//  SharedComponents.swift
//  workoutapp
//
//  Created by Codex on 20/04/2026.
//

import SwiftUI

struct SurfaceCard<Content: View>: View {
    let theme: AppPalette
    var stroke: Color?
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(18)
            .background(theme.elevatedSurface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(stroke ?? theme.border, lineWidth: 1)
            )
    }
}

struct AppPill: View {
    let text: String
    let foreground: Color
    let background: Color

    var body: some View {
        Text(text)
            .font(.caption2.monospaced())
            .foregroundStyle(foreground)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(background, in: Capsule())
    }
}

struct AppMetricCard: View {
    let label: String
    let value: String
    let accent: Color
    let theme: AppPalette

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(accent)
            Text(label)
                .font(.caption2.monospaced())
                .textCase(.uppercase)
                .tracking(1.2)
                .foregroundStyle(theme.mutedText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(accent.opacity(0.16), lineWidth: 1)
        )
    }
}
