import SwiftUI

struct MoonNotificationsView: View {
    @State private var fullMoonEnabled = true
    @State private var newMoonEnabled = false
    @State private var quartersEnabled = false
    @State private var moonriseEnabled = false
    @State private var showingPermissionPreview = false

    var body: some View {
        NavigationStack {
            ZStack {
                MoonBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        statusStrip
                        reminderList
                        permissionCard
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 20)
                    .padding(.bottom, 34)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .alert("알림 권한 안내", isPresented: $showingPermissionPreview) {
                Button("확인", role: .cancel) {}
            } message: {
                Text("실제 앱에서는 사용자가 알림을 켤 때만 iOS 알림 권한을 요청합니다.")
            }
        }
    }

    private var enabledCount: Int {
        [fullMoonEnabled, newMoonEnabled, quartersEnabled, moonriseEnabled].filter { $0 }.count
    }

    private var header: some View {
        ScreenHeader(
            title: "알림",
            eyebrow: "달 알림",
            subtitle: "보름과 월출처럼 놓치기 쉬운 밤만 골라 챙겨요."
        ) {
            MoonChip("\(enabledCount)개 켜짐", symbolName: "bell.badge.fill", tint: Color.moonGold)
        }
    }

    private var statusStrip: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 8)], spacing: 8) {
            ReminderStatusMetric(symbol: "moon.stars.fill", title: "주요 위상", value: fullMoonEnabled ? "대기 중" : "꺼짐")
            ReminderStatusMetric(symbol: "hand.raised.fill", title: "권한", value: "켤 때 요청", tint: Color.moonAqua)
            ReminderStatusMetric(symbol: "speaker.wave.2.fill", title: "소리", value: "조용히", tint: Color.moonSubtext)
        }
    }

    private var reminderList: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    Text("받을 알림")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.moonText)

                    Spacer()

                    Text("사용자가 켠 항목만")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.moonSubtext)
                }

                NotificationToggleRow(
                    title: "보름달",
                    subtitle: "3일 전, 1일 전, 정각",
                    symbol: "moon.circle.fill",
                    isOn: $fullMoonEnabled
                )

                NotificationToggleRow(
                    title: "삭",
                    subtitle: "별 관측하기 좋은 밤",
                    symbol: "circle",
                    isOn: $newMoonEnabled
                )

                NotificationToggleRow(
                    title: "상현 · 하현",
                    subtitle: "한 달 흐름을 놓치지 않게",
                    symbol: "moonphase.first.quarter",
                    isOn: $quartersEnabled
                )

                NotificationToggleRow(
                    title: "월출",
                    subtitle: "달이 뜨기 1시간 전",
                    symbol: "arrow.up.circle",
                    isOn: $moonriseEnabled
                )
            }
        }
    }

    private var permissionCard: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Image(systemName: "hand.raised.fill")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.moonBackground)
                        .frame(width: 36, height: 36)
                        .background(Color.moonAqua, in: Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text("권한은 나중에 요청")
                            .font(.headline)
                            .foregroundStyle(Color.moonText)

                        Text("처음 실행 화면은 방해하지 않습니다.")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.moonSubtext)
                    }
                }

                Text("처음 실행하자마자 알림 권한을 요구하지 않고, 사용자가 알림을 켤 때 이유를 설명합니다.")
                    .font(.subheadline)
                    .foregroundStyle(Color.moonSubtext)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    showingPermissionPreview = true
                } label: {
                    Label("권한 요청 미리보기", systemImage: "bell.badge")
                }
                .buttonStyle(PillButtonStyle())
            }
        }
    }
}

private struct NotificationToggleRow: View {
    let title: String
    let subtitle: String
    let symbol: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(isOn ? Color.moonBackground : Color.moonSubtext)
                    .frame(width: 38, height: 38)
                    .background(isOn ? Color.moonGold : Color.white.opacity(0.06), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color.moonText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.moonSubtext)
                        .lineLimit(1)
                        .minimumScaleFactor(0.74)
                }
            }
        }
        .tint(Color.moonGold)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(isOn ? Color.moonGold.opacity(0.08) : Color.white.opacity(0.035))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(isOn ? Color.moonGold.opacity(0.24) : Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
}

private struct ReminderStatusMetric: View {
    let symbol: String
    let title: String
    let value: String
    var tint: Color = Color.moonGold

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Image(systemName: symbol)
                .font(.headline.weight(.semibold))
                .foregroundStyle(tint)

            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.moonSubtext)

            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.moonText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 92, alignment: .topLeading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.moonSurface.opacity(0.66))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

#Preview {
    MoonNotificationsView()
}
