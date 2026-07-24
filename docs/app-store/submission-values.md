# 오늘달 App Store Connect 입력값

## 앱 정보

| 항목 | 입력값 |
| --- | --- |
| 앱 이름 | 오늘달 |
| 부제 | 달의 위상과 월출을 한눈에 |
| 기본 언어 | 한국어 |
| 번들 ID | `com.oneuldal.app` |
| SKU | 기존 App Store Connect 값 유지 |
| 주 카테고리 | 참고 자료(Reference) |
| 보조 카테고리 | 날씨(Weather) |
| 저작권 | `2026 오늘달` |

앱 이름은 App Store Connect에서 사용 가능 여부를 최종 확인합니다.

## URL

| 항목 | 입력값 |
| --- | --- |
| 지원 URL | `https://nlnh-ai.github.io/MOON/support.html` |
| 개인정보 처리방침 URL | `https://nlnh-ai.github.io/MOON/privacy.html` |
| 마케팅 URL | 비워도 됨 |

두 URL은 2026년 7월 24일 외부 HTTPS 요청에서 `200` 응답을 확인했습니다.

## 버전

| 항목 | 입력값 |
| --- | --- |
| 버전 | `1.0.0` |
| 빌드 | `17` |
| 가격 | 무료 |
| 출시 지역 | 대한민국 우선 |
| 출시 방식 | 심사 승인 후 수동 출시 |

## 앱 개인정보

- 데이터 수집: 수집하지 않음
- 추적: 사용하지 않음
- 타사 광고: 사용하지 않음
- 분석: 사용하지 않음
- 위치: 기기 내 천문 계산에만 사용하며 외부 전송 또는 저장하지 않음
- 사용자 설정: 기기의 `UserDefaults`에만 저장
- 로컬 알림: 사용자가 항목을 켤 때 권한을 요청하고 기기에서 예약

## 연령 등급

현재 앱 기능 기준으로 폭력성, 성적 콘텐츠, 비속어, 약물, 도박, 공포,
사용자 생성 콘텐츠, 무제한 웹 접근 등의 항목은 모두 해당 없음으로
답변합니다. 최종 등급은 App Store Connect 설문 결과를 따릅니다.

## 수출 규정 준수

`Info.plist`의 `ITSAppUsesNonExemptEncryption` 값은 `false`입니다. 앱은
비면제 암호화 기능을 구현하지 않으므로 App Store Connect에서 암호화 관련
추가 문서가 필요하지 않은 경로로 답변합니다.

## 콘텐츠 권리

앱 아이콘, 달 표면 이미지 및 스토어 스크린샷의 사용 권리를 확인합니다.
SwiftAA는 MIT 라이선스이며 `THIRD_PARTY_NOTICES.md`와 앱 내 오픈 소스
고지에 포함되어 있습니다.

## 제출 파일

- 설명: `docs/app-store/description-ko.txt`
- 프로모션 문구: `docs/app-store/promotional-text-ko.txt`
- 키워드: `docs/app-store/keywords-ko.txt`
- 심사 메모: `docs/app-store/review-notes-ko.txt`
- 6.9형 스크린샷: `docs/app-store/screenshots/6.9-inch/`
