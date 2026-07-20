import SwiftUI
import UIKit

struct MoonNotificationsView: View {
    @EnvironmentObject private var appModel: AppModel
    @Environment(\.openURL) private var openURL
    @State private var pendingReminder: MoonReminderKind?
    @State private var showingPermissionExplanation = false

    var body: some View {
        NavigationStack {
            ZStack {
                MoonBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        statusStrip
                        reminderList
                        permissionCard
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 16)
                    .padding(.bottom, MoonLayout.tabBarContentClearance)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .alert("달 알림을 허용할까요?", isPresented: $showingPermissionExplanation) {
                Button("취소", role: .cancel) {
                    pendingReminder = nil
                }
                Button("계속") {
                    guard let pendingReminder else { return }
                    Task {
                        _ = await appModel.setReminder(pendingReminder, enabled: true)
                        self.pendingReminder = nil
                    }
                }
            } message: {
                Text("선택한 달의 위상이나 월출 전에 알려드리기 위해 iOS 알림 권한이 필요합니다.")
            }
        }
    }

    private var header: some View {
        ScreenHeader(
            title: "알림",
            eyebrow: "달 알림",
            subtitle: "보고 싶은 달과 월출만 골라 알림을 받습니다."
        ) {
            MoonChip("\(appModel.enabledReminderCount)개 켜짐", symbolName: "bell.badge.fill", tint: Color.moonGold)
        }
    }

    private var statusStrip: some View {
        GlassPanel(padding: 14) {
            HStack(spacing: 0) {
                ReminderStatusMetric(
                    symbol: "moon.stars.fill",
                    title: "달 알림",
                    value: appModel.enabledReminderCount > 0 ? "예약됨" : "꺼짐"
                )
                NotificationStatusDivider()
                ReminderStatusMetric(
                    symbol: "hand.raised.fill",
                    title: "권한",
                    value: appModel.notificationAuthorization.displayText,
                    tint: Color.moonAqua
                )
                NotificationStatusDivider()
                ReminderStatusMetric(
                    symbol: "location.fill",
                    title: "기준",
                    value: appModel.selectedLocation.name,
                    tint: Color.moonSubtext
                )
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var reminderList: some View {
        GlassPanel(padding: 14) {
            VStack(alignment: .leading, spacing: 10) {
                Text("받을 알림")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.moonText)

                NotificationToggleRow(
                    title: "보름달",
                    subtitle: "3일 전, 1일 전, 보름 시각",
                    symbol: "moon.circle.fill",
                    isOn: reminderBinding(for: .fullMoon)
                )

                NotificationToggleRow(
                    title: "삭",
                    subtitle: "별을 보기 좋은 달빛 적은 밤",
                    symbol: "circle",
                    isOn: reminderBinding(for: .newMoon)
                )

                NotificationToggleRow(
                    title: "상현 · 하현",
                    subtitle: "반달이 되는 시각",
                    symbol: "moonphase.first.quarter",
                    isOn: reminderBinding(for: .quarters)
                )

                NotificationToggleRow(
                    title: "월출",
                    subtitle: "달이 뜨기 1시간 전",
                    symbol: "arrow.up.circle",
                    isOn: reminderBinding(for: .moonrise)
                )
            }
        }
    }

    @ViewBuilder
    private var permissionCard: some View {
        switch appModel.notificationAuthorization {
        case .notDetermined:
            PermissionPanel(
                symbol: "bell.badge",
                title: "알림은 필요할 때만 요청",
                message: "위 알림 중 하나를 켜면 이유를 먼저 설명한 뒤 권한을 요청합니다.",
                buttonTitle: "알림 권한 요청"
            ) {
                Task { _ = await appModel.requestNotificationAccess() }
            }
        case .denied:
            PermissionPanel(
                symbol: "bell.slash.fill",
                title: "알림 권한이 꺼져 있어요",
                message: "알림을 받으려면 iPhone 설정에서 오늘달 알림을 허용해 주세요.",
                buttonTitle: "iPhone 설정 열기"
            ) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
        case .authorized, .provisional, .ephemeral:
            PermissionPanel(
                symbol: "checkmark.circle.fill",
                title: "알림 준비 완료",
                message: "켜 둔 항목은 실제 달의 날짜와 \(appModel.selectedLocation.name) 월출 시간에 맞춰 자동 갱신됩니다.",
                buttonTitle: nil,
                action: {}
            )
        }
    }

    private func reminderBinding(for kind: MoonReminderKind) -> Binding<Bool> {
        Binding(
            get: { appModel.reminderPreferences[kind] },
            set: { enabled in
                if enabled && !appModel.notificationAuthorization.allowsScheduling {
                    pendingReminder = kind
                    showingPermissionExplanation = true
                } else {
                    Task { _ = await appModel.setReminder(kind, enabled: enabled) }
                }
            }
        )
    }
}

private struct NotificationToggleRow: View {
    let title: String
    let subtitle: String
    let symbol: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(isOn ? Color.moonBackground : Color.moonSubtext)
                    .frame(width: 36, height: 36)
                    .background(isOn ? Color.moonGold : Color.white.opacity(0.06), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color.moonText)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.moonSubtext)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            }
        }
        .tint(Color.moonGold)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: MoonLayout.compactPanelCornerRadius, style: .continuous)
                .fill(isOn ? Color.moonGold.opacity(0.08) : Color.white.opacity(0.035))
                .overlay(
                    RoundedRectangle(cornerRadius: MoonLayout.compactPanelCornerRadius, style: .continuous)
                        .stroke(isOn ? Color.moonGold.opacity(0.24) : Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
}

private struct PermissionPanel: View {
    let symbol: String
    let title: String
    let message: String
    let buttonTitle: String?
    let action: () -> Void

    var body: some View {
        GlassPanel(padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                Label(title, systemImage: symbol)
                    .font(.headline)
                    .foregroundStyle(Color.moonText)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color.moonSubtext)
                    .fixedSize(horizontal: false, vertical: true)

                if let buttonTitle {
                    Button(buttonTitle, action: action)
                        .buttonStyle(PillButtonStyle())
                }
            }
        }
    }
}

private struct ReminderStatusMetric: View {
    let symbol: String
    let title: String
    let value: String
    var tint: Color = Color.moonGold

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Label(title, systemImage: symbol)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.68)

            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.moonText)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .center)
    }
}

private struct NotificationStatusDivider: View {
    var body: some View {
        Rectangle()
            .fill(.white.opacity(0.07))
            .frame(width: 1, height: 42)
            .padding(.horizontal, 6)
            .accessibilityHidden(true)
    }
}

#Preview {
    MoonNotificationsView()
        .environmentObject(AppModel())
}
