//
//  DetailViewController.swift
//  lhpe-sample
//
//  Created by Erik Madsen on 5/17/18.
//  Copyright © 2018 Erik Madsen. All rights reserved.
//

import UIKit
import LighthouseKit
import SafariServices

class DetailViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!


    func configureView() {
        // Update the user interface for the detail item.
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let signal = signalItem {
            let urlReq = Lighthouse.urlRequest(forSignalId: signal.id)
            self.webView.loadRequest(urlReq!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var signalItem: LHSignal? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    // MARK: UIWebViewDelegate
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let urlReq = Lighthouse.urlRequest(forSignalId: signalItem?.id)
        if(urlReq?.url?.absoluteString == request.url?.absoluteString){
            return true
        }
        let svc = SFSafariViewController(url: request.url!)
        self.present(svc, animated: true, completion: nil)
        return false
    }


}

