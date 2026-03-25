
//: Declare String Begin

/*: "offmarket_loop_ :*/
fileprivate let sessionCalendarOutputState:[Character] = ["o","f","f","m","a","r","k","e","t","_","l"]
fileprivate let engineTowardProgressFlag:String = "oop_us remote album"

//: Declare String End

// __DEBUG__
// __CLOSE_PRINT__
//: import Foundation
import Foundation
//: import UserNotifications
import UserNotifications


//: public class LocalPushScheduler: NSObject {
public class EnvironmentArrow: NSObject {
    
    //: public static let shared = LocalPushScheduler()
    public static let shared = EnvironmentArrow()
    
    //: private override init() {
    private override init() {
        //: super.init()
        super.init()
    }
    
    /// 核心调度方法
    /// - Parameters:
    ///   - times: 每天推送的小时点列表 (0-23)，如 [8, 22]。如果为空则清空所有推送。
    ///   - contents: 文案列表。
    //: public func schedule(times: [Int], contents: [String]) {
    public func toAfter(times: [Int], contents: [String]) {
        // 清除之前所有的旧推送任务
        //: UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // 如果数组为空，代表只清除，不再创建新任务
        //: guard !times.isEmpty, !contents.isEmpty else { return }
        guard !times.isEmpty, !contents.isEmpty else { return }
        
        // 过滤掉无效的时间点（判断时间不能大于 24，实际应为 0-23）
        //: let validTimes = times.filter { $0 >= 0 && $0 < 24 }.sorted()
        let validTimes = times.filter { $0 >= 0 && $0 < 24 }.sorted()
        //: guard !validTimes.isEmpty else { return }
        guard !validTimes.isEmpty else { return }
        
        //: let center = UNUserNotificationCenter.current()
        let center = UNUserNotificationCenter.current()
        //: let calendar = Calendar.current
        let calendar = Calendar.current
        //: let now = Date()
        let now = Date()
        
        // 记录文案取到的索引 (按顺序循环取)
        //: var contentIndex = 0
        var contentIndex = 0
        
        // 遍历未来 7 天，每一天都根据 validTimes 创建特定时间点的推送。
        // 将 repeats 设置为 true，并指定 weekday，系统会每周在同一时间重复。
        //: for dayOffset in 0..<7 {
        for dayOffset in 0..<7 {
            // 获取目标日期以便拿到 weekday
            //: guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }
            guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }
            //: let dayComponents = calendar.dateComponents([.weekday], from: targetDate)
            let dayComponents = calendar.dateComponents([.weekday], from: targetDate)
            //: guard let weekday = dayComponents.weekday else { continue }
            guard let weekday = dayComponents.weekday else { continue }
            
            //: for hour in validTimes {
            for hour in validTimes {
                //: let content = UNMutableNotificationContent()
                let content = UNMutableNotificationContent()
                //: content.title = AppName as! String
                content.title = givenTextStr as! String
                
                // 循环取文案
                //: let text = contents[contentIndex % contents.count]
                let text = contents[contentIndex % contents.count]
                //: content.body = text
                content.body = text
                //: content.sound = .default
                content.sound = .default
                
                // 设置触发器组件
                //: var triggerComponents = DateComponents()
                var triggerComponents = DateComponents()
                //: triggerComponents.weekday = weekday 
                triggerComponents.weekday = weekday // 周几
                //: triggerComponents.hour = hour       
                triggerComponents.hour = hour       // 几点
                //: triggerComponents.minute = 0
                triggerComponents.minute = 0
                //: triggerComponents.second = 0
                triggerComponents.second = 0
                //: let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
                
                // 创建唯一标识符 (基于周几和小时，确保 7天xN次 都不重合)
                //: let identifier = "offmarket_loop_\(weekday)_\(hour)"
                let identifier = (String(sessionCalendarOutputState) + String(engineTowardProgressFlag.prefix(4))) + "\(weekday)_\(hour)"
                //: let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                //: center.add(request) { _ in }
                center.add(request) { _ in }
                // 递增索引，下次取下一条文案
                //: contentIndex += 1
                contentIndex += 1
            }
        }
    }
}