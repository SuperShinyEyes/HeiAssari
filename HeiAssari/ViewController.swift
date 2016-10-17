//
//  ViewController.swift
//  HeiAssari
//
//  Created by Park Seyoung on 17/10/16.
//  Copyright © 2016 Park Seyoung. All rights reserved.
//

import UIKit
import AudioToolbox

struct Constants {
    static let aPlusURL = "https://plus.cs.hut.fi/a1141/2016"
    static let aPlusLogInURL = "https://plus.cs.hut.fi/accounts/login/?next=/a1141/2016/"
    static let aPlusLogInURLPath = "/shibboleth/login/?next=/a1141/2016/"
}

class ViewController: UIViewController, UIWebViewDelegate {
    
    var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebView()
        loadURL(webView: webView, urlString: Constants.aPlusURL)

    }

    
    func loadWebView() {
        let frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.8))
        webView = UIWebView(frame: frame)
        webView.delegate = self
        
        view.addSubview(webView)
    }
    
    func loadURL(webView: UIWebView, urlString: String) {
        let url = URL(string: urlString)
        let urlRequest = URLRequest(url: url!)
        webView.loadRequest(urlRequest)
    }
    
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if let url = webView.request?.url?.absoluteString {
            if url == Constants.aPlusLogInURL {
                
            }
        }
        let doc: String? = webView.stringByEvaluatingJavaScript(from: "document.documentElement.outerHTML")
        
        // FIXME: Parse HTML by tags
        /**
            # Parsing HTML
         
            For some reason I couldn't parse html using JS such as
         
                webView.stringByEvaluatingJavaScript(from: "document.links")
                webView.stringByEvaluatingJavaScript(from: "document.documentElement.getElementsByTagName('a')")
         
            Those would return Optional()
         
        */
        
        print(doc)
        if let doc = doc {
            if doc.contains(Constants.aPlusLogInURLPath) {
                print(">>> Should log in")
                vibratePhone()
            } else {
                print(">>> logged in")
            }
        }
    }

    

}

extension ViewController {
    fileprivate func vibratePhone() {
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
    }
}
