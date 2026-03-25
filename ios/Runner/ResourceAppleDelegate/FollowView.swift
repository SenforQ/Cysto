
//: Declare String Begin

/*: "init(coder:) has not been implemented" :*/
fileprivate let sessionPastOpenPath:[UInt8] = [0xca,0xcf,0xca,0xd5,0x89,0xc4,0xd0,0xc5,0xc6,0xd3,0x9b,0x8a,0x81,0xc9,0xc2,0xd4,0x81,0xcf,0xd0,0xd5,0x81,0xc3,0xc6,0xc6,0xcf,0x81,0xca,0xce,0xd1,0xcd,0xc6,0xce,0xc6,0xcf,0xd5,0xc6,0xc5]

fileprivate func mainPart(point num: UInt8) -> UInt8 {
    let value = Int(num) + 159
    if value > 255 {
        return UInt8(value - 256)
    } else {
        return UInt8(value)
    }
}

//: Declare String End

// __DEBUG__
// __CLOSE_PRINT__
//
//  FollowView.swift
//  AbroadTalking
//
//  Created by Joeyoung on 2022/9/1.
//

//: import UIKit
import UIKit

//: let kProgressHUD_W            = 80.0
let modelPartStr            = 80.0
//: let kProgressHUD_cornerRadius = 14.0
let noti_systemMaxMsg = 14.0
//: let kProgressHUD_alpha        = 0.9
let k_localMsg        = 0.9
//: let kBackgroundView_alpha     = 0.6
let mainInformValue     = 0.6
//: let kAnimationInterval        = 0.2
let showDataConverterOutputKey        = 0.2
//: let kTransformScale           = 0.9
let cacheAdDisabledDict           = 0.9

//: open class ProgressHUD: UIView {
open class FollowView: UIView {
    //: required public init?(coder: NSCoder) {
    required public init?(coder: NSCoder) {
        //: fatalError("init(coder:) has not been implemented")
        fatalError(String(bytes: sessionPastOpenPath.map{mainPart(point: $0)}, encoding: .utf8)!)
    }
    
    //: static var shared = ProgressHUD()
    static var shared = FollowView()
    //: private override init(frame: CGRect) {
    private override init(frame: CGRect) {
        //: super.init(frame: frame)
        super.init(frame: frame)
        //: self.frame = UIScreen.main.bounds
        self.frame = UIScreen.main.bounds
        //: self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //: self.backgroundColor = UIColor(white: 0, alpha: 0)
        self.backgroundColor = UIColor(white: 0, alpha: 0)
        //: self.addSubview(activityIndicator)
        self.addSubview(activityIndicator)
    }
    //: open override func copy() -> Any { return self }
    open override func copy() -> Any { return self }
    //: open override func mutableCopy() -> Any { return self }
    open override func mutableCopy() -> Any { return self }
    
    //: class func show() {
    class func range() {
        //: show(superView: nil)
        untilDemonstrate(superView: nil)
    }
    //: class func show(superView: UIView?) {
    class func untilDemonstrate(superView: UIView?) {
        //: if superView != nil {
        if superView != nil {
            //: DispatchQueue.main.async {
            DispatchQueue.main.async {
                //: ProgressHUD.shared.frame = superView!.bounds
                FollowView.shared.frame = superView!.bounds
                //: ProgressHUD.shared.activityIndicator.center = ProgressHUD.shared.center
                FollowView.shared.activityIndicator.center = FollowView.shared.center
                //: superView!.addSubview(ProgressHUD.shared)
                superView!.addSubview(FollowView.shared)
            }
        //: } else {
        } else {
            //: DispatchQueue.main.async {
            DispatchQueue.main.async {
                //: ProgressHUD.shared.frame = UIScreen.main.bounds
                FollowView.shared.frame = UIScreen.main.bounds
                //: ProgressHUD.shared.activityIndicator.center = ProgressHUD.shared.center
                FollowView.shared.activityIndicator.center = FollowView.shared.center
                //: AppConfig.getWindow().addSubview(ProgressHUD.shared)
                ForceDomain.leaseAdjust().addSubview(FollowView.shared)
            }
        }
        //: ProgressHUD.shared.hud_startAnimating()
        FollowView.shared.confirm()
    }
    //: class func dismiss() {
    class func filterBack() {
        //: ProgressHUD.shared.hud_stopAnimating()
        FollowView.shared.adjustFrame()
    }
    
    //: private func hud_startAnimating() {
    private func confirm() {
        //: DispatchQueue.main.async {
        DispatchQueue.main.async {
            //: self.backgroundColor = UIColor(white: 0, alpha: 0)
            self.backgroundColor = UIColor(white: 0, alpha: 0)
            //: self.activityIndicator.transform = CGAffineTransform(scaleX: kTransformScale, y: kTransformScale)
            self.activityIndicator.transform = CGAffineTransform(scaleX: cacheAdDisabledDict, y: cacheAdDisabledDict)
            //: self.activityIndicator.alpha = 0
            self.activityIndicator.alpha = 0
            //: UIView.animate(withDuration: kAnimationInterval) {
            UIView.animate(withDuration: showDataConverterOutputKey) {
                //: self.backgroundColor = UIColor(white: 0, alpha: kBackgroundView_alpha)
                self.backgroundColor = UIColor(white: 0, alpha: mainInformValue)
                //: self.activityIndicator.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.activityIndicator.transform = CGAffineTransform(scaleX: 1, y: 1)
                //: self.activityIndicator.alpha = kProgressHUD_alpha
                self.activityIndicator.alpha = k_localMsg
                //: self.activityIndicator.startAnimating()
                self.activityIndicator.startAnimating()
            }
        }
    }
    //: private func hud_stopAnimating() {
    private func adjustFrame() {
        //: DispatchQueue.main.async {
        DispatchQueue.main.async {
            //: UIView.animate(withDuration: kAnimationInterval) {
            UIView.animate(withDuration: showDataConverterOutputKey) {
                //: self.backgroundColor = UIColor(white: 0, alpha: 0)
                self.backgroundColor = UIColor(white: 0, alpha: 0)
                //: self.activityIndicator.transform = CGAffineTransform(scaleX: kTransformScale, y: kTransformScale)
                self.activityIndicator.transform = CGAffineTransform(scaleX: cacheAdDisabledDict, y: cacheAdDisabledDict)
                //: self.activityIndicator.alpha = 0
                self.activityIndicator.alpha = 0
            //: } completion: { finished in
            } completion: { finished in
                //: self.activityIndicator.stopAnimating()
                self.activityIndicator.stopAnimating()
                //: ProgressHUD.shared.removeFromSuperview()
                FollowView.shared.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Lazy load
    //: private lazy var activityIndicator: UIActivityIndicatorView = {
    private lazy var activityIndicator: UIActivityIndicatorView = {
        //: let indicator = UIActivityIndicatorView(style: .whiteLarge)
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        //: indicator.bounds = CGRect(x: 0, y: 0, width: kProgressHUD_W, height: kProgressHUD_W)
        indicator.bounds = CGRect(x: 0, y: 0, width: modelPartStr, height: modelPartStr)
        //: indicator.center = self.center
        indicator.center = self.center
        //: indicator.backgroundColor = .black
        indicator.backgroundColor = .black
        //: indicator.layer.cornerRadius = kProgressHUD_cornerRadius
        indicator.layer.cornerRadius = noti_systemMaxMsg
        //: indicator.layer.masksToBounds = true
        indicator.layer.masksToBounds = true
        //: return indicator
        return indicator
    //: }()
    }()
}

//: extension ProgressHUD {
extension FollowView {
    //: class func toast(_ str: String?) {
    class func title(_ str: String?) {
        //: toast(str, showTime: 1)
        post(str, showTime: 1)
    }
    //: class func toast(_ str: String?, showTime: CGFloat) {
    class func post(_ str: String?, showTime: CGFloat) {
        //: guard str != nil else { return }
        guard str != nil else { return }
                
        //: let titleLab = UILabel()
        let titleLab = UILabel()
        //: titleLab.backgroundColor = UIColor(white: 0, alpha: 0.8)
        titleLab.backgroundColor = UIColor(white: 0, alpha: 0.8)
        //: titleLab.layer.cornerRadius = 5
        titleLab.layer.cornerRadius = 5
        //: titleLab.layer.masksToBounds = true
        titleLab.layer.masksToBounds = true
        //: titleLab.text = str
        titleLab.text = str
        //: titleLab.font = .systemFont(ofSize: 16)
        titleLab.font = .systemFont(ofSize: 16)
        //: titleLab.textAlignment = .center
        titleLab.textAlignment = .center
        //: titleLab.numberOfLines = 0
        titleLab.numberOfLines = 0
        //: titleLab.textColor = .white
        titleLab.textColor = .white
        //: AppConfig.getWindow().addSubview(titleLab)
        ForceDomain.leaseAdjust().addSubview(titleLab)
        //: let size = titleLab.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 40, height: CGFloat(MAXFLOAT)))
        let size = titleLab.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 40, height: CGFloat(MAXFLOAT)))
        //: titleLab.center = AppConfig.getWindow().center
        titleLab.center = ForceDomain.leaseAdjust().center
        //: titleLab.bounds = CGRect(x: 0, y: 0, width: size.width + 30, height: size.height + 30)
        titleLab.bounds = CGRect(x: 0, y: 0, width: size.width + 30, height: size.height + 30)
        //: titleLab.alpha = 0
        titleLab.alpha = 0
        
        //: UIView.animate(withDuration: 0.2) {
        UIView.animate(withDuration: 0.2) {
            //: titleLab.alpha = 1
            titleLab.alpha = 1
        //: } completion: { finished in
        } completion: { finished in
            //: DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + showTime) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + showTime) {
                //: UIView.animate(withDuration: 0.2) {
                UIView.animate(withDuration: 0.2) {
                    //: titleLab.alpha = 1
                    titleLab.alpha = 1
                //: } completion: { finished in
                } completion: { finished in
                    //: titleLab.removeFromSuperview()
                    titleLab.removeFromSuperview()
                }
            }
        }
    }
}