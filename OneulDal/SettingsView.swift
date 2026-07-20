import SwiftUI

struct LocationPickerSheet: View {
    @EnvironmentObject private var appModel: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        appModel.setPreciseLocationEnabled(true)
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "location.fill")
                                .foregroundStyle(Color.moonAqua)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("현재 위치 사용")
                                Text(appModel.locationStatusText)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if appModel.usePreciseLocation {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.moonGold)
                            }
                        }
                    }
                } footer: {
                    Text("정확 위치는 달의 월출·남중·월몰 계산에만 사용하며 기기에 저장합니다.")
                }

                Section("도시 기준") {
                    ForEach(MoonLocationCatalog.cities) { city in
                        Button {
                            appModel.selectCity(city)
                            dismiss()
                        } label: {
                            HStack {
                                Text(city.name)
                                Spacer()
                                if !appModel.usePreciseLocation && appModel.selectedLocation.id == city.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.moonGold)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("지역 선택")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SettingsSheet: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationStack {
            Form {
                Section("위치") {
                    Toggle(
                        "정확 위치 사용",
                        isOn: Binding(
                            get: { appModel.usePreciseLocation },
                            set: appModel.setPreciseLocationEnabled
                        )
                    )
                    Text(appModel.usePreciseLocation
                         ? "현재 위치 기준으로 월출과 월몰을 계산합니다."
                         : "\(appModel.selectedLocation.name) 기준으로 계산합니다.")
                        .foregroundStyle(.secondary)
                }

                Section("표시") {
                    Toggle(
                        "24시간제",
                        isOn: Binding(
                            get: { appModel.use24HourTime },
                            set: appModel.setUse24HourTime
                        )
                    )
                    Toggle(
                        "월요일 시작 달력",
                        isOn: Binding(
                            get: { appModel.mondayStart },
                            set: appModel.setMondayStart
                        )
                    )
                }

                Section("위젯") {
                    Toggle(
                        "간단한 달 위젯 우선",
                        isOn: Binding(
                            get: { appModel.compactWidget },
                            set: appModel.setCompactWidget
                        )
                    )
                    Text("위젯 확장 시 달 그림과 밝기를 먼저 보여주기 위한 설정입니다.")
                        .foregroundStyle(.secondary)
                }

                Section("계산 기준") {
                    LabeledContent("지역", value: appModel.selectedLocation.name)
                    LabeledContent("시간대", value: appModel.selectedLocation.timeZone.identifier)
                    LabeledContent("천문 데이터", value: "SwiftAA 고정밀 계산")
                }

                Section("정보") {
                    NavigationLink("개인정보 처리 안내") {
                        MoonPrivacyView()
                    }
                    NavigationLink("오픈소스 라이선스") {
                        OpenSourceLicenseView()
                    }
                }
            }
            .tint(Color.moonGold)
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct MoonPrivacyView: View {
    var body: some View {
        List {
            Section("위치") {
                Text("정확 위치를 켠 경우 월출·남중·월몰 시간을 계산하기 위해 위치를 사용합니다. 위치와 설정은 이 iPhone 안에만 저장되며 서버로 전송하지 않습니다.")
            }
            Section("알림") {
                Text("사용자가 켠 달 알림은 iOS의 로컬 알림으로 기기에서 예약합니다. 알림 설정은 외부 서버로 전송하지 않습니다.")
            }
            Section("공유") {
                Text("사진 모드 이미지는 기기에서 생성되며, 사용자가 공유 버튼을 누른 경우에만 선택한 앱으로 전달됩니다.")
            }
            Section("수집") {
                Text("오늘달은 계정, 광고, 추적 도구 또는 자체 분석 서버를 사용하지 않습니다.")
            }
        }
        .navigationTitle("개인정보 처리 안내")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct OpenSourceLicenseView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("SwiftAA")
                    .font(.title2.bold())
                Text("Copyright © 2015–2017 Cédric Foellmi")
                    .foregroundStyle(.secondary)
                Text("MIT License")
                    .font(.headline)
                Text("Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files, to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, subject to inclusion of the copyright and permission notice. The software is provided without warranty.")
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(22)
        }
        .navigationTitle("오픈소스 라이선스")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Location") {
    LocationPickerSheet()
        .environmentObject(AppModel())
}

#Preview("Settings") {
    SettingsSheet()
        .environmentObject(AppModel())
}
