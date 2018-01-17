//
//  TodayViewController.swift
//  TodayWidget
//
//  Created by Majid Khan on 28/07/2016.
//  Copyright © 2016 Muflihun.com. All rights reserved.
//

import Cocoa
import NotificationCenter
import ObjectMapper

class TodayView : NSView {
    @IBOutlet weak var hadithText : NSTextFieldCell!
}

class TodayViewController: NSViewController, NCWidgetProviding {
    
    var hadithToday : HadithToday?
    var clickRecog : NSClickGestureRecognizer!

    var todayView : TodayView {
        get {
            return self.view as! TodayView
        }
    }
    
    var hadithText : NSTextFieldCell {
        get {
            return self.todayView.hadithText
        }
    }
    
    func fetchHadithOfTheDay() {
        do {
            let json = try String(contentsOfURL: NSURL(string: "http://muflihun.com/svc/hadithtoday")!)
            self.hadithToday = HadithToday.fromJson(json)
            if self.hadithToday != nil {
                self.hadithText.title = self.hadithToday!.text
                self.hadithText.title += " [" + self.hadithToday!.ref + "]"
            }
        } catch {
            print(error)
            if self.hadithToday == nil {
                self.hadithText.title = "Failed to load"
            }
        }
    }
    override func viewDidLoad() {
        
        
        clickRecog = NSClickGestureRecognizer(target: self, action: #selector(TodayViewController.onClick(_:)))
        view.addGestureRecognizer(clickRecog)

        if self.hadithToday == nil {
            self.hadithText.title = "Loading..."
        }
        self.fetchHadithOfTheDay()
    }
    
    override var nibName: String? {
        return "TodayViewController"
    }
    
    func onClick(sender : NSClickGestureRecognizer) {
        if hadithToday != nil {
             NSWorkspace.sharedWorkspace().openURL(NSURL(string: hadithToday!.link)!)
        }
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        let beforeUpdateText = self.hadithToday?.text
        self.fetchHadithOfTheDay()
        if self.hadithToday != nil && self.hadithToday!.text != beforeUpdateText {
            completionHandler(NCUpdateResult.NewData)
        } else {
            completionHandler(NCUpdateResult.NoData)
            
        }
    }


}

class HadithToday : NSObject, Mappable  {
    var link : String = ""
    var text : String = ""
    var ref : String = ""
    
    override init() {
    }
    
    convenience init(link: String, text: String, ref: String) {
        self.init()
        self.link = link
        self.text = text
        self.ref = ref
    }
    
    required init?(_ map: Map) {
        super.init()
        mapping(map)
    }
    
    func mapping(map: Map) {
        self.link <- map["link"]
        self.text <- map["text"]
        self.ref <- map["ref"]
    }
    
    class func fromJson(json:String) -> HadithToday? {
        if json.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.first != "{"
            || json.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.last != "}" {
            return nil
        }
        return Mapper<HadithToday>().map(json)!
    }
}