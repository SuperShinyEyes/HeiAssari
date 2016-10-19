//
//  ViewController.swift
//  HeiAssari
//
//  Created by Park Seyoung on 17/10/16.
//  Copyright © 2016 Park Seyoung. All rights reserved.
//

import UIKit
import AudioToolbox
import WebKit
import Kanna
import Alamofire
import AVFoundation
import UserNotifications

struct Constants {
    static let aPlusURL = "https://plus.cs.hut.fi/a1141/2016/"
    static let aPlusLogInURL = "https://plus.cs.hut.fi/accounts/login/?next=/a1141/2016/"
    static let aPlusLogInURLPath = "/shibboleth/login/?next=/a1141/2016/"
    
    static let greenGoblinURLprefix = "https://greengoblin.cs.hut.fi/neuvontajono/sessions/"
    static let greenGoblinURLsuffix = "/manage"
}

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    var webView: WKWebView!
    var label: UILabel!
    var audioPlayer: AVAudioPlayer!
    var students = [Student]()
    var queueChecker = Timer()
    
    private var isOnManagePage: Bool = false {
        didSet {
            if isOnManagePage {
                label.text = "On manage"
                queueChecker = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(parseManagePage), userInfo: nil, repeats: true)
//                parseManagePage()
            } else {
                queueChecker.invalidate()
                label.text = "Not manage"
            }
        }
    }
    
    func parseManagePage() {
        webView.reload()
        let url = webView.url!.absoluteString
        print(">>> parseManagePage() @ \(url)")
//        Alamofire.request(url).responseString { response in
//            print("Success: \(response.result.isSuccess)")
//            self.parseHTML(html: response.result.value!)
//        }
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") {
            (html: Any?, error: Error?) -> Void in
            self.parseHTML(html: html as! String)
//            print(html)
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebView()
        loadLabel()
        loadAVAudioSession()
        loadAudioPlayer()
        loadURL(webView: webView, urlString: Constants.aPlusURL)

    }
    
    func loadAVAudioSession() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.defaultToSpeaker])
            
            NSLog("Succeeded to set audio session category.")
        } catch {
            NSLog("Failed to set audio session category.  Error: \(error)")
        }
        
    }
    
    func loadAudioPlayer() {
//        let song = AVPlayerItem(url: Bundle.main.url(forResource: "silent", withExtension: "mp3")!)
        guard let songURL = Bundle.main.url(forResource: "silent", withExtension: "mp3") else {
            print("Cannot load the song url")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: songURL)
        } catch {
            print("Cannot load the song: \(error)")
        }
        audioPlayer.numberOfLoops = -1
        audioPlayer.play()
//        audioPlayer = AVQueuePlayer(playerItem: song)
//        audioPlayer.actionAtItemEnd = .none
        
    }

    func loadWebView() {
        
        let frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.8))
        webView = WKWebView(frame: frame)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)
    }
    
    func loadURL(webView: WKWebView, urlString: String) {
        let url = URL(string: urlString)
        let urlRequest = URLRequest(url: url!)
        webView.load(urlRequest)
    }
    
    func loadLabel() {
        let webViewHeight = webView.bounds.height
        let frame = CGRect(
            origin: CGPoint(x: 0, y: webViewHeight),
            size: CGSize(
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height - webViewHeight))
        label = UILabel(frame: frame)
        label.text = "Hello"
        label.textColor = UIColor.white
        view.addSubview(label)
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(">>> finish loading")
        
        
        let isURLPrefixManagePagePrefix = webView.url!.absoluteString.hasPrefix(Constants.greenGoblinURLprefix)
        let isURLSuffixManagePagePrefix = webView.url!.absoluteString.hasSuffix(Constants.greenGoblinURLsuffix)
        isOnManagePage = isURLPrefixManagePagePrefix && isURLSuffixManagePagePrefix
        
        // FIXME: Parse HTML by tags
        /**
         # Parsing HTML
         
         For some reason I couldn't parse html using JS such as
         
         webView.stringByEvaluatingJavaScript(from: "document.links")
         webView.stringByEvaluatingJavaScript(from: "document.documentElement.getElementsByTagName('a')")
         
         Those would return Optional()
         
         */

    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        print(">>> createWebViewWith configuration")

        guard navigationAction.targetFrame == nil else { return nil }
        
        webView.load(navigationAction.request)
        
        return nil
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print(">>> didReceiveServerRedirectForProvisionalNavigation: @ \(webView.url!)")
//        let urlRequest = URLRequest(url: webView.url!)
//        webView.load(urlRequest)
    }
    
    func parseHTML(html: String) -> Void {
        print(">>> @parseHTML()")
//        print(html)
        
        if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
            for student in doc.css("table#queue tbody tr") {
                let studentString = student.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                let seperatedString = studentString.components(separatedBy: "\n").map{
                    $0.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                }
                guard seperatedString.count > 3 else {
                    break
                }
                print(">>> Student: \(seperatedString)")
                
                let name = seperatedString[1]
                let time = seperatedString[2]
                if self.isNotStudentInQueue(name: name, time: time) {
                    let seat = seperatedString[3]
                    self.pushStudentToQueue(name: name, time: time, seat: seat)
                } else {
                    print(">>> Already in queue")
                }
                
            }
        }
    }
    
    func isNotStudentInQueue(name: String, time: String) -> Bool {
        let studentsWithSameName = students.filter { $0.name == name }
        guard let _ = studentsWithSameName.first else {
            return true  // Because we don't want to add it to the queue
        }
        return studentsWithSameName.filter { existing in
            existing.time == time
        }.isEmpty
    }
    
    func pushStudentToQueue(name: String, time:String, seat: String) {
        print(">>> pushStudentToQueue()")
        let student = Student(name: name, time: time, seat: seat)
        students.append(student)
        vibratePhone()
        scheduleNotification(student: student)
    }
    

    func scheduleNotification(student: Student) {
        let content = UNMutableNotificationContent()
        content.title = student.name
        content.subtitle = student.time
        content.body = student.seat
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let requestIdentifier = student.name + student.time
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) {
            error in
        }
    }

}

struct Student {
    let name: String
    let time: String
    let seat: String
    var timeAsInt: Int {
        // 14:30 => 14*60 + 30
        let hourAndMinute: [String] = time.components(separatedBy: ":")
        guard let hourAsString = hourAndMinute.first,
            let minuteAsString = hourAndMinute.last,
            let hour = Int(hourAsString),
            let minute = Int(minuteAsString)  else {
            print("Wrong time input: \(hourAndMinute)")
            return -1
        }
        return hour * 60 + minute
    }
}

extension ViewController {
    fileprivate func vibratePhone() {
        print(">>> vibratePhone()")
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
