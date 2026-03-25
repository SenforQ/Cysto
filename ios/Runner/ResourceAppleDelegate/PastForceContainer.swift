
//: Declare String Begin

/*: "mf/recharge/createApplePay" :*/
fileprivate let configPrivacyId:String = "mf/recalways print given"
fileprivate let data_packageFlag:String = "pad screen sube/crea"
fileprivate let managerKindEndStr:[Character] = ["l","e","P","a","y"]

/*: "productId" :*/
fileprivate let dataInfoRoundWillList:String = "PRODU"

/*: "source" :*/
fileprivate let networkSinceContactKey:String = "soutotalce"

/*: "orderNum" :*/
fileprivate let appTransactionCount:[Character] = ["o","r","d","e","r","N","u","m"]

/*: "mf/recharge/applePayNotify" :*/
fileprivate let routerCasingFormat:[Character] = ["m","f","/","r","e","c","h","a","r","g","e","/","a","p","p","l","e","P","a"]
fileprivate let show_appMode:[Character] = ["y","N","o","t","i","f","y"]

/*: "reportMoney" :*/
fileprivate let dataPetitionTagValue:String = "REPO"

/*: "transactionId" :*/
fileprivate let show_oldBoyNetworkString:String = "tchallengean"
fileprivate let userTitleMessageCancelStatus:String = "ionIdelse take i stop super"

/*: "mf/AutoSub/AppleCreateOrder" :*/
fileprivate let user_loopProductUrl:[Character] = ["m","f","/","A","u","t","o","S","u","b","/","A","p","p","l","e","C","r","e","a","t","e"]
fileprivate let noti_packageValue:[Character] = ["O","r","d","e","r"]

/*: "orderId" :*/
fileprivate let managerQuantityTrustPhoneValue:[UInt8] = [0xaf,0xb2,0xa4,0xa5,0xb2,0x89,0xa4]

/*: "mf/AutoSub/ApplePaySuccess" :*/
fileprivate let parserCanFailData:String = "mf/Auorigin faculty sub data"
fileprivate let routerByDecideFlag:String = "visible service session/Appl"
fileprivate let configContactName:String = "run break version try allowSuccess"

/*: "App" :*/
fileprivate let k_receiveDeviceKey:String = "Appbuild open root local bounce"

/*: "OrderTransactionInfo_Cache" :*/
fileprivate let controllerFilterValue:[Character] = ["O","r","d","e","r","T","r","a","n","s","a","c","t","i","o","n","I","n","f","o","_"]
fileprivate let controllerCameraSecret:[Character] = ["C","a","c","h","e"]

/*: "OrderTransactionInfo_Subscribe_Cache" :*/
fileprivate let app_usResult:[UInt8] = [0x65,0x68,0x63,0x61,0x43,0x5f,0x65,0x62,0x69,0x72,0x63,0x73,0x62,0x75,0x53,0x5f,0x6f,0x66,0x6e,0x49,0x6e,0x6f,0x69,0x74,0x63,0x61,0x73,0x6e,0x61,0x72,0x54,0x72,0x65,0x64,0x72,0x4f]

/*: "verifyData" :*/
fileprivate let k_eventFlag:[UInt8] = [0xb4,0xa7,0xb0,0xab,0xa4,0xbb,0x86,0xa3,0xb6,0xa3]

private func levelScene(production num: UInt8) -> UInt8 {
    return num ^ 194
}

/*: " 未知的交易类型" :*/
fileprivate let managerAgainMessage:String = " 未\u{77e5}的\u{4ea4}易类型"

//: Declare String End

// __DEBUG__
// __CLOSE_PRINT__
//: import UIKit
import UIKit
//: import StoreKit
import StoreKit
 
// 最大失败重试次数
//: let APPLE_IAP_MAX_RETRY_COUNT = 9
let controllerRequestStr = 9

/// 支付类型
//: enum ApplePayType {
enum CoordinatorScreen {
    //: case Pay        
    case Pay        // 支付
    //: case Subscribe  
    case Subscribe  // 订阅
}
/// 支付状态
//: enum AppleIAPStatus: String {
enum RoundArgument: String {
    //: case unknow            = "未知类型"
    case unknow            = "未知类型"
    //: case createOrderFail   = "创建订单失败"
    case createOrderFail   = "创建订单失败"
    //: case notArrow          = "设备不允许"
    case notArrow          = "设备不允许"
    //: case noProductId       = "缺少产品Id"
    case noProductId       = "缺少产品Id"
    //: case failed            = "交易失败/取消"
    case failed            = "交易失败/取消"
    //: case restored          = "已购买过该商品"
    case restored          = "已购买过该商品"
    //: case deferred          = "交易延期"
    case deferred          = "交易延期"
    //: case verityFail        = "服务器验证失败"
    case verityFail        = "服务器验证失败"
    //: case veritySucceed     = "服务器验证成功"
    case veritySucceed     = "服务器验证成功"
    //: case renewSucceed      = "自动续订成功"
    case renewSucceed      = "自动续订成功"
}

//: typealias IAPcompletionHandle = (AppleIAPStatus, Double, ApplePayType) -> Void
typealias IAPcompletionHandle = (RoundArgument, Double, CoordinatorScreen) -> Void

//: class AppleIAPManager: NSObject {
class PastForceContainer: NSObject {
    
    //: var completionHandle: IAPcompletionHandle?
    var completionHandle: IAPcompletionHandle?
    //: private var productInfoReq: SKProductsRequest?
    private var productInfoReq: SKProductsRequest?
    //: private var reqRetryCountDict = [String: Int]()         
    private var reqRetryCountDict = [String: Int]()         // 记录每个交易请求重试次数
    //: private var payCacheList = [[String: String]]()         
    private var payCacheList = [[String: String]]()         // 【购买】缓存数据
    //: private var subscribeCacheList = [[String: String]]()   
    private var subscribeCacheList = [[String: String]]()   // 【订阅】缓存数据
    //: private var createOrderId: String?                      
    private var createOrderId: String?                      // 当前支付服务端创建的订单id
    //: private var currentPayType: ApplePayType = .Pay         
    private var currentPayType: CoordinatorScreen = .Pay         // 当前支付类型
    
    // singleton
    //: static let shared = AppleIAPManager()
    static let shared = PastForceContainer()
    //: override func copy() -> Any { return self }
    override func copy() -> Any { return self }
    //: override func mutableCopy() -> Any { return self }
    override func mutableCopy() -> Any { return self }
    //: private override init() {
    private override init() {
        //: super.init()
        super.init()
        //: SKPaymentQueue.default().add(self as SKPaymentTransactionObserver)
        SKPaymentQueue.default().add(self as SKPaymentTransactionObserver)
        // 监听应用将要销毁
        //: NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate),
        NotificationCenter.default.addObserver(self, selector: #selector(faculty),
                                               //: name: UIApplication.willTerminateNotification,
                                               name: UIApplication.willTerminateNotification,
                                               //: object: nil)
                                               object: nil)
    }

    // MARK: - NotificationCenter
    //: @objc func appWillTerminate() {
    @objc func faculty() {
        //: SKPaymentQueue.default().remove(self as SKPaymentTransactionObserver)
        SKPaymentQueue.default().remove(self as SKPaymentTransactionObserver)
    }
}

// MARK: - 【苹果购买】业务接口
//: extension AppleIAPManager {
extension PastForceContainer {
    /// 【购买】创建业务订单
    /// - Parameters:
    ///   - productId: 产品Id
    ///   - block: 回调
    //: fileprivate func req_pay_createAppleOrder(productId: String, source: Int, handle: @escaping (String?, Bool) -> Void) {
    fileprivate func frame(productId: String, source: Int, handle: @escaping (String?, Bool) -> Void) {
        //: let reqModel = AppRequestModel.init()
        let reqModel = OnlyPresentModel.init()
        //: reqModel.requestPath = "mf/recharge/createApplePay"
        reqModel.requestPath = (String(configPrivacyId.prefix(6)) + "harg" + String(data_packageFlag.suffix(6)) + "teApp" + String(managerKindEndStr))
        //: var dict = Dictionary<String, Any>()
        var dict = Dictionary<String, Any>()
        //: dict["productId"] = productId
        dict[(dataInfoRoundWillList.lowercased() + "ctId")] = productId
        //: dict["source"] = source
        dict[(networkSinceContactKey.replacingOccurrences(of: "total", with: "r"))] = source
        //: reqModel.params = dict
        reqModel.params = dict
        //: AppRequestTool.startPostRequest(model: reqModel) { succeed, result, errorModel in
        ArgumentTransform.at(model: reqModel) { succeed, result, errorModel in
            //: guard succeed == true else {
            guard succeed == true else {
                //: handle(nil, succeed)
                handle(nil, succeed)
                //: return
                return
            }

            //: var orderId: String?
            var orderId: String?
            //: let dict = result as? [String: Any]
            let dict = result as? [String: Any]
            //: if let value = dict?["orderNum"] as? String {
            if let value = dict?[(String(appTransactionCount))] as? String {
                //: orderId = value
                orderId = value
            }
            //: handle(orderId, succeed)
            handle(orderId, succeed)
        }
    }
    
    /// 【购买】上传支付信息到服务器验证
    /// - Parameters:
    ///   - transaction: 交易信息
    ///   - params: 接口参数
    //: fileprivate func req_pay_uploadAppletransaction(_ transactionId: String, params: [String: String]) {
    fileprivate func towardHandle(_ transactionId: String, params: [String: String]) {
        //: let reqModel = AppRequestModel.init()
        let reqModel = OnlyPresentModel.init()
        //: reqModel.requestPath = "mf/recharge/applePayNotify"
        reqModel.requestPath = (String(routerCasingFormat) + String(show_appMode))
        //: reqModel.params = params
        reqModel.params = params
        //: AppRequestTool.startPostRequest(model: reqModel) { succeed, result, errorModel in
        ArgumentTransform.at(model: reqModel) { succeed, result, errorModel in
            //: guard succeed == true || errorModel?.errorCode == 405 else { 
            guard succeed == true || errorModel?.errorCode == 405 else { // 验证接口失败，重试接口
                //: DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    //: self.transcationPurchasedToCheck(transactionId, .Pay)
                    self.buildPrompt(transactionId, .Pay)
                }
                //: return
                return
            }

            //: let dict = result as? [String: Any]
            let dict = result as? [String: Any]
            //: let reportMoney: Double = {
            let reportMoney: Double = {
                //: if let d = dict?["reportMoney"] as? Double { return d }
                if let d = dict?[(dataPetitionTagValue.lowercased() + "rtMoney")] as? Double { return d }
                //: return 0
                return 0
            //: }()
            }()
            
            // 过滤已验证成功的订单数据
            //: let newPayCacheList = self.payCacheList.filter({$0["transactionId"] != transactionId})
            let newPayCacheList = self.payCacheList.filter({$0[(show_oldBoyNetworkString.replacingOccurrences(of: "challenge", with: "r") + "sact" + String(userTitleMessageCancelStatus.prefix(5)))] != transactionId})
            //: let diskPath = self.getPayCachePath()
            let diskPath = self.fromDate()
            //: NSKeyedArchiver.archiveRootObject(newPayCacheList, toFile: diskPath)
            NSKeyedArchiver.archiveRootObject(newPayCacheList, toFile: diskPath)
                        
            // 成功回调
            //: self.completionHandle?(.veritySucceed, reportMoney, .Pay)
            self.completionHandle?(.veritySucceed, reportMoney, .Pay)
        }
    }
}

// MARK: - 【苹果订阅】业务接口
//: extension AppleIAPManager {
extension PastForceContainer {
    /// 【订阅】创建业务订单
    /// - Parameters:
    ///   - productId: 产品Id
    ///   - block: 回调
    //: fileprivate func req_subscribe_createAppleOrder(productId: String, source: Int, handle: @escaping (String?, Bool) -> Void) {
    fileprivate func evaluateBack(productId: String, source: Int, handle: @escaping (String?, Bool) -> Void) {
        //: let reqModel = AppRequestModel.init()
        let reqModel = OnlyPresentModel.init()
        //: reqModel.requestPath = "mf/AutoSub/AppleCreateOrder"
        reqModel.requestPath = (String(user_loopProductUrl) + String(noti_packageValue))
        //: var dict = Dictionary<String, Any>()
        var dict = Dictionary<String, Any>()
        //: dict["productId"] = productId
        dict[(dataInfoRoundWillList.lowercased() + "ctId")] = productId
        //: dict["source"] = source
        dict[(networkSinceContactKey.replacingOccurrences(of: "total", with: "r"))] = source
        //: reqModel.params = dict
        reqModel.params = dict
        //: AppRequestTool.startPostRequest(model: reqModel) { succeed, result, errorModel in
        ArgumentTransform.at(model: reqModel) { succeed, result, errorModel in
            //: guard succeed == true else {
            guard succeed == true else {
                //: handle(nil, succeed)
                handle(nil, succeed)
                //: return
                return
            }

            //: var orderId: String? = nil
            var orderId: String? = nil
            //: let dict = result as? [String: Any]
            let dict = result as? [String: Any]
            //: if let value = dict?["orderId"] as? String {
            if let value = dict?[String(bytes: managerQuantityTrustPhoneValue.map{$0^192}, encoding: .utf8)!] as? String {
                //: orderId = value
                orderId = value
            }
            //: handle(orderId, succeed)
            handle(orderId, succeed)
        }
    }
    
    /// 【订阅】上传支付信息到服务器验证
    /// - Parameters:
    ///   - transaction: 交易信息
    ///   - params: 接口参数
    //: fileprivate func req_subscribe_uploadAppletransaction(_ transactionId: String, params: [String: String]) {
    fileprivate func inputAfter(_ transactionId: String, params: [String: String]) {
        //: let reqModel = AppRequestModel.init()
        let reqModel = OnlyPresentModel.init()
        //: reqModel.requestPath = "mf/AutoSub/ApplePaySuccess"
        reqModel.requestPath = (String(parserCanFailData.prefix(5)) + "toSub" + String(routerByDecideFlag.suffix(5)) + "ePay" + String(configContactName.suffix(7)))
        //: reqModel.params = params
        reqModel.params = params
        //: AppRequestTool.startPostRequest(model: reqModel) { succeed, result, errorModel in
        ArgumentTransform.at(model: reqModel) { succeed, result, errorModel in
            //: guard succeed == true || errorModel?.errorCode == 405 else { 
            guard succeed == true || errorModel?.errorCode == 405 else { // 验证接口失败，重试接口
                //: DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                    //: self.transcationPurchasedToCheck(transactionId, .Subscribe)
                    self.buildPrompt(transactionId, .Subscribe)
                }
                //: return
                return
            }

            //: let dict = result as? [String: Any]
            let dict = result as? [String: Any]
            //: let reportMoney: Double = {
            let reportMoney: Double = {
                //: if let d = dict?["reportMoney"] as? Double { return d }
                if let d = dict?[(dataPetitionTagValue.lowercased() + "rtMoney")] as? Double { return d }
                //: return 0
                return 0
            //: }()
            }()

            // 过滤已验证成功的订单数据
            //: let newSubscribeCacheList = self.subscribeCacheList.filter({$0["transactionId"] != transactionId})
            let newSubscribeCacheList = self.subscribeCacheList.filter({$0[(show_oldBoyNetworkString.replacingOccurrences(of: "challenge", with: "r") + "sact" + String(userTitleMessageCancelStatus.prefix(5)))] != transactionId})
            //: let diskPath = self.getSubscribeCachePath()
            let diskPath = self.to()
            //: NSKeyedArchiver.archiveRootObject(newSubscribeCacheList, toFile: diskPath)
            NSKeyedArchiver.archiveRootObject(newSubscribeCacheList, toFile: diskPath)
 
            // 成功回调
            //: self.completionHandle?(.veritySucceed, reportMoney, .Subscribe)
            self.completionHandle?(.veritySucceed, reportMoney, .Subscribe)
        }
    }
}

// MARK: - Event
//: extension AppleIAPManager {
extension PastForceContainer {
    /// 初始化数据
    //: private func iap_initData() {
    private func object() {
        //: self.payCacheList = getLocalPayCacheList(payType: .Pay)
        self.payCacheList = content(payType: .Pay)
        //: self.subscribeCacheList = getLocalPayCacheList(payType: .Subscribe)
        self.subscribeCacheList = content(payType: .Subscribe)
        //: self.createOrderId = nil
        self.createOrderId = nil
    }
    
    /// 获取缓存列表
    /// - Parameter payType: 支付类型
    /// - Returns: 缓存列表
    //: private func getLocalPayCacheList(payType: ApplePayType) -> [[String: String]] {
    private func content(payType: CoordinatorScreen) -> [[String: String]] {
        //: var list: [[String: String]]?
        var list: [[String: String]]?
        //: var diskPath = ""
        var diskPath = ""
        //: if payType == .Pay {
        if payType == .Pay {
            //: diskPath = getPayCachePath()
            diskPath = fromDate()
        //: } else {
        } else {
            //: diskPath = getSubscribeCachePath()
            diskPath = to()
        }
        
        //: if FileManager.default.fileExists(atPath: diskPath) {
        if FileManager.default.fileExists(atPath: diskPath) {
            //: list = NSKeyedUnarchiver.unarchiveObject(withFile: diskPath) as? [[String: String]]
            list = NSKeyedUnarchiver.unarchiveObject(withFile: diskPath) as? [[String: String]]
            //: if list == nil {
            if list == nil {
               //: try? FileManager.default.removeItem(atPath: diskPath)
               try? FileManager.default.removeItem(atPath: diskPath)
            }
        }
        //: if list == nil {
        if list == nil {
            //: list = [[String: String]]()
            list = [[String: String]]()
        }
        //: return list!
        return list!
    }
    
    /// 获取【购买】缓存路径【和uid关联】
    /// - Returns: 缓存路径
    //: private func getPayCachePath() -> String {
    private func fromDate() -> String {
        //: let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        //: let appDirectoryPath = (documentDirectoryPath as NSString).appendingPathComponent("App")
        let appDirectoryPath = (documentDirectoryPath as NSString).appendingPathComponent((String(k_receiveDeviceKey.prefix(3))))
        
        //: let fileManager = FileManager.default
        let fileManager = FileManager.default
        //: if fileManager.fileExists(atPath: appDirectoryPath) == false {
        if fileManager.fileExists(atPath: appDirectoryPath) == false {
           //: try? fileManager.createDirectory(atPath: appDirectoryPath, withIntermediateDirectories: true)
           try? fileManager.createDirectory(atPath: appDirectoryPath, withIntermediateDirectories: true)
        }
    
        //: let filePath = (appDirectoryPath as NSString).appendingPathComponent("OrderTransactionInfo_Cache")
        let filePath = (appDirectoryPath as NSString).appendingPathComponent((String(controllerFilterValue) + String(controllerCameraSecret)))
        //: return filePath
        return filePath
    }
    
    /// 获取【订阅】缓存路径【和uid关联】
    /// - Returns: 缓存路径
    //: private func getSubscribeCachePath() -> String {
    private func to() -> String {
        //: let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        //: let appDirectoryPath = (documentDirectoryPath as NSString).appendingPathComponent("App")
        let appDirectoryPath = (documentDirectoryPath as NSString).appendingPathComponent((String(k_receiveDeviceKey.prefix(3))))
        
        //: let fileManager = FileManager.default
        let fileManager = FileManager.default
        //: if fileManager.fileExists(atPath: appDirectoryPath) == false {
        if fileManager.fileExists(atPath: appDirectoryPath) == false {
           //: try? fileManager.createDirectory(atPath: appDirectoryPath, withIntermediateDirectories: true)
           try? fileManager.createDirectory(atPath: appDirectoryPath, withIntermediateDirectories: true)
        }
    
        //: let filePath = (appDirectoryPath as NSString).appendingPathComponent("OrderTransactionInfo_Subscribe_Cache")
        let filePath = (appDirectoryPath as NSString).appendingPathComponent(String(bytes: app_usResult.reversed(), encoding: .utf8)!)
        //: return filePath
        return filePath
    }
 
    /// 获取本地收据数据
    /// - Parameters:
    ///   - transactionId: 收据标识符
    ///   - payType: 支付类型
    /// - Returns: 收据数据
    //: fileprivate func getVerifyData(_ transactionId: String, _ payType: ApplePayType) -> String? {
    fileprivate func moveCountoStratfordOnAvon(_ transactionId: String, _ payType: CoordinatorScreen) -> String? {
        // 有未完成的订单，先取缓存
        //: var paramsArr = [[String: String]]()
        var paramsArr = [[String: String]]()
        //: switch(payType) {
        switch(payType) {
        //: case .Pay:
        case .Pay:
            //: paramsArr = self.payCacheList.filter({$0["transactionId"] == transactionId})
            paramsArr = self.payCacheList.filter({$0[(show_oldBoyNetworkString.replacingOccurrences(of: "challenge", with: "r") + "sact" + String(userTitleMessageCancelStatus.prefix(5)))] == transactionId})
        //: case .Subscribe:
        case .Subscribe:
            //: paramsArr = self.subscribeCacheList.filter({$0["transactionId"] == transactionId})
            paramsArr = self.subscribeCacheList.filter({$0[(show_oldBoyNetworkString.replacingOccurrences(of: "challenge", with: "r") + "sact" + String(userTitleMessageCancelStatus.prefix(5)))] == transactionId})
        }
        //: if paramsArr.count > 0 && paramsArr.first!["verifyData"] != nil {
        if paramsArr.count > 0 && paramsArr.first![String(bytes: k_eventFlag.map{levelScene(production: $0)}, encoding: .utf8)!] != nil {
            //: return paramsArr.first!["verifyData"]
            return paramsArr.first![String(bytes: k_eventFlag.map{levelScene(production: $0)}, encoding: .utf8)!]
        }

        // 取本地
        //: guard let receiptUrl = Bundle.main.appStoreReceiptURL else { return nil }
        guard let receiptUrl = Bundle.main.appStoreReceiptURL else { return nil }
        //: let data = NSData(contentsOf: receiptUrl)
        let data = NSData(contentsOf: receiptUrl)
        //: let receiptStr = data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        let receiptStr = data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        //: return receiptStr
        return receiptStr
    }
}

// MARK: - 失败重试流程
//: extension AppleIAPManager {
extension PastForceContainer {
    /// 检测未完成的苹果支付【只会重试当前登录用户】
    //: func iap_checkUnfinishedTransactions() {
    func key() {
        //: iap_initData()
        object()

        // 【购买】失败重试
        //: for dict in self.payCacheList {
        for dict in self.payCacheList {
            //: iap_failedRetry(dict["transactionId"], .Pay)
            withCurrent(dict[(show_oldBoyNetworkString.replacingOccurrences(of: "challenge", with: "r") + "sact" + String(userTitleMessageCancelStatus.prefix(5)))], .Pay)
        }
        
        // 【订阅】失败重试
        //: for dict in self.subscribeCacheList {
        for dict in self.subscribeCacheList {
            //: iap_failedRetry(dict["transactionId"], .Subscribe)
            withCurrent(dict[(show_oldBoyNetworkString.replacingOccurrences(of: "challenge", with: "r") + "sact" + String(userTitleMessageCancelStatus.prefix(5)))], .Subscribe)
        }
    }
    
    /// 失败重试
    /// - Parameters:
    ///   - transactionId: Id
    ///   - payType: 支付类型
    //: private func iap_failedRetry(_ transactionId: String?, _ payType: ApplePayType) {
    private func withCurrent(_ transactionId: String?, _ payType: CoordinatorScreen) {
        //: guard let transactionId = transactionId else { return }
        guard let transactionId = transactionId else { return }
        // 初始化每个交易请求次数
        //: reqRetryCountDict[transactionId] = 0
        reqRetryCountDict[transactionId] = 0
        // 3. 服务端校验流程
        //: transcationPurchasedToCheck(transactionId, payType)
        buildPrompt(transactionId, payType)
    }
}

// MARK: - 苹果正常支付流程
//: extension AppleIAPManager {
extension PastForceContainer {
    /// 发起苹果支付【1.创建订单； 2.发起苹果支付； 3.服务端校验】
    /// - Parameters:
    ///   - purchID: 产品ID
    ///   - payType: 支付类型
    ///   - handle: 回调
    ///   - source: 0 常规充值 1 观看视频后充值或订阅
    //: func iap_startPurchase(productId: String, payType: ApplePayType, source: Int = 0, handle: @escaping IAPcompletionHandle) {
    func pad(productId: String, payType: CoordinatorScreen, source: Int = 0, handle: @escaping IAPcompletionHandle) {
        //: iap_initData()
        object()
        //: self.completionHandle = handle
        self.completionHandle = handle
        //: self.currentPayType = payType
        self.currentPayType = payType
        
        // 1. 根据类型创建订单
        //: switch(payType) {
        switch(payType) {
        //: case .Pay:
        case .Pay:
            //: req_pay_createAppleOrder(productId: productId, source: source) { [weak self] orderId, succeed in
            frame(productId: productId, source: source) { [weak self] orderId, succeed in
                //: guard let self = self else { return }
                guard let self = self else { return }
                //: guard succeed == true && orderId != nil else { 
                guard succeed == true && orderId != nil else { // 订单创建失败
                    //: self.completionHandle?(.createOrderFail, 0, .Pay)
                    self.completionHandle?(.createOrderFail, 0, .Pay)
                    //: return
                    return
                }
                
                //: self.createOrderId = orderId
                self.createOrderId = orderId
                //: self.requestProductInfo(productId)
                self.fail(productId)
            }
        
        //: case .Subscribe:
        case .Subscribe:
            //: req_subscribe_createAppleOrder(productId: productId, source: source) { [weak self] orderId, succeed in
            evaluateBack(productId: productId, source: source) { [weak self] orderId, succeed in
                //: guard let self = self else { return }
                guard let self = self else { return }
                //: guard succeed == true && orderId != nil else { 
                guard succeed == true && orderId != nil else { // 订单创建失败
                    //: self.completionHandle?(.createOrderFail, 0, .Subscribe)
                    self.completionHandle?(.createOrderFail, 0, .Subscribe)
                    //: return
                    return
                }
                
                //: self.createOrderId = orderId
                self.createOrderId = orderId
                //: self.requestProductInfo(productId)
                self.fail(productId)
            }
        }
    }
        
    // 2 发起苹果支付，查询apple内购商品
    //: fileprivate func requestProductInfo(_ productId: String) {
    fileprivate func fail(_ productId: String) {
        //: guard SKPaymentQueue.canMakePayments() else {
        guard SKPaymentQueue.canMakePayments() else {
            //: self.completionHandle?(.notArrow, 0, currentPayType)
            self.completionHandle?(.notArrow, 0, currentPayType)
            //: return
            return
        }
        
        // 销毁当前请求
        //: self.clearProductInfoRequest()
        self.user()
        // 查询apple内购商品
        //: let identifiers: Set<String> = [productId]
        let identifiers: Set<String> = [productId]
        //: productInfoReq = SKProductsRequest(productIdentifiers: identifiers)
        productInfoReq = SKProductsRequest(productIdentifiers: identifiers)
        //: productInfoReq?.delegate = self
        productInfoReq?.delegate = self
        //: productInfoReq?.start()
        productInfoReq?.start()
    }
    
    // 销毁当前请求
    //: fileprivate func clearProductInfoRequest() {
    fileprivate func user() {
        //: guard productInfoReq != nil else { return }
        guard productInfoReq != nil else { return }
        //: productInfoReq?.delegate = nil
        productInfoReq?.delegate = nil
        //: productInfoReq?.cancel()
        productInfoReq?.cancel()
        //: productInfoReq = nil
        productInfoReq = nil
    }
}

// MARK: - SKProductsRequestDelegate【商品查询】
//: extension AppleIAPManager: SKProductsRequestDelegate {
extension PastForceContainer: SKProductsRequestDelegate {
    // 查询apple内购商品成功回调
     //: func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
     func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
         //: guard response.products.count > 0 else {
         guard response.products.count > 0 else {
             //: self.completionHandle?( .noProductId, 0, currentPayType)
             self.completionHandle?( .noProductId, 0, currentPayType)
             //: return
             return
         }
         
         //: let payment = SKPayment(product: response.products.first!)
         let payment = SKPayment(product: response.products.first!)
         //: SKPaymentQueue.default().add(payment)
         SKPaymentQueue.default().add(payment)
     }
    
    // 查询apple内购商品失败
    //: func request(_ request: SKRequest, didFailWithError error: Error) {
    func request(_ request: SKRequest, didFailWithError error: Error) {
        //: self.completionHandle?( .noProductId, 0, currentPayType)
        self.completionHandle?( .noProductId, 0, currentPayType)
    }
    
    // 查询apple内购商品完成
    //: func requestDidFinish(_ request: SKRequest) {
    func requestDidFinish(_ request: SKRequest) {
        
    }
}

// MARK: - SKPaymentTransactionObserver【支付回调】
//: extension AppleIAPManager: SKPaymentTransactionObserver {
extension PastForceContainer: SKPaymentTransactionObserver {
    /// 2.2 apple内购完成回调
    //: func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        //: for transaction in transactions {
        for transaction in transactions {
            //: switch transaction.transactionState {
            switch transaction.transactionState {
            //: case .purchasing:  
            case .purchasing:  // 交易中
                //: break
                break
                
            //: case .purchased:   
            case .purchased:   // 交易成功
                /**
                 original.transactionIdentifier 首次订阅时为nil，transaction.transactionIdentifier有值；
                 后续自动订阅、续订时，original.transactionIdentifier为首次订阅时生成的transaction.transactionIdentifier，值固定不变；
                 每次订阅transaction.transactionIdentifier都不一样，为当前交易的标识；
                 */
                //: if transaction.original != nil && createOrderId == nil { 
                if transaction.original != nil && createOrderId == nil { // 启动自动续订时，不需要调用服务端验证接口
                    //: self.completionHandle?(.renewSucceed, 0, currentPayType)
                    self.completionHandle?(.renewSucceed, 0, currentPayType)
                //: } else { 
                } else { // 普通购买和订阅
                    // 初始化每个交易请求次数
                    //: reqRetryCountDict[transaction.transactionIdentifier!] = 0
                    reqRetryCountDict[transaction.transactionIdentifier!] = 0
                    // 3. 服务端校验流程
                    //: transcationPurchasedToCheck(transaction.transactionIdentifier!, self.currentPayType)
                    buildPrompt(transaction.transactionIdentifier!, self.currentPayType)
                }
                // 移除苹果支付系统缓存
                //: SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                //: createOrderId = nil
                createOrderId = nil
                
            //: case .failed:      
            case .failed:      // 交易失败/取消
                //: SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                //: self.completionHandle?(.failed, 0, currentPayType)
                self.completionHandle?(.failed, 0, currentPayType)
                //: createOrderId = nil
                createOrderId = nil

            //: case .restored:    
            case .restored:    // 已购买过该商品
                //: SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                //: self.completionHandle?(.restored, 0, currentPayType)
                self.completionHandle?(.restored, 0, currentPayType)
                //: createOrderId = nil
                createOrderId = nil
                
            //: case .deferred:    
            case .deferred:    // 交易延期
                //: SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                //: self.completionHandle?(.deferred, 0, currentPayType)
                self.completionHandle?(.deferred, 0, currentPayType)
                //: createOrderId = nil
                createOrderId = nil
                
            //: @unknown default:
            @unknown default:
                //: SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                //: self.completionHandle?(.unknow, 0, currentPayType)
                self.completionHandle?(.unknow, 0, currentPayType)
                //: createOrderId = nil
                createOrderId = nil
                //: fatalError(" 未知的交易类型")
                fatalError((managerAgainMessage))
            }
        }
    }
 
    /// 3. 服务端校验流程
    /// - Parameters:
    ///   - transactionId: 交易唯一标识符
    ///   - payType: 支付类型
    //: fileprivate func transcationPurchasedToCheck(_ transactionId: String, _ payType: ApplePayType) {
    fileprivate func buildPrompt(_ transactionId: String, _ payType: CoordinatorScreen) {
        //: guard let receiptStr = getVerifyData(transactionId, payType) else {
        guard let receiptStr = moveCountoStratfordOnAvon(transactionId, payType) else {
            //: self.completionHandle?(.verityFail, 0, payType)
            self.completionHandle?(.verityFail, 0, payType)
            //: return
            return
        }

        // 缓存支付成功信息，防止接口校验失败
        //: if createOrderId != nil { 
        if createOrderId != nil { // 正常支付流程
            //: switch(payType) {
            switch(payType) {
            //: case .Pay:
            case .Pay:
                //: if self.payCacheList.filter({$0["transactionId"] == transactionId || $0["orderId"] == createOrderId}).count == 0 {  // 防止重复添加缓存数据
                if self.payCacheList.filter({$0[(show_oldBoyNetworkString.replacingOccurrences(of: "challenge", with: "r") + "sact" + String(userTitleMessageCancelStatus.prefix(5)))] == transactionId || $0[String(bytes: managerQuantityTrustPhoneValue.map{$0^192}, encoding: .utf8)!] == createOrderId}).count == 0 {  // 防止重复添加缓存数据
                    //: let cacheDict = ["transactionId": transactionId,
                    let cacheDict = [(show_oldBoyNetworkString.replacingOccurrences(of: "challenge", with: "r") + "sact" + String(userTitleMessageCancelStatus.prefix(5))): transactionId,
                                     //: "orderId": createOrderId!,
                                     String(bytes: managerQuantityTrustPhoneValue.map{$0^192}, encoding: .utf8)!: createOrderId!,
                                     //: "verifyData": receiptStr]
                                     String(bytes: k_eventFlag.map{levelScene(production: $0)}, encoding: .utf8)!: receiptStr]
                    //: self.payCacheList.append(cacheDict)
                    self.payCacheList.append(cacheDict)
                    //: let diskPath = self.getPayCachePath()
                    let diskPath = self.fromDate()
                    //: NSKeyedArchiver.archiveRootObject(self.payCacheList, toFile: diskPath)
                    NSKeyedArchiver.archiveRootObject(self.payCacheList, toFile: diskPath)
                }
                
            //: case .Subscribe:
            case .Subscribe:
                //: if self.subscribeCacheList.filter({$0["transactionId"] == transactionId || $0["orderId"] == createOrderId}).count == 0 { // 防止重复添加缓存数据
                if self.subscribeCacheList.filter({$0[(show_oldBoyNetworkString.replacingOccurrences(of: "challenge", with: "r") + "sact" + String(userTitleMessageCancelStatus.prefix(5)))] == transactionId || $0[String(bytes: managerQuantityTrustPhoneValue.map{$0^192}, encoding: .utf8)!] == createOrderId}).count == 0 { // 防止重复添加缓存数据
                    //: let cacheDict = ["transactionId": transactionId,
                    let cacheDict = [(show_oldBoyNetworkString.replacingOccurrences(of: "challenge", with: "r") + "sact" + String(userTitleMessageCancelStatus.prefix(5))): transactionId,
                                     //: "orderId": createOrderId!,
                                     String(bytes: managerQuantityTrustPhoneValue.map{$0^192}, encoding: .utf8)!: createOrderId!,
                                     //: "verifyData": receiptStr]
                                     String(bytes: k_eventFlag.map{levelScene(production: $0)}, encoding: .utf8)!: receiptStr]
                    //: self.subscribeCacheList.append(cacheDict)
                    self.subscribeCacheList.append(cacheDict)
                    //: let diskPath = self.getSubscribeCachePath()
                    let diskPath = self.to()
                    //: NSKeyedArchiver.archiveRootObject(self.subscribeCacheList, toFile: diskPath)
                    NSKeyedArchiver.archiveRootObject(self.subscribeCacheList, toFile: diskPath)
                }
            }
        }
        
        // 限制交易重试最大次数
        //: var reqCount = reqRetryCountDict[transactionId] ?? 0
        var reqCount = reqRetryCountDict[transactionId] ?? 0
        //: reqCount += 1
        reqCount += 1
        //: reqRetryCountDict[transactionId] = reqCount
        reqRetryCountDict[transactionId] = reqCount
        //: if reqCount > APPLE_IAP_MAX_RETRY_COUNT {
        if reqCount > controllerRequestStr {
            //: self.completionHandle?(.verityFail, 0, payType)
            self.completionHandle?(.verityFail, 0, payType)
            //: return
            return
        }
        
        // 3.服务端校验，根据transactionId从缓存中取
        //: switch(payType) {
        switch(payType) {
        //: case .Pay:
        case .Pay:
            //: let paramsArr = self.payCacheList.filter({$0["transactionId"] == transactionId})
            let paramsArr = self.payCacheList.filter({$0[(show_oldBoyNetworkString.replacingOccurrences(of: "challenge", with: "r") + "sact" + String(userTitleMessageCancelStatus.prefix(5)))] == transactionId})
            //: guard paramsArr.count > 0 else { return }
            guard paramsArr.count > 0 else { return }
            //: req_pay_uploadAppletransaction(transactionId, params: paramsArr.first!)
            towardHandle(transactionId, params: paramsArr.first!)
            
        //: case .Subscribe:
        case .Subscribe:
            //: let paramsArr = self.subscribeCacheList.filter({$0["transactionId"] == transactionId})
            let paramsArr = self.subscribeCacheList.filter({$0[(show_oldBoyNetworkString.replacingOccurrences(of: "challenge", with: "r") + "sact" + String(userTitleMessageCancelStatus.prefix(5)))] == transactionId})
            //: guard paramsArr.count > 0 else { return }
            guard paramsArr.count > 0 else { return }
            //: req_subscribe_uploadAppletransaction(transactionId, params: paramsArr.first!)
            inputAfter(transactionId, params: paramsArr.first!)
        }
    }
}