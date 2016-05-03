//
//  ViewController.swift
//  KyabPlayer
//
//  Created by koji on 2016/04/23.
//  Copyright © 2016年 kyab. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController {
    @IBOutlet weak var button: NSButton!
    @IBOutlet weak var webView: WebView!
    @IBOutlet weak var lblCurrentTime: NSTextField!
    @IBOutlet weak var lblTotalTime: NSTextField!
    @IBOutlet weak var lblMovieTitle: NSTextField!
    @IBOutlet weak var editURL: NSTextField!
    @IBOutlet weak var sliderPosition: NSSlider!
    
    var youtubeURL : String?
    var currentSec : Int = 0
    var currentSecLastReliable : Int = 0
    var targetSec : Int = 0
    var totalSec : Int = 0
    var date : NSDate!
    
    let VIDEO_ELEMENT = "document.getElementsByClassName('html5-main-video')[0]"

    
    //document.getElementsByClassName("html5-main-video")[0].playbackRate = 0.7
    //document.getElementsByClassName("html5-main-video")[0].duration
    //document.getElementsByClassName("html5-main-video")[0].currentTime
    //document.getElementsByClassName("html5-main-video")[0].currentTime = 5.00


    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self,
                                                selector: #selector(ViewController.onTimer(_:)),
                                                userInfo: nil,
                                                repeats: true)
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    @IBAction func btnClicked(sender: AnyObject) {
        print("Clicked")
    }
    
    @IBAction func onEditURL(sender: AnyObject) {
        loadYouTube()
        print("onEditURL")
    }
    
    @IBAction func onLoadButton(sender: AnyObject) {
        loadYouTube()
        print("onLoadButton")
    }
    
    func loadYouTube() {
        
        youtubeURL = editURL.stringValue
        let url = NSURL(string:youtubeURL!)
        
        let req = NSURLRequest(URL: url!)
        webView.mainFrame.loadRequest(req)
    }
    
    
    func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
//        NSLog("delegate calld(didFinishLoadForFrame\n");
    }
    
    func onTimer(t:NSTimer){

        let title = webView.stringByEvaluatingJavaScriptFromString("document.title")
        if title != "" {
            lblMovieTitle.stringValue = title
        }
        
        var script = script_getFirstElementForClass("ytp-time-current")
        let currentTime = webView.stringByEvaluatingJavaScriptFromString(script + ".innerHTML")

        //Youtube上でコントロールが非表示な場合は信頼できない値
        //コントロールが表示されている場合、ytp-chorme-controlsクラスである要素のcursorスタイルが"auto"
        if currentTime != "" {
            script = "document.defaultView.getComputedStyle(document.getElementsByClassName('ytp-chrome-controls')[0],'').cursor"
            let cursorStyle = webView.stringByEvaluatingJavaScriptFromString(script)
            if (cursorStyle == "auto") {
                let timeComponents = currentTime.componentsSeparatedByString(":")
                let prevCurrentSec = currentSec
                currentSec = Int(timeComponents[0])! * 60 + Int(timeComponents[1])!
                currentSecLastReliable = currentSec
                if (prevCurrentSec != currentSec){
                    date = NSDate()
                }
                
                lblCurrentTime.stringValue =
                    String(format:"%.2d:%.2d", currentSec / 60, currentSec % 60 )
                //print("currentTime(HTML) = ", currentTime, ", seconds = ", currentSec)
                
            }else{
                //print("currentTime is not reliable(", currentTime, ")")
                currentSec = currentSecLastReliable + Int(NSDate().timeIntervalSinceDate(date))
                lblCurrentTime.stringValue =
                    String(format:"%.2d:%.2d", currentSec / 60, currentSec % 60 )
            }
        }
        
        
        script = script_getFirstElementForClass("ytp-time-duration")
        let duration = webView.stringByEvaluatingJavaScriptFromString(script + ".innerHTML")
        if duration != "" {
            lblTotalTime.stringValue = duration
            
            let timeComponents = duration.componentsSeparatedByString(":")
            totalSec = Int(timeComponents[0])! * 60 + Int(timeComponents[1])!
            
            let currentPositionRatio = 1.0 * Double(currentSec) / Double(totalSec)
            sliderPosition.doubleValue = currentPositionRatio
//            print("currentSec = ", currentSec, ", totalSec = ", totalSec, "ratio = ", currentPositionRatio)
        }
    }
    
    @IBAction func sliderChanged(sender: AnyObject) {
        targetSec = Int(Double(totalSec) * sliderPosition.doubleValue)
        lblCurrentTime.stringValue =
            String(format:"%.2d:%.2d", targetSec / 60, targetSec % 60 )
        
        //Do the trick to detect change ensured.
        //http://stackoverflow.com/questions/3919905/subclassing-nsslider-need-a-workaround-for-missing-mouse-up-events-cocoa-osx
        //https://lists.apple.com/archives/cocoa-dev/2008/Oct/msg01251.html
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(ViewController.onSliderChangeDone), object: nil)
        self.performSelector(#selector(ViewController.onSliderChangeDone), withObject: nil, afterDelay: 0.0)

        
    }
    
    func onSliderChangeDone(){
        print("onSliderChangeDone")
        let newURL = youtubeURL! + String(format:"&t=%dm%ds", targetSec / 60, targetSec % 60)
        let req = NSURLRequest(URL: NSURL(string:newURL)!)
        webView.mainFrame.loadRequest(req)
    }
    
    @IBAction func playOrPause(sender: AnyObject) {

        let result = webView.stringByEvaluatingJavaScriptFromString(VIDEO_ELEMENT + ".paused")
        if (result == "true"){
            webView.stringByEvaluatingJavaScriptFromString(VIDEO_ELEMENT + ".play()")
        }else if (result == "false"){
            webView.stringByEvaluatingJavaScriptFromString(VIDEO_ELEMENT + ".pause()")
        }else{
            
        }

    }

    func script_getFirstElementForClass(className : String) -> String {
        return "document.getElementsByClassName(" + "'" + className + "'" + ")[0]"
    }
    
    @IBAction func gotoSolo(sender: AnyObject) {
        let newURL = youtubeURL! + "&t=3m06s"
        let req = NSURLRequest(URL: NSURL(string:newURL)!)
        webView.mainFrame.loadRequest(req)
        
    }

}

