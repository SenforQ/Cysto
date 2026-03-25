// __DEBUG__
// __CLOSE_PRINT__
//
//  PastPause.swift
//  OverseaH5
//
//  Created by young on 2025/9/24.
//

//: import UIKit
import UIKit
//: import Foundation
import Foundation
//: import WebKit
import WebKit

//: class AppWebViewScriptDelegateHandler: NSObject, WKScriptMessageHandler {
class PastPause: NSObject, WKScriptMessageHandler {
    //: weak var scriptDelegate: WKScriptMessageHandler?
    weak var scriptDelegate: WKScriptMessageHandler?
    
    //: init(_ scriptDelegate: WKScriptMessageHandler) {
    init(_ scriptDelegate: WKScriptMessageHandler) {
        //: super.init()
        super.init()
        //: self.scriptDelegate = scriptDelegate
        self.scriptDelegate = scriptDelegate
    }
    
    //: func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        //: print("js call method name = \(message.name), message = \(message.body)")
        //: DispatchQueue.main.async {
        DispatchQueue.main.async {
            //: self.scriptDelegate?.userContentController(userContentController, didReceive: message)
            self.scriptDelegate?.userContentController(userContentController, didReceive: message)
        }
    }
}