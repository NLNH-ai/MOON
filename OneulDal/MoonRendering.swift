import SwiftUI

struct MoonLightDirection: Equatable {
    let horizontal: Float
    let depth: Float
}

enum MoonLightingGeometry {
    static func lightDirection(illumination: Int, isWaxing: Bool) -> MoonLightDirection {
        let fraction = Float(min(max(illumination, 0), 100)) / 100
        let depth = (2 * fraction) - 1
        let horizontalMagnitude = sqrt(max(0, 1 - (depth * depth)))

        return MoonLightDirection(
            horizontal: isWaxing ? horizontalMagnitude : -horizontalMagnitude,
            depth: depth
        )
    }
}

struct RealisticMoonView: View {
    let illumination: Int
    let isWaxing: Bool
    let size: CGFloat

    private var lightDirection: MoonLightDirection {
        MoonLightingGeometry.lightDirection(
            illumination: illumination,
            isWaxing: isWaxing
        )
    }

    var body: some View {
        moonTexture
            .saturation(0.78)
            .contrast(1.02)
            .layerEffect(
                ShaderLibrary.moonSphereLighting(
                    .float2(CGSize(width: size, height: size)),
                    .float(lightDirection.horizontal),
                    .float(lightDirection.depth)
                ),
                maxSampleOffset: .zero
            )
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.moonGold.opacity(0.14), lineWidth: 1)
            )
            .shadow(color: Color.moonGold.opacity(0.12), radius: 18, x: 0, y: 8)
            .accessibilityHidden(true)
    }

    private var moonTexture: some View {
        Image("MoonSurface")
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .scaleEffect(MoonLayout.moonSurfaceScale)
            .offset(y: size * MoonLayout.moonSurfaceOffsetYRatio)
            .clipped()
    }
}
