//
//  ViewController.swift
//  KyabPlayer
//
//  Created by koji on 2016/04/23.
//  Copyright © 2016年 kyab. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController, WebUIDelegate {
    @IBOutlet weak var webView: WebView!
    @IBOutlet weak var lblCurrentTime: NSTextField!
    @IBOutlet weak var lblTotalTime: NSTextField!
    @IBOutlet weak var lblMovieTitle: NSTextField!
    @IBOutlet weak var editURL: NSTextField!
    @IBOutlet weak var sliderPosition: NSSlider!
    @IBOutlet weak var txtLoopStart: NSTextField!
    @IBOutlet weak var txtLoopEnd: NSTextField!
    @IBOutlet weak var chkLoop: NSButton!
    @IBOutlet weak var lblSpeed: NSTextField!
    @IBOutlet weak var sliderSpeed: NSSlider!
    @IBOutlet weak var chkAutoInterval: NSButton!
    
    var youtubeURL : String?
    var currentSec : Double = 0
    var totalSec : Double = 0
    var targetSec : Double = 0
    
    var loopStartSec : Double = 0.0
    var loopEndSec : Double = 0.0
    
    var intervalTimer : Timer?
    
    let VIDEO_ELEMENT = "document.getElementsByClassName('html5-main-video')[0]"

    
    //document.getElementsByClassName("html5-main-video")[0].playbackRate = 0.7
    //document.getElementsByClassName("html5-main-video")[0].duration
    //document.getElementsByClassName("html5-main-video")[0].currentTime
    //document.getElementsByClassName("html5-main-video")[0].currentTime = 5.00


    override func viewDidLoad() {
        super.viewDidLoad()
        updateLoopStartTextField()
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                selector: #selector(ViewController.onTimer(_:)),
                                                userInfo: nil,
                                                repeats: true)
        webView.uiDelegate = self
    }
    
    override func viewWillAppear() {
//        txtLoopStart.becomeFirstResponder()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    @IBAction func onEditURL(_ sender: AnyObject) {
        loadYouTube()
        print("onEditURL")
    }
    
    @IBAction func onLoadButton(_ sender: AnyObject) {
        loadYouTube()
        print("onLoadButton")
    }
    
    func loadYouTube() {
        
        youtubeURL = editURL.stringValue
        let url = URL(string:youtubeURL!)
        
        let req = URLRequest(url: url!)
        webView.mainFrame.load(req)
    }
    
    @IBAction func onSpace(_ sender: AnyObject) {
        print("SPACE")
    }
    
    func webView(_ sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
        print("didFinishLoadForFrame")
        updateLoopEndTextField()
        
    }
    
    func onTimerInterval(_ t:Timer){
        intervalTimer = nil
        webView.stringByEvaluatingJavaScript(from: VIDEO_ELEMENT + ".play()")
    }
    
    func onTimer(_ t:Timer){

        let title = webView.stringByEvaluatingJavaScript(from: "document.title")
        if title != "" {
            lblMovieTitle.stringValue = title!
        }
        
        let currentTimeStr = webView.stringByEvaluatingJavaScript(from: VIDEO_ELEMENT + ".currentTime")
        if (currentTimeStr != "") {
            currentSec = Double(currentTimeStr!)!
            
            if (chkLoop.state == NSOnState){
                if ((loopEndSec > 0.0) && (currentSec > loopEndSec)){
                    
                    if (chkAutoInterval.state == NSOnState){
                        if (intervalTimer==nil){
                            webView.stringByEvaluatingJavaScript(from: VIDEO_ELEMENT + ".currentTime = " + loopStartSec.description)
                            webView.stringByEvaluatingJavaScript(from: VIDEO_ELEMENT + ".pause()")
                            intervalTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self,
                                             selector: #selector(ViewController.onTimerInterval(_:)),
                                             userInfo: nil,
                                             repeats: false)
                        }
                    }else{
                        webView.stringByEvaluatingJavaScript(from: VIDEO_ELEMENT + ".currentTime = " + loopStartSec.description)
                    }

                    return
                }
            }
            
            
            lblCurrentTime.stringValue =
                String(format:"%.2d:%.2d.%.1d",
                       Int(currentSec) / 60,
                       Int(currentSec) % 60,
                       Int(currentSec * 10.0) % 10)

        }
        
        let totalTimeStr = webView.stringByEvaluatingJavaScript(from: VIDEO_ELEMENT + ".duration")
        if (totalTimeStr != "" && totalTimeStr != "NaN") {
            totalSec = Double(totalTimeStr!)!
            lblTotalTime.stringValue =
                String(format:"%.2d:%.2d", Int(totalSec) / 60, Int(totalSec) % 60 )
        }else {
            totalSec = 0.0
            
        }
        
        if (totalSec > 0.0) {
            sliderPosition.doubleValue = currentSec / totalSec
            if (loopEndSec == 0.0){
                loopEndSec = totalSec
                updateLoopEndTextField()
            }
        }
        
    }
    
    
    
    @IBAction func setLoopStartToCurrentTime(_ sender: AnyObject) {
        let currentTimeStr = webView.stringByEvaluatingJavaScript(from: VIDEO_ELEMENT + ".currentTime")
        if (currentTimeStr != "") {
            loopStartSec = Double(currentTimeStr!)!
            updateLoopStartTextField()
        }else{
            loopStartSec = 0.0
        }
    }
    @IBAction func setLoopEndToCurrentTime(_ sender: AnyObject) {
        let currentTimeStr = webView.stringByEvaluatingJavaScript(from: VIDEO_ELEMENT + ".currentTime")
        if (currentTimeStr != "") {
            loopEndSec = Double(currentTimeStr!)!
            updateLoopEndTextField()

        }else{
            loopEndSec = 0.0
        }
    }
    @IBAction func clearLoopStart(_ sender: AnyObject) {
        loopStartSec = 0.0
        updateLoopStartTextField()
    }
    
    @IBAction func clearLoopEnd(_ sender: AnyObject) {
        loopEndSec = 0.0
        updateLoopEndTextField()
    }
    
    @IBAction func seekToLoopStart(_ sender: AnyObject) {
        webView.stringByEvaluatingJavaScript(from: VIDEO_ELEMENT + ".currentTime = " + loopStartSec.description)
        webView.stringByEvaluatingJavaScript(from: VIDEO_ELEMENT + ".play()")
    }
    @IBAction func seekToLoopEnd(_ sender: AnyObject) {
        webView.stringByEvaluatingJavaScript(from: VIDEO_ELEMENT + ".currentTime = " + loopEndSec.description)
    }
    
    @IBAction func sliderChanged(_ sender: AnyObject) {
        targetSec = totalSec * sliderPosition.doubleValue
        lblCurrentTime.stringValue =
            String(format:"%.2d:%.2d.%1d",
                   Int(targetSec) / 60,
                   Int(targetSec) % 60,
                   Int(targetSec * 10.0) % 10)
        
        webView.stringByEvaluatingJavaScript(from: VIDEO_ELEMENT + ".currentTime = " + targetSec.description)
        
//        //Do the trick to detect change ensured.
//        //http://stackoverflow.com/questions/3919905/subclassing-nsslider-need-a-workaround-for-missing-mouse-up-events-cocoa-osx
//        //https://lists.apple.com/archives/cocoa-dev/2008/Oct/msg01251.html
//        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(ViewController.onSliderChangeDone), object: nil)
//        self.performSelector(#selector(ViewController.onSliderChangeDone), withObject: nil, afterDelay: 0.0)

        
    }
    
    func onSliderChangeDone(){
        print("onSliderChangeDone")
        webView.stringByEvaluatingJavaScript(from: VIDEO_ELEMENT + ".currentTime = " + targetSec.description)
    }
    
    @IBAction func playOrPause(_ sender: AnyObject) {

        let result = webView.stringByEvaluatingJavaScript(from: VIDEO_ELEMENT + ".paused")
        if (result == "true"){
            webView.stringByEvaluatingJavaScript(from: VIDEO_ELEMENT + ".play()")
        }else if (result == "false"){
            webView.stringByEvaluatingJavaScript(from: VIDEO_ELEMENT + ".pause()")
        }else{
            
        }
        webView.stringByEvaluatingJavaScript(
            from: "window.onkeydown = function(e) {" +
            "if(e.keyCode == 32 && e.target == document.body) {" +
            VIDEO_ELEMENT + ".pause();" +
            "    e.preventDefault();" +
            "    return false;" +
            "}" +
        "};")
        
        

    }

    func script_getFirstElementForClass(_ className : String) -> String {
        return "document.getElementsByClassName(" + "'" + className + "'" + ")[0]"
    }
    
    @IBAction func onResetPlaybackRate(_ sender: Any) {
        sliderSpeed.doubleValue = 1.0
        self.onSpeedSliderChanged(self)
    }

    @IBAction func onSpeedSliderChanged(_ sender: AnyObject) {
        lblSpeed.stringValue = sliderSpeed.doubleValue.description
        webView.stringByEvaluatingJavaScript(from: VIDEO_ELEMENT + ".playbackRate = "
                + sliderSpeed.doubleValue.description)
        

    }
    
    func updateLoopStartTextField(){
        txtLoopStart.stringValue =
            String(format:"%.2d:%.2d.%.3d",
                   Int(loopStartSec) / 60,
                   Int(loopStartSec) % 60,
                   Int(loopStartSec * 1000.0) % 1000 )
    }
    
    func updateLoopEndTextField(){
        if (loopEndSec > 0.0){
            txtLoopEnd.stringValue =
                String(format:"%.2d:%.2d.%.3d",
                       Int(loopEndSec) / 60,
                       Int(loopEndSec) % 60,
                       Int(loopEndSec * 1000.0) % 1000 )
        }else{
            txtLoopEnd.stringValue = "-:--.---"
        }
    }
    
    @IBAction func retreatLoopStart(_ sender: AnyObject) {
        loopStartSec -= 1.0
        if (loopStartSec < 0.0) {
            loopStartSec = 0.0
        }
        updateLoopStartTextField()
    }

    @IBAction func retreatLoopStartLittle(_ sender: AnyObject) {
        loopStartSec -= 0.2
        if (loopStartSec < 0.0) {
            loopStartSec = 0.0
        }
        updateLoopStartTextField()
    }
    
    @IBAction func advanceLoopStartLittle(_ sender: AnyObject) {
        loopStartSec += 0.2
        if ((totalSec > 0.0) && (totalSec < loopStartSec)) {
            loopStartSec = totalSec
        }
        updateLoopStartTextField()
    }
    
    @IBAction func advanceLoopStart(_ sender: AnyObject) {
        loopStartSec += 1.0
        if ((totalSec > 0.0) && (totalSec < loopStartSec)) {
            loopStartSec = totalSec
        }
        updateLoopStartTextField()
    }

    @IBAction func retreatLoopEnd(_ sender: AnyObject) {
        loopEndSec -= 1.0
        if (loopEndSec < loopStartSec){
            loopEndSec = loopStartSec + 1.0
        }
        updateLoopEndTextField()
    }
    
    @IBAction func retreatLoopEndLittle(_ sender: AnyObject) {
        loopEndSec -= 0.2
        if (loopEndSec < loopStartSec){
            loopEndSec = loopStartSec + 1.0
        }
        updateLoopEndTextField()
    }
    
    @IBAction func advanceLoopEndLittle(_ sender: AnyObject) {
        loopEndSec += 0.2
        if ((totalSec > 0.0) && (totalSec < loopEndSec)){
            loopEndSec = totalSec
        }
        updateLoopEndTextField()
    }
    
    @IBAction func advanceLoopEnd(_ sender: AnyObject) {
        loopEndSec += 1.0
        if ((totalSec > 0.0) && (totalSec < loopEndSec)){
            loopEndSec = totalSec
        }
        updateLoopEndTextField()

    }



    
    @IBAction func gotoSolo(_ sender: AnyObject) {
        let newURL = youtubeURL! + "&t=3m06s"
        let req = URLRequest(url: URL(string:newURL)!)
        webView.mainFrame.load(req)
        
    }

}

