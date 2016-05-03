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
    var currentSec : Double = 0
    var totalSec : Double = 0
    var targetSec : Double = 0
    
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
        
    }
    
    func onTimer(t:NSTimer){

        let title = webView.stringByEvaluatingJavaScriptFromString("document.title")
        if title != "" {
            lblMovieTitle.stringValue = title
        }
        
        let currentTimeStr = webView.stringByEvaluatingJavaScriptFromString(VIDEO_ELEMENT + ".currentTime")
        if (currentTimeStr != "") {
            currentSec = Double(currentTimeStr)!
            lblCurrentTime.stringValue =
                String(format:"%.2d:%.2d", Int(currentSec) / 60, Int(currentSec) % 60 )

        }
        
        let totalTimeStr = webView.stringByEvaluatingJavaScriptFromString(VIDEO_ELEMENT + ".duration")
        if (totalTimeStr != "" && totalTimeStr != "NaN") {
            totalSec = Double(totalTimeStr)!
            lblTotalTime.stringValue =
                String(format:"%.2d:%.2d", Int(totalSec) / 60, Int(totalSec) % 60 )
        }else {
            totalSec = 0.0
            
        }
        
        if (totalSec > 0.0) {
            sliderPosition.doubleValue = currentSec / totalSec
        }
        

    }
    
    @IBAction func sliderChanged(sender: AnyObject) {
        targetSec = totalSec * sliderPosition.doubleValue
        lblCurrentTime.stringValue =
            String(format:"%.2d:%.2d", Int(targetSec) / 60, Int(targetSec) % 60 )
        
        webView.stringByEvaluatingJavaScriptFromString(VIDEO_ELEMENT + ".currentTime = " + targetSec.description)
        
//        //Do the trick to detect change ensured.
//        //http://stackoverflow.com/questions/3919905/subclassing-nsslider-need-a-workaround-for-missing-mouse-up-events-cocoa-osx
//        //https://lists.apple.com/archives/cocoa-dev/2008/Oct/msg01251.html
//        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(ViewController.onSliderChangeDone), object: nil)
//        self.performSelector(#selector(ViewController.onSliderChangeDone), withObject: nil, afterDelay: 0.0)

        
    }
    
    func onSliderChangeDone(){
        print("onSliderChangeDone")
        webView.stringByEvaluatingJavaScriptFromString(VIDEO_ELEMENT + ".currentTime = " + targetSec.description)
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

