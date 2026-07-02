import SwiftUI

struct LocationPickerSheet: View {
    @Binding var selectedCity: String
    @Environment(\.dismiss) private var dismiss

    private let cities = ["서울", "부산", "제주", "대전", "도쿄"]

    var body: some View {
        NavigationStack {
            List(cities, id: \.self) { city in
                Button {
                    selectedCity = city
                    dismiss()
                } label: {
                    HStack {
                        Text(city)
                        Spacer()
                        if selectedCity == city {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.moonGold)
                        }
                    }
                }
            }
            .navigationTitle("도시 선택")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SettingsSheet: View {
    @State private var preciseLocation = false
    @State private var use24HourTime = true
    @State private var mondayStart = true
    @State private var compactWidget = true

    var body: some View {
        NavigationStack {
            Form {
                Section("개인정보") {
                    Toggle("정확 위치 사용", isOn: $preciseLocation)
                    Text("끄면 선택한 도시 기준으로 계산합니다.")
                        .foregroundStyle(.secondary)
                }

                Section("표시") {
                    Toggle("24시간제", isOn: $use24HourTime)
                    Toggle("월요일 시작 달력", isOn: $mondayStart)
                }

                Section("위젯") {
                    Toggle("1x1 초소형 위젯 우선", isOn: $compactWidget)
                    Text("홈 화면에서 달 그림과 밝기만 빠르게 확인하는 스타일입니다.")
                        .foregroundStyle(.secondary)
                }
            }
            .tint(.moonGold)
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview("Location") {
    LocationPickerSheet(selectedCity: .constant("서울"))
}

#Preview("Settings") {
    SettingsSheet()
}
