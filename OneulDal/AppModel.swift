import Combine
import CoreLocation
import Foundation

@MainActor
final class AppModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    enum AppModelError: LocalizedError {
        case notificationDenied
        case noFutureMoonrise

        var errorDescription: String? {
            switch self {
            case .notificationDenied:
                return "iPhone 설정에서 오늘달 알림을 허용해 주세요."
            case .noFutureMoonrise:
                return "선택한 날짜에 예약할 수 있는 월출 시간이 없습니다."
            }
        }
    }

    @Published private(set) var snapshot: MoonSnapshot
    @Published private(set) var calendarMonthStart: Date
    @Published private(set) var calendarDays: [MoonDay]
    @Published private(set) var selectedLocation: MoonLocation
    @Published private(set) var usePreciseLocation: Bool
    @Published private(set) var use24HourTime: Bool
    @Published private(set) var mondayStart: Bool
    @Published private(set) var compactWidget: Bool
    @Published private(set) var reminderPreferences: MoonReminderPreferences
    @Published private(set) var notificationAuthorization: MoonNotificationAuthorization = .notDetermined
    @Published private(set) var locationStatusText = "도시 기준"
    @Published private(set) var isRefreshing = false
    @Published var userFacingError: String?

    private enum DefaultsKey {
        static let cityID = "settings.cityID"
        static let preciseLocation = "settings.preciseLocation"
        static let lastLatitude = "settings.lastLatitude"
        static let lastLongitude = "settings.lastLongitude"
        static let use24HourTime = "settings.use24HourTime"
        static let mondayStart = "settings.mondayStart"
        static let compactWidget = "settings.compactWidget"
        static let fullMoonReminder = "reminders.fullMoon"
        static let newMoonReminder = "reminders.newMoon"
        static let quartersReminder = "reminders.quarters"
        static let moonriseReminder = "reminders.moonrise"
    }

    private let defaults: UserDefaults
    private let notificationScheduler: MoonNotificationScheduling
    private let locationManager: CLLocationManager
    private var fallbackCity: MoonLocation
    private var astronomyRefreshTask: Task<Void, Never>?
    private var calendarRefreshTask: Task<Void, Never>?

    init(
        defaults: UserDefaults = .standard,
        notificationScheduler: MoonNotificationScheduling = MoonNotificationService(),
        locationManager: CLLocationManager = CLLocationManager(),
        referenceDate: Date = Date()
    ) {
        self.defaults = defaults
        self.notificationScheduler = notificationScheduler
        self.locationManager = locationManager

        let city = MoonLocationCatalog.city(id: defaults.string(forKey: DefaultsKey.cityID))
        let preciseLocationEnabled = defaults.object(forKey: DefaultsKey.preciseLocation) as? Bool ?? false
        let twentyFourHourTimeEnabled = defaults.object(forKey: DefaultsKey.use24HourTime) as? Bool ?? true
        fallbackCity = city
        usePreciseLocation = preciseLocationEnabled
        use24HourTime = twentyFourHourTimeEnabled
        mondayStart = defaults.object(forKey: DefaultsKey.mondayStart) as? Bool ?? true
        compactWidget = defaults.object(forKey: DefaultsKey.compactWidget) as? Bool ?? true
        reminderPreferences = MoonReminderPreferences(
            fullMoon: defaults.object(forKey: DefaultsKey.fullMoonReminder) as? Bool ?? false,
            newMoon: defaults.object(forKey: DefaultsKey.newMoonReminder) as? Bool ?? false,
            quarters: defaults.object(forKey: DefaultsKey.quartersReminder) as? Bool ?? false,
            moonrise: defaults.object(forKey: DefaultsKey.moonriseReminder) as? Bool ?? false
        )

        let initialLocation: MoonLocation
        if preciseLocationEnabled,
           defaults.object(forKey: DefaultsKey.lastLatitude) != nil,
           defaults.object(forKey: DefaultsKey.lastLongitude) != nil {
            initialLocation = MoonLocationCatalog.current(
                latitude: defaults.double(forKey: DefaultsKey.lastLatitude),
                longitude: defaults.double(forKey: DefaultsKey.lastLongitude)
            )
        } else {
            initialLocation = city
        }
        selectedLocation = initialLocation

        let initialSnapshot = MoonAstronomyService.snapshot(
            at: referenceDate,
            location: initialLocation,
            use24HourTime: twentyFourHourTimeEnabled
        )
        snapshot = initialSnapshot
        calendarMonthStart = initialSnapshot.currentMonthStart
        calendarDays = initialSnapshot.currentMonthDays

        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationStatusText = selectedLocation.isCurrentLocation ? "최근 위치" : "도시 기준"

        Task {
            await synchronizeNotificationState()
        }

        if usePreciseLocation {
            requestCurrentLocation()
        }
    }

    deinit {
        astronomyRefreshTask?.cancel()
        calendarRefreshTask?.cancel()
    }

    var nextFullMoon: MoonEventSummary? {
        snapshot.nextFullMoon
    }

    var enabledReminderCount: Int {
        reminderPreferences.enabledCount
    }

    var calendar: Calendar {
        MoonAstronomyService.calendar(for: selectedLocation)
    }

    func selectCity(_ city: MoonLocation) {
        fallbackCity = city
        defaults.set(city.id, forKey: DefaultsKey.cityID)
        usePreciseLocation = false
        defaults.set(false, forKey: DefaultsKey.preciseLocation)
        selectedLocation = city
        locationStatusText = "도시 기준"
        refreshAstronomy()
    }

    func setPreciseLocationEnabled(_ enabled: Bool) {
        usePreciseLocation = enabled
        defaults.set(enabled, forKey: DefaultsKey.preciseLocation)

        if enabled {
            requestCurrentLocation()
        } else {
            selectedLocation = fallbackCity
            locationStatusText = "도시 기준"
            refreshAstronomy()
        }
    }

    func setUse24HourTime(_ enabled: Bool) {
        guard use24HourTime != enabled else { return }
        use24HourTime = enabled
        defaults.set(enabled, forKey: DefaultsKey.use24HourTime)
        refreshAstronomy()
    }

    func setMondayStart(_ enabled: Bool) {
        mondayStart = enabled
        defaults.set(enabled, forKey: DefaultsKey.mondayStart)
    }

    func setCompactWidget(_ enabled: Bool) {
        compactWidget = enabled
        defaults.set(enabled, forKey: DefaultsKey.compactWidget)
    }

    func refreshForCurrentDate() {
        let today = calendar.startOfDay(for: Date())
        guard today != snapshot.today.date else { return }
        refreshAstronomy()
    }

    func refreshAstronomy(referenceDate: Date = Date()) {
        astronomyRefreshTask?.cancel()
        let location = selectedLocation
        let use24HourTime = use24HourTime
        isRefreshing = true

        astronomyRefreshTask = Task {
            let result = await Task.detached(priority: .userInitiated) {
                MoonAstronomyService.snapshot(
                    at: referenceDate,
                    location: location,
                    use24HourTime: use24HourTime
                )
            }.value

            guard !Task.isCancelled else { return }
            snapshot = result
            calendarMonthStart = result.currentMonthStart
            calendarDays = result.currentMonthDays
            isRefreshing = false
            await rescheduleNotificationsIfAllowed()
        }
    }

    func moveCalendarMonth(by value: Int) {
        let target = calendar.date(byAdding: .month, value: value, to: calendarMonthStart)
            ?? calendarMonthStart
        loadCalendarMonth(containing: target)
    }

    func loadCalendarMonth(containing date: Date) {
        calendarRefreshTask?.cancel()
        let location = selectedLocation
        let use24HourTime = use24HourTime

        calendarRefreshTask = Task {
            let result = await Task.detached(priority: .userInitiated) {
                MoonAstronomyService.month(
                    containing: date,
                    location: location,
                    use24HourTime: use24HourTime
                )
            }.value

            guard !Task.isCancelled else { return }
            calendarMonthStart = result.start
            calendarDays = result.days
        }
    }

    func requestNotificationAccess() async -> Bool {
        do {
            let granted = try await notificationScheduler.requestAuthorization()
            notificationAuthorization = await notificationScheduler.authorizationStatus()
            if granted || notificationAuthorization.allowsScheduling {
                await rescheduleNotificationsIfAllowed()
                return true
            }
            userFacingError = AppModelError.notificationDenied.localizedDescription
            return false
        } catch {
            userFacingError = error.localizedDescription
            return false
        }
    }

    func setReminder(_ kind: MoonReminderKind, enabled: Bool) async -> Bool {
        if enabled && !notificationAuthorization.allowsScheduling {
            guard await requestNotificationAccess() else { return false }
        }

        var updated = reminderPreferences
        updated[kind] = enabled
        reminderPreferences = updated
        persistReminderPreferences()
        await rescheduleNotificationsIfAllowed()
        return true
    }

    func addMoonriseReminder(for day: MoonDay) async throws {
        if !notificationAuthorization.allowsScheduling {
            guard await requestNotificationAccess() else {
                throw AppModelError.notificationDenied
            }
        }

        guard let plan = MoonNotificationPlanner.oneOffMoonrisePlan(for: day, now: Date()) else {
            throw AppModelError.noFutureMoonrise
        }

        try await notificationScheduler.schedule(plan, timeZone: selectedLocation.timeZone)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationStatusText = "위치 확인 중"
            manager.requestLocation()
        case .denied, .restricted:
            usePreciseLocation = false
            defaults.set(false, forKey: DefaultsKey.preciseLocation)
            selectedLocation = fallbackCity
            locationStatusText = "위치 권한 꺼짐"
            userFacingError = "정확 위치 권한이 없어 \(fallbackCity.name) 기준으로 표시합니다."
            refreshAstronomy()
        case .notDetermined:
            locationStatusText = "권한 요청 전"
        @unknown default:
            locationStatusText = "도시 기준"
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        defaults.set(location.coordinate.latitude, forKey: DefaultsKey.lastLatitude)
        defaults.set(location.coordinate.longitude, forKey: DefaultsKey.lastLongitude)
        selectedLocation = MoonLocationCatalog.current(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        locationStatusText = "현재 위치"
        refreshAstronomy()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationStatusText = selectedLocation.isCurrentLocation ? "최근 위치" : "도시 기준"
        userFacingError = "현재 위치를 갱신하지 못했습니다. 저장된 위치로 계속 표시합니다."
    }

    private func requestCurrentLocation() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationStatusText = "권한 요청 전"
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationStatusText = "위치 확인 중"
            locationManager.requestLocation()
        case .denied, .restricted:
            usePreciseLocation = false
            defaults.set(false, forKey: DefaultsKey.preciseLocation)
            selectedLocation = fallbackCity
            locationStatusText = "위치 권한 꺼짐"
            userFacingError = "iPhone 설정에서 위치 권한을 허용하면 현재 위치 기준으로 계산할 수 있습니다."
        @unknown default:
            break
        }
    }

    private func synchronizeNotificationState() async {
        notificationAuthorization = await notificationScheduler.authorizationStatus()
        await rescheduleNotificationsIfAllowed()
    }

    private func rescheduleNotificationsIfAllowed() async {
        guard notificationAuthorization.allowsScheduling else { return }

        do {
            let plans = MoonNotificationPlanner.plans(
                snapshot: snapshot,
                preferences: reminderPreferences,
                now: Date()
            )
            try await notificationScheduler.replaceScheduledNotifications(
                with: plans,
                timeZone: selectedLocation.timeZone
            )
        } catch {
            userFacingError = "알림 일정을 저장하지 못했습니다. 잠시 후 다시 시도해 주세요."
        }
    }

    private func persistReminderPreferences() {
        defaults.set(reminderPreferences.fullMoon, forKey: DefaultsKey.fullMoonReminder)
        defaults.set(reminderPreferences.newMoon, forKey: DefaultsKey.newMoonReminder)
        defaults.set(reminderPreferences.quarters, forKey: DefaultsKey.quartersReminder)
        defaults.set(reminderPreferences.moonrise, forKey: DefaultsKey.moonriseReminder)
    }
}
