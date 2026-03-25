
//: Declare String Begin

/*: "Net Error, Try again later" :*/
fileprivate let main_itemFromClickSubMessage:[Character] = ["N","e","t"," ","E","r","r","o","r",","]
fileprivate let constGoKey:String = "through body wait Try "
fileprivate let appPleasePathData:[Character] = ["a","g","a","i","n"," ","l","a","t","e","r"]

/*: "data" :*/
fileprivate let main_displayString:String = "DATA"

/*: ":null" :*/
fileprivate let k_coordinatePath:[Character] = [":","n","u","l","l"]

/*: "json error" :*/
fileprivate let serviceDayId:String = "json tool error end given"
fileprivate let appResponseInputResult:[Character] = ["e","r","r","o","r"]

/*: "platform=iphone&version= :*/
fileprivate let showGrantFlag:String = "pwhite"
fileprivate let main_rePermissionResult:String = "buttonor"
fileprivate let configUntilUrl:String = "one&vevar camera application title ok"

/*: &packageId= :*/
fileprivate let mainSoundState:[Character] = ["&","p","a","c","k"]
fileprivate let onGivenPath:String = "success superageId="

/*: &bundleId= :*/
fileprivate let app_gainsayArrayKey:[Character] = ["&","b","u","n","d","l","e","I","d","="]

/*: &lang= :*/
fileprivate let networkDataConverterKey:String = "black option bounce&lang="

/*: ; build: :*/
fileprivate let constSecretReTitle:[Character] = [";"," "]
fileprivate let k_pastPrivacyName:[Character] = ["b","u","i","l","d",":"]

/*: ; iOS  :*/
fileprivate let constCountPath:String = "lease demonstrate; iOS "

//: Declare String End

// __DEBUG__
// __CLOSE_PRINT__
//: import UIKit
import UIKit
//: import Alamofire
import Alamofire
//: import CoreMedia
import CoreMedia
//: import HandyJSON
import HandyJSON
 
//: typealias FinishBlock = (_ succeed: Bool, _ result: Any?, _ errorModel: AppErrorResponse?) -> Void
typealias FinishBlock = (_ succeed: Bool, _ result: Any?, _ errorModel: KeyTitle?) -> Void
 
//: @objc class AppRequestTool: NSObject {
@objc class ArgumentTransform: NSObject {
    /// 发起Post请求
    /// - Parameters:
    ///   - model: 请求参数
    ///   - completion: 回调
    //: class func startPostRequest(model: AppRequestModel, completion: @escaping FinishBlock) {
    class func at(model: OnlyPresentModel, completion: @escaping FinishBlock) {
        //: let serverUrl = self.buildServerUrl(model: model)
        let serverUrl = self.startBar(model: model)
        //: let headers = self.getRequestHeader(model: model)
        let headers = self.unfinished(model: model)
        //: AF.request(serverUrl, method: .post, parameters: model.params, headers: headers, requestModifier: { $0.timeoutInterval = 10.0 }).responseData { [self] responseData in
        AF.request(serverUrl, method: .post, parameters: model.params, headers: headers, requestModifier: { $0.timeoutInterval = 10.0 }).responseData { [self] responseData in
            //: switch responseData.result {
            switch responseData.result {
            //: case .success:
            case .success:
                //: func__requestSucess(model: model, response: responseData.response!, responseData: responseData.data!, completion: completion)
                substance(model: model, response: responseData.response!, responseData: responseData.data!, completion: completion)
                
            //: case .failure:
            case .failure:
                //: completion(false, nil, AppErrorResponse.init(errorCode: RequestResultCode.NetError.rawValue, errorMsg: "Net Error, Try again later"))
                completion(false, nil, KeyTitle.init(errorCode: CollectionConnect.NetError.rawValue, errorMsg: (String(main_itemFromClickSubMessage) + String(constGoKey.suffix(5)) + String(appPleasePathData))))
            }
        }
    }
    
    //: class func func__requestSucess(model: AppRequestModel, response: HTTPURLResponse, responseData: Data, completion: @escaping FinishBlock) {
    class func substance(model: OnlyPresentModel, response: HTTPURLResponse, responseData: Data, completion: @escaping FinishBlock) {
        //: var responseJson = String(data: responseData, encoding: .utf8)
        var responseJson = String(data: responseData, encoding: .utf8)
        //: responseJson = responseJson?.replacingOccurrences(of: "\"data\":null", with: "\"data\":{}")
        responseJson = responseJson?.replacingOccurrences(of: "\"" + (main_displayString.lowercased()) + "\"" + (String(k_coordinatePath)), with: "" + "\"" + (main_displayString.lowercased()) + "\"" + ":{}")
        //: if let responseModel = JSONDeserializer<AppBaseResponse>.deserializeFrom(json: responseJson) {
        if let responseModel = JSONDeserializer<IssueFoundApplyCoordinator>.deserializeFrom(json: responseJson) {
            //: if responseModel.errno == RequestResultCode.Normal.rawValue {
            if responseModel.errno == CollectionConnect.Normal.rawValue {
                //: completion(true, responseModel.data, nil)
                completion(true, responseModel.data, nil)
            //: } else {
            } else {
                //: completion(false, responseModel.data, AppErrorResponse.init(errorCode: responseModel.errno, errorMsg: responseModel.msg ?? ""))
                completion(false, responseModel.data, KeyTitle.init(errorCode: responseModel.errno, errorMsg: responseModel.msg ?? ""))
                //: switch responseModel.errno {
                switch responseModel.errno {
//                case CollectionConnect.NeedReLogin.rawValue:
//                    NotificationCenter.default.post(name: DID_LOGIN_OUT_SUCCESS_NOTIFICATION, object: nil, userInfo: nil)
                //: default:
                default:
                    //: break
                    break
                }
            }
        //: } else {
        } else {
            //: completion(false, nil, AppErrorResponse.init(errorCode: RequestResultCode.NetError.rawValue, errorMsg: "json error"))
            completion(false, nil, KeyTitle.init(errorCode: CollectionConnect.NetError.rawValue, errorMsg: (String(serviceDayId.prefix(5)) + String(appResponseInputResult))))
        }
                
    }
    
    //: class func buildServerUrl(model: AppRequestModel) -> String {
    class func startBar(model: OnlyPresentModel) -> String {
        //: var serverUrl: String = model.requestServer
        var serverUrl: String = model.requestServer
        //: let otherParams = "platform=iphone&version=\(AppNetVersion)&packageId=\(PackageID)&bundleId=\(AppBundle)&lang=\(UIDevice.interfaceLang)"
        let otherParams = (showGrantFlag.replacingOccurrences(of: "white", with: "la") + main_rePermissionResult.replacingOccurrences(of: "button", with: "tf") + "m=iph" + String(configUntilUrl.prefix(6)) + "rsion=") + "\(showSameMessage)" + (String(mainSoundState) + String(onGivenPath.suffix(6))) + "\(routerMustSuccessVersionFlag)" + (String(app_gainsayArrayKey)) + "\(mainLogWarnToken)" + (String(networkDataConverterKey.suffix(6))) + "\(UIDevice.interfaceLang)"
        //: if !model.requestPath.isEmpty {
        if !model.requestPath.isEmpty {
            //: serverUrl.append("/\(model.requestPath)")
            serverUrl.append("/\(model.requestPath)")
        }
        //: serverUrl.append("?\(otherParams)")
        serverUrl.append("?\(otherParams)")
        
        //: return serverUrl
        return serverUrl
    }
    
    /// 获取请求头参数
    /// - Parameter model: 请求模型
    /// - Returns: 请求头参数
    //: class func getRequestHeader(model: AppRequestModel) -> HTTPHeaders {
    class func unfinished(model: OnlyPresentModel) -> HTTPHeaders {
        //: let userAgent = "\(AppName)/\(AppVersion) (\(AppBundle); build:\(AppBuildNumber); iOS \(UIDevice.current.systemVersion); \(UIDevice.modelName))"
        let userAgent = "\(givenTextStr)/\(helperReportCameraToken) (\(mainLogWarnToken)" + (String(constSecretReTitle) + String(k_pastPrivacyName)) + "\(kAdjustFlag)" + (String(constCountPath.suffix(6))) + "\(UIDevice.current.systemVersion); \(UIDevice.modelName))"
        //: let headers = [HTTPHeader.userAgent(userAgent)]
        let headers = [HTTPHeader.userAgent(userAgent)]
        //: return HTTPHeaders(headers)
        return HTTPHeaders(headers)
    }
}
 