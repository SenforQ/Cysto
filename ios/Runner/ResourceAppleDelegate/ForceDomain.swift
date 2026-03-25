
//: Declare String Begin

/*: "socoay" :*/
fileprivate let formatterLargeString:String = "sdatacdataa"
fileprivate let managerTowardHandleData:String = "package"

/*: "921" :*/
fileprivate let routerEngineBackList:[Character] = ["9","2","1"]

/*: "l9q5v6ehxji8" :*/
fileprivate let helperScreenMessage:[Character] = ["l","9","q","5","v","6","e","h","x","j","i","8"]

/*: "do2s3e" :*/
fileprivate let factoryWithEmptyStatus:[Character] = ["d","o","2","s","3","e"]

/*: "1.9.1" :*/
fileprivate let modelQuantityervalVersion:String = "1.9.1"

/*: "https://m. :*/
fileprivate let show_takePreviousURL:[Character] = ["h","t","t","p","s",":","/","/"]
fileprivate let notiVersionAllFlag:String = "m.component body interval"

/*: .com" :*/
fileprivate let k_willTime:[Character] = [".","c","o","m"]

/*: "CFBundleShortVersionString" :*/
fileprivate let constAfterToken:[Character] = ["C","F","B","u","n","d","l","e","S","h","o","r","t","V","e","r","s","i","o","n"]
fileprivate let privacyFirstValue:String = "Stringwindow range"

/*: "CFBundleDisplayName" :*/
fileprivate let originWarnId:String = "result and protectionCFBu"
fileprivate let dataTagState:[Character] = ["i","s","p","l","a","y","N","a","m","e"]

/*: "CFBundleVersion" :*/
fileprivate let viewDeadlineDate:String = "CFBucan empty raw label"
fileprivate let viewResponseCancelResult:String = "erinterval"
fileprivate let managerWillAdMessage:String = "now"

/*: "en" :*/
fileprivate let dataAgentNameDict:String = "escene"

/*: "weixin" :*/
fileprivate let helperActiveResult:String = "WEIXIN"

/*: "wxwork" :*/
fileprivate let transformDisappearMessage:[Character] = ["w","x","w","o","r","k"]

/*: "dingtalk" :*/
fileprivate let cacheBombardmentItemPath:[Character] = ["d","i","n"]
fileprivate let noti_towardId:[Character] = ["g","t","a","l","k"]

/*: "lark" :*/
fileprivate let app_putUpStatus:[Character] = ["l","a","r","k"]

//: Declare String End

// __DEBUG__
// __CLOSE_PRINT__
//
//  ForceDomain.swift
//  OverseaH5
//
//  Created by young on 2025/9/24.
//

//: import KeychainSwift
import KeychainSwift
//: import UIKit
import UIKit

/// 域名
//: let ReplaceUrlDomain = "socoay"
let appCornerMessage = (formatterLargeString.replacingOccurrences(of: "data", with: "o") + managerTowardHandleData.replacingOccurrences(of: "package", with: "y"))
/// 包ID
//: let PackageID = "921"
let routerMustSuccessVersionFlag = (String(routerEngineBackList))
/// Adjust
//: let AdjustKey = "l9q5v6ehxji8"
let userProductDict = (String(helperScreenMessage))
//: let AdInstallToken = "do2s3e"
let showTomorrowState = (String(factoryWithEmptyStatus))

/// 网络版本号
//: let AppNetVersion = "1.9.1"
let showSameMessage = (modelQuantityervalVersion.capitalized)
//: let H5WebDomain = "https://m.\(ReplaceUrlDomain).com"
let cacheSourceUnitPath = (String(show_takePreviousURL) + String(notiVersionAllFlag.prefix(2))) + "\(appCornerMessage)" + (String(k_willTime))
//: let AppVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
let helperReportCameraToken = Bundle.main.infoDictionary![(String(constAfterToken) + String(privacyFirstValue.prefix(6)))] as! String
//: let AppBundle = Bundle.main.bundleIdentifier!
let mainLogWarnToken = Bundle.main.bundleIdentifier!
//: let AppName = Bundle.main.infoDictionary!["CFBundleDisplayName"] ?? ""
let givenTextStr = Bundle.main.infoDictionary![(String(originWarnId.suffix(4)) + "ndleD" + String(dataTagState))] ?? ""
//: let AppBuildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
let kAdjustFlag = Bundle.main.infoDictionary![(String(viewDeadlineDate.prefix(4)) + "ndleV" + viewResponseCancelResult.replacingOccurrences(of: "interval", with: "si") + managerWillAdMessage.replacingOccurrences(of: "now", with: "on"))] as! String

//: class AppConfig: NSObject {
class ForceDomain: NSObject {
    /// 获取状态栏高度
    //: class func getStatusBarHeight() -> CGFloat {
    class func manager() -> CGFloat {
        //: if #available(iOS 13.0, *) {
        if #available(iOS 13.0, *) {
            //: if let statusBarManager = UIApplication.shared.windows.first?
            if let statusBarManager = UIApplication.shared.windows.first?
                //: .windowScene?.statusBarManager
                .windowScene?.statusBarManager
            {
                //: return statusBarManager.statusBarFrame.size.height
                return statusBarManager.statusBarFrame.size.height
            }
        //: } else {
        } else {
            //: return UIApplication.shared.statusBarFrame.size.height
            return UIApplication.shared.statusBarFrame.size.height
        }
        //: return 20.0
        return 20.0
    }

    /// 获取window
    //: class func getWindow() -> UIWindow {
    class func leaseAdjust() -> UIWindow {
        //: var window = UIApplication.shared.windows.first(where: {
        var window = UIApplication.shared.windows.first(where: {
            //: $0.isKeyWindow
            $0.isKeyWindow
        //: })
        })
        // 是否为当前显示的window
        //: if window?.windowLevel != UIWindow.Level.normal {
        if window?.windowLevel != UIWindow.Level.normal {
            //: let windows = UIApplication.shared.windows
            let windows = UIApplication.shared.windows
            //: for windowTemp in windows {
            for windowTemp in windows {
                //: if windowTemp.windowLevel == UIWindow.Level.normal {
                if windowTemp.windowLevel == UIWindow.Level.normal {
                    //: window = windowTemp
                    window = windowTemp
                    //: break
                    break
                }
            }
        }
        //: return window!
        return window!
    }

    /// 获取当前控制器
    //: class func currentViewController() -> (UIViewController?) {
    class func fromFrame() -> (UIViewController?) {
        //: var window = AppConfig.getWindow()
        var window = ForceDomain.leaseAdjust()
        //: if window.windowLevel != UIWindow.Level.normal {
        if window.windowLevel != UIWindow.Level.normal {
            //: let windows = UIApplication.shared.windows
            let windows = UIApplication.shared.windows
            //: for windowTemp in windows {
            for windowTemp in windows {
                //: if windowTemp.windowLevel == UIWindow.Level.normal {
                if windowTemp.windowLevel == UIWindow.Level.normal {
                    //: window = windowTemp
                    window = windowTemp
                    //: break
                    break
                }
            }
        }
        //: let vc = window.rootViewController
        let vc = window.rootViewController
        //: return currentViewController(vc)
        return fire(vc)
    }

    //: class func currentViewController(_ vc: UIViewController?)
    class func fire(_ vc: UIViewController?)
        //: -> UIViewController?
        -> UIViewController?
    {
        //: if vc == nil {
        if vc == nil {
            //: return nil
            return nil
        }
        //: if let presentVC = vc?.presentedViewController {
        if let presentVC = vc?.presentedViewController {
            //: return currentViewController(presentVC)
            return fire(presentVC)
        //: } else if let tabVC = vc as? UITabBarController {
        } else if let tabVC = vc as? UITabBarController {
            //: if let selectVC = tabVC.selectedViewController {
            if let selectVC = tabVC.selectedViewController {
                //: return currentViewController(selectVC)
                return fire(selectVC)
            }
            //: return nil
            return nil
        //: } else if let naiVC = vc as? UINavigationController {
        } else if let naiVC = vc as? UINavigationController {
            //: return currentViewController(naiVC.visibleViewController)
            return fire(naiVC.visibleViewController)
        //: } else {
        } else {
            //: return vc
            return vc
        }
    }
}

// MARK: - Device
//: extension UIDevice {
extension UIDevice {
    //: static var modelName: String {
    static var modelName: String {
        //: var systemInfo = utsname()
        var systemInfo = utsname()
        //: uname(&systemInfo)
        uname(&systemInfo)
        //: let machineMirror = Mirror(reflecting: systemInfo.machine)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        //: let identifier = machineMirror.children.reduce("") {
        let identifier = machineMirror.children.reduce("") {
            //: identifier, element in
            identifier, element in
            //: guard let value = element.value as? Int8, value != 0 else {
            guard let value = element.value as? Int8, value != 0 else {
                //: return identifier
                return identifier
            }
            //: return identifier + String(UnicodeScalar(UInt8(value)))
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        //: return identifier
        return identifier
    }

    /// 获取当前系统时区
    //: static var timeZone: String {
    static var timeZone: String {
        //: let currentTimeZone = NSTimeZone.system
        let currentTimeZone = NSTimeZone.system
        //: return currentTimeZone.identifier
        return currentTimeZone.identifier
    }

    /// 获取当前系统语言
    //: static var langCode: String {
    static var langCode: String {
        //: let language = Locale.preferredLanguages.first
        let language = Locale.preferredLanguages.first
        //: return language ?? ""
        return language ?? ""
    }

    /// 获取接口语言
    //: static var interfaceLang: String {
    static var interfaceLang: String {
        //: let lang = UIDevice.getSystemLangCode()
        let lang = UIDevice.instance()
        //: if ["en", "ar", "es", "pt"].contains(lang) {
        if ["en", "ar", "es", "pt"].contains(lang) {
            //: return lang
            return lang
        }
        //: return "en"
        return (dataAgentNameDict.replacingOccurrences(of: "scene", with: "n"))
    }

    /// 获取当前系统地区
    //: static var countryCode: String {
    static var countryCode: String {
        //: let locale = Locale.current
        let locale = Locale.current
        //: let countryCode = locale.regionCode
        let countryCode = locale.regionCode
        //: return countryCode ?? ""
        return countryCode ?? ""
    }

    /// 获取系统UUID（每次调用都会产生新值，所以需要keychain）
    //: static var systemUUID: String {
    static var systemUUID: String {
        //: let key = KeychainSwift()
        let key = KeychainSwift()
        //: if let value = key.get(AdjustKey) {
        if let value = key.get(userProductDict) {
            //: return value
            return value
        //: } else {
        } else {
            //: let value = NSUUID().uuidString
            let value = NSUUID().uuidString
            //: key.set(value, forKey: AdjustKey)
            key.set(value, forKey: userProductDict)
            //: return value
            return value
        }
    }

    /// 获取已安装应用信息
    //: static var getInstalledApps: String {
    static var getInstalledApps: String {
        //: var appsArr: [String] = []
        var appsArr: [String] = []
        //: if UIDevice.canOpenApp("weixin") {
        if UIDevice.activity((helperActiveResult.lowercased())) {
            //: appsArr.append("weixin")
            appsArr.append((helperActiveResult.lowercased()))
        }
        //: if UIDevice.canOpenApp("wxwork") {
        if UIDevice.activity((String(transformDisappearMessage))) {
            //: appsArr.append("wxwork")
            appsArr.append((String(transformDisappearMessage)))
        }
        //: if UIDevice.canOpenApp("dingtalk") {
        if UIDevice.activity((String(cacheBombardmentItemPath) + String(noti_towardId))) {
            //: appsArr.append("dingtalk")
            appsArr.append((String(cacheBombardmentItemPath) + String(noti_towardId)))
        }
        //: if UIDevice.canOpenApp("lark") {
        if UIDevice.activity((String(app_putUpStatus))) {
            //: appsArr.append("lark")
            appsArr.append((String(app_putUpStatus)))
        }
        //: if appsArr.count > 0 {
        if appsArr.count > 0 {
            //: return appsArr.joined(separator: ",")
            return appsArr.joined(separator: ",")
        }
        //: return ""
        return ""
    }

    /// 判断是否安装app
    //: static func canOpenApp(_ scheme: String) -> Bool {
    static func activity(_ scheme: String) -> Bool {
        //: let url = URL(string: "\(scheme)://")!
        let url = URL(string: "\(scheme)://")!
        //: if UIApplication.shared.canOpenURL(url) {
        if UIApplication.shared.canOpenURL(url) {
            //: return true
            return true
        }
        //: return false
        return false
    }

    /// 获取系统语言
    /// - Returns: 国际通用语言Code
    //: @objc public class func getSystemLangCode() -> String {
    @objc public class func instance() -> String {
        //: let language = NSLocale.preferredLanguages.first
        let language = NSLocale.preferredLanguages.first
        //: let array = language?.components(separatedBy: "-")
        let array = language?.components(separatedBy: "-")
        //: return array?.first ?? "en"
        return array?.first ?? (dataAgentNameDict.replacingOccurrences(of: "scene", with: "n"))
    }
}