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
import Alamofire


struct Constants {
    static let aPlusURL = "https://plus.cs.hut.fi/a1141/2016/"
    static let aPlusLogInURL = "https://plus.cs.hut.fi/accounts/login/?next=/a1141/2016/"
    static let aPlusLogInURLPath = "/shibboleth/login/?next=/a1141/2016/"
    
    static let greenGoblinURLprefix = "https://greengoblin.cs.hut.fi/neuvontajono/sessions/"
    static let greenGoblinURLsuffix = "/manage"
}

class ViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var label: UILabel!
    
    private var isOnManagePage: Bool = false {
        didSet {
            if isOnManagePage {
                label.text = "On manage"
            } else {
                label.text = "Not manage"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebView()
        loadLabel()
        loadURL(webView: webView, urlString: Constants.aPlusURL)

    }

    func loadWebView() {
        
        let frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.8))
        webView = WKWebView(frame: frame)
        webView.navigationDelegate = self
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
        
        
        isOnManagePage = webView.url!.absoluteString.hasPrefix(Constants.greenGoblinURLprefix) && webView.url!.absoluteString.hasSuffix(Constants.greenGoblinURLsuffix)
        
        // FIXME: Parse HTML by tags
        /**
         # Parsing HTML
         
         For some reason I couldn't parse html using JS such as
         
         webView.stringByEvaluatingJavaScript(from: "document.links")
         webView.stringByEvaluatingJavaScript(from: "document.documentElement.getElementsByTagName('a')")
         
         Those would return Optional()
         
         */


        webView.evaluateJavaScript("document.documentElement.outerHTML") {
            (html: Any?, error: Error?) in
//            print(html)
            if let doc = html as? String {
                if doc.contains(Constants.aPlusLogInURLPath) {
                    print(">>> Should log in")
                    self.vibratePhone()
                } else {
                    print(">>> logged in")
                    if let url = webView.url {
                        print("    >>> logged in @ \(url.absoluteString)")
                        if url.absoluteString == Constants.aPlusURL {
                            webView.load(URLRequest(url: URL(string: "https://plus.cs.hut.fi/a1141/2016/lti-login/78/")!))
                        }
                    }
                    
                }
            }
        }
        
        if let url = webView.url {
            let urlString = url.absoluteString
            
                
                Alamofire.request(urlString).responseString { response in
                    print("Success: \(response.result.isSuccess)")
                    self.parseHTML(html: response.result.value!)
                }
        }
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
        print(html)
//        if let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
//            
//            // Search for nodes by CSS
//            for show in doc.css("td[id^='Text']") {
//                
//                // Strip the string of surrounding whitespace.
//                let showString = show.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
//                
//                // All text involving shows on this page currently start with the weekday.
//                // Weekday formatting is inconsistent, but the first three letters are always there.
//                let regex = try! NSRegularExpression(pattern: "^(mon|tue|wed|thu|fri|sat|sun)", options: [.CaseInsensitive])
//                
//                if regex.firstMatchInString(showString, options: [], range: NSMakeRange(0, showString.characters.count)) != nil {
//                    shows.append(showString)
//                    print(showString + "\n")
//                }
//            }
//        }
    }
    
    // TODO: Check if you could use the same session with WKWebView and Alamofire
}

extension ViewController {
    fileprivate func vibratePhone() {
        print(">>> vibratePhone()")
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
