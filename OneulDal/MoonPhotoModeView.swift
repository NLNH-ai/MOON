import SwiftUI
import UIKit

struct MoonPhotoModeView: View {
    let day: MoonDay
    let locationName: String

    @Environment(\.dismiss) private var dismiss
    @State private var shareURL: URL?

    var body: some View {
        ZStack {
            MoonBackground()

            VStack(spacing: 18) {
                toolbar

                Spacer(minLength: 8)

                RealisticMoonView(
                    illumination: day.illumination,
                    isWaxing: day.isWaxing,
                    size: 300
                )
                .frame(maxWidth: .infinity, alignment: .center)

                VStack(spacing: 8) {
                    Text(day.phaseNameKo)
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.moonText)
                        .multilineTextAlignment(.center)

                    Text("\(day.dateTitle) · \(locationName)")
                        .font(.headline.weight(.medium))
                        .foregroundStyle(Color.moonSubtext)

                    Text("\(day.brightnessText) · \(day.moonAgeText)")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.moonGold)
                }

                Spacer()

                Text("오늘달")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.moonSubtext.opacity(0.72))
            }
            .padding(.horizontal, 22)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
        .task {
            shareURL = renderShareImage()
        }
    }

    private var toolbar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline.weight(.bold))
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .accessibilityLabel("사진 모드 닫기")

            Spacer()

            if let shareURL {
                ShareLink(
                    item: shareURL,
                    preview: SharePreview("\(day.dateTitle) 오늘달", image: Image("MoonSurface"))
                ) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.headline.weight(.bold))
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .accessibilityLabel("달 사진 공유")
            } else {
                ProgressView()
                    .frame(width: 44, height: 44)
                    .accessibilityLabel("공유 이미지 준비 중")
            }
        }
        .foregroundStyle(Color.moonText)
    }

    @MainActor
    private func renderShareImage() -> URL? {
        let content = MoonShareCard(day: day, locationName: locationName)
            .frame(width: 1080, height: 1350)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 1

        guard
            let image = renderer.uiImage,
            let data = image.pngData()
        else { return nil }

        let fileName = "oneuldal-\(Int(day.date.timeIntervalSince1970)).png"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }
}

private struct MoonShareCard: View {
    let day: MoonDay
    let locationName: String

    var body: some View {
        ZStack {
            Color.moonBackground

            RadialGradient(
                colors: [Color.moonGold.opacity(0.14), .clear],
                center: .topTrailing,
                startRadius: 30,
                endRadius: 760
            )

            VStack(spacing: 46) {
                HStack {
                    Text(locationName)
                    Spacer()
                    Text(day.dateTitle)
                }
                .font(.system(size: 38, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.moonSubtext)

                Spacer(minLength: 0)

                RealisticMoonView(
                    illumination: day.illumination,
                    isWaxing: day.isWaxing,
                    size: 700
                )

                VStack(spacing: 18) {
                    Text(day.phaseNameKo)
                        .font(.system(size: 72, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.moonText)

                    Text("\(day.brightnessText) · \(day.moonAgeText)")
                        .font(.system(size: 38, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.moonGold)
                }

                Spacer(minLength: 0)

                Text("오늘달")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.moonSubtext)
            }
            .padding(74)
        }
    }
}
