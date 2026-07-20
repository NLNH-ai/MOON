# 오늘달 iOS

현재 날짜와 선택한 위치를 기준으로 달의 위상, 밝기, 월출·남중·월몰을 보여주는 SwiftUI iPhone 앱입니다.

## 구현 기능

- SwiftAA 기반 실제 달 위상, 조도, 월령, 월출·남중·월몰 계산
- 도시 선택 또는 Core Location 현재 위치 사용
- 월 단위 달력 이동과 날짜별 상세 정보
- 보름달, 삭, 상현·하현, 월출 로컬 알림
- 날짜별 월출 알림 추가
- 공유 가능한 달 사진 모드
- 위치, 시간 표시, 달력 시작 요일, 알림 설정의 기기 내 저장
- VoiceOver 라벨, Dynamic Type 축소 대응, Privacy Manifest

## 빌드

`OneulDal.xcodeproj`를 Xcode에서 열고 `OneulDal` 스킴을 iPhone 시뮬레이터 또는 기기에서 실행합니다. Swift Package Manager가 SwiftAA 3.0.0을 자동으로 해결합니다.

Codemagic의 `ios-simulator-prototype` 워크플로는 빌드와 XCTest를 실행합니다. `ios-*` 태그는 `ios-testflight` 워크플로를 통해 TestFlight Internal 빌드를 업로드합니다.

## 개인정보

위치와 사용자 설정은 기기 안에서 계산·저장되며 앱 서버로 전송되지 않습니다. App Store 제출 전 App Store Connect에 공개 개인정보처리방침 URL을 등록해야 합니다.
