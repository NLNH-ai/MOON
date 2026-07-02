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

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("알림")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.moonText)

            Text("필요한 달 변화만 조용히 챙겨요.")
                .font(.body)
                .foregroundStyle(.moonSubtext)
        }
    }

    private var reminderList: some View {
        GlassPanel {
            VStack(spacing: 2) {
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
            VStack(alignment: .leading, spacing: 12) {
                Text("권한은 나중에 요청")
                    .font(.headline)
                    .foregroundStyle(.moonText)

                Text("처음 실행하자마자 알림 권한을 요구하지 않고, 사용자가 알림을 켤 때 이유를 설명합니다.")
                    .font(.subheadline)
                    .foregroundStyle(.moonSubtext)
                    .fixedSize(horizontal: false, vertical: true)

                Button("권한 요청 미리보기") {
                    showingPermissionPreview = true
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
                    .font(.title3)
                    .foregroundStyle(isOn ? .moonGold : .moonSubtext)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.moonText)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.moonSubtext)
                }
            }
        }
        .tint(.moonGold)
        .padding(.vertical, 12)
    }
}

#Preview {
    MoonNotificationsView()
}
