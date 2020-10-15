// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import AppCenterPush

/**
 * AppCenterDelegate implementation in Swift.
 */
class AppCenterDelegateSwift : AppCenterDelegate {

  //MARK: MSACAppCenter section.
  func isAppCenterEnabled() -> Bool {
    return AppCenter.enabled
  }
  func setAppCenterEnabled(_ isEnabled: Bool) {
    AppCenter.enabled = isEnabled
  }
  func setCountryCode(_ countryCode: String?) {
    AppCenter.setCountryCode(countryCode)
  }
  func setCustomProperties(_ customProperties: CustomProperties){
    AppCenter.setCustomProperties(customProperties)
  }
  func installId() -> String {
    return AppCenter.installId().uuidString
  }
  func appSecret() -> String {
    return kMSSwiftAppSecret
  }
  func isDebuggerAttached() -> Bool {
    return AppCenter.isDebuggerAttached()
  }
  func startAnalyticsFromLibrary() {
    AppCenter.startFromLibrary(withServices: [Analytics.self])
  }
  func setUserId(_ userId: String?) {
    AppCenter.setUserId(userId);
  }
  func setLogUrl(_ logUrl: String?) {
    AppCenter.logUrl = logUrl;
  }

  //MARK: Modules section.
  func isAnalyticsEnabled() -> Bool {
    return Analytics.isEnabled
  }
  func isCrashesEnabled() -> Bool {
    return MSACCrashes.isEnabled
  }
  func isPushEnabled() -> Bool {
    return MSPush.isEnabled
  }
  func setAnalyticsEnabled(_ isEnabled: Bool) {
    Analytics.isEnabled = isEnabled
  }
  func setCrashesEnabled(_ isEnabled: Bool) {
    MSACCrashes.isEnabled = isEnabled
  }
  func setPushEnabled(_ isEnabled: Bool) {
    MSPush.isEnabled = isEnabled
  }

  //MARK: Analytics section.
  func trackEvent(_ eventName: String) {
    Analytics.trackEvent(eventName)
  }
  func trackEvent(_ eventName: String, withProperties properties: Dictionary<String, String>) {
    Analytics.trackEvent(eventName, withProperties: properties)
  }
  func trackEvent(_ eventName: String, withProperties properties: Dictionary<String, String>, flags: MSACFlags) {
    Analytics.trackEvent(eventName, withProperties: properties, flags:flags)
  }
  func trackEvent(_ eventName: String, withTypedProperties properties: EventProperties) {
    Analytics.trackEvent(eventName, withProperties: properties)
  }
  func trackEvent(_ eventName: String, withTypedProperties properties: EventProperties?, flags: MSACFlags) {
    Analytics.trackEvent(eventName, withProperties: properties, flags: flags)
  }
  func resume() {
    Analytics.resume()
  }
  func pause() {
    Analytics.pause()
  }
  #warning("TODO: Uncomment when trackPage is moved from internal to public")
  func trackPage(_ pageName: String) {
    // Analytics.trackPage(pageName)
  }
  #warning("TODO: Uncomment when trackPage is moved from internal to public")
  func trackPage(_ pageName: String, withProperties properties: Dictionary<String, String>) {
    // Analytics.trackPage(pageName, withProperties: properties)
  }

  //MARK: MSACCrashes section.
  func hasCrashedInLastSession() -> Bool {
    return MSACCrashes.hasCrashedInLastSession()
  }
  func generateTestCrash() {
    MSACCrashes.generateTestCrash()
  }

  //MARK: Last crash report section.
  func lastCrashReportIncidentIdentifier() -> String? {
    return MSACCrashes.lastSessionCrashReport()?.incidentIdentifier
  }
  func lastCrashReportReporterKey() -> String? {
    return MSACCrashes.lastSessionCrashReport()?.reporterKey
  }
  func lastCrashReportSignal() -> String? {
    return MSACCrashes.lastSessionCrashReport()?.signal
  }
  func lastCrashReportExceptionName() -> String? {
    return MSACCrashes.lastSessionCrashReport()?.exceptionName
  }
  func lastCrashReportExceptionReason() -> String? {
    return MSACCrashes.lastSessionCrashReport()?.exceptionReason
  }
  func lastCrashReportAppStartTimeDescription() -> String? {
    return MSACCrashes.lastSessionCrashReport()?.appStartTime.description
  }
  func lastCrashReportAppErrorTimeDescription() -> String? {
    return MSACCrashes.lastSessionCrashReport()?.appErrorTime.description
  }
  func lastCrashReportAppProcessIdentifier() -> UInt {
    return (MSACCrashes.lastSessionCrashReport()?.appProcessIdentifier)!
  }
  func lastCrashReportIsAppKill() -> Bool {
    return (MSACCrashes.lastSessionCrashReport()?.isAppKill())!
  }
  func lastCrashReportDeviceModel() -> String? {
    return MSACCrashes.lastSessionCrashReport()?.device.model
  }
  func lastCrashReportDeviceOemName() -> String? {
    return MSACCrashes.lastSessionCrashReport()?.device.oemName
  }
  func lastCrashReportDeviceOsName() -> String? {
    return MSACCrashes.lastSessionCrashReport()?.device.osName
  }
  func lastCrashReportDeviceOsVersion() -> String? {
    return MSACCrashes.lastSessionCrashReport()?.device.osVersion
  }
  func lastCrashReportDeviceOsBuild() -> String? {
    return MSACCrashes.lastSessionCrashReport()?.device.osBuild
  }
  func lastCrashReportDeviceLocale() -> String? {
    return MSACCrashes.lastSessionCrashReport()?.device.locale
  }
  func lastCrashReportDeviceTimeZoneOffset() -> NSNumber? {
    return MSACCrashes.lastSessionCrashReport()?.device.timeZoneOffset
  }
  func lastCrashReportDeviceScreenSize() -> String? {
    return MSACCrashes.lastSessionCrashReport()?.device.screenSize
  }
  func lastCrashReportDeviceAppVersion() -> String? {
    return MSACCrashes.lastSessionCrashReport()?.device.appVersion
  }
  func lastCrashReportDeviceAppBuild() -> String? {
    return MSACCrashes.lastSessionCrashReport()?.device.appBuild
  }
  func lastCrashReportDeviceCarrierName() -> String? {
    return MSACCrashes.lastSessionCrashReport()?.device.carrierName
  }
  func lastCrashReportDeviceCarrierCountry() -> String? {
    return MSACCrashes.lastSessionCrashReport()?.device.carrierCountry
  }
  func lastCrashReportDeviceAppNamespace() -> String? {
    return MSACCrashes.lastSessionCrashReport()?.device.appNamespace
  }

  //MARK: MSEventFilter section.
  func isEventFilterEnabled() -> Bool{
    return MSEventFilter.isEnabled;
  }
  func setEventFilterEnabled(_ isEnabled: Bool){
    MSEventFilter.isEnabled = isEnabled;
  }
  func startEventFilterService() {
    AppCenter.startService(MSEventFilter.self)
  }
}
