//
//  ViewController.swift
//  candleDiagramms
//
//  Created by Alexandra Gara on 9/29/17.
//  Copyright © 2017 Alexandra Gara. All rights reserved.
//

import UIKit
import SwiftWebSocket

class ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var candlestickChart: CandlestickChartView!
    var socket : WebSocket?

    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = NotificationCenter.default
        center.addObserver(forName: NSNotification.Name.UIDeviceOrientationDidChange, object: nil, queue: nil, using: {
            [unowned self] (notification)  in
            DispatchQueue.main.async {
                self.candlestickChart.setNeedsDisplay()
            }
        })
        
        center.addObserver(forName: .StatsCandleDidAdd, object: nil, queue: OperationQueue.main) {
            [unowned self] (notification)  in
            let userInfo = notification.userInfo!
            // run update chart in main
            DispatchQueue.main.async {
                if let candle = userInfo["candle"] as? Candle,
                    let idx = userInfo["idx"] as? Int
                {
                    let rect = self.candlestickChart.rectForCandle(candle, idx: idx)
                    if rect.maxX > self.candlestickChart.frame.width {
                        self.scrollView.contentSize.width = rect.maxX + UIScreen.main.bounds.width
                        self.candlestickChart.frame.size.width = self.scrollView.contentSize.width
                    }
                    self.candlestickChart.setNeedsDisplay()
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        socket?.close()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //connect
        if socket == nil {
            socket = WebSocket("wss://quotes.exness.com:18400/")
        }
        
        socket?.event.open = {
            print("opened")
            self.socket?.send("SUBSCRIBE: BTCUSD")
        }
        
        socket?.event.close = { code, reason, clean in
            print("close")
            self.socket?.open() // reopen the socket to the previous url
        }
        
        socket?.event.error = { error in
            print("error \(error)")
        }
        
        socket?.event.message = { message in
            if let text = message as? String {
                print("recv: \(text)")
                
                // parse received data
                guard let data = text.data(using: .utf16),
                    let jsonData = try? JSONSerialization.jsonObject(with: data),
                    let jsonDict = jsonData as? [String: Any] else {
                        return
                }
                
                var ticks : [[String: Any]]?
                if let subscribedList = jsonDict["subscribed_list"] as? [String: Any] {
                    ticks = subscribedList["ticks"] as? [[String: Any]]
                } else {
                    ticks = jsonDict["ticks"] as? [[String: Any]]
                }
                
                //parse data from tick and save it to Stats
                if ticks != nil {
                    for tick in ticks! {
                        if let currencies = tick["s"] as? String, let bid = tick["b"] as? String,
                        let bf = tick["bf"] as? Int, let ask = tick["a"] as? String,
                        let af = tick["af"] as? Int, let spr = tick["spr"] as? String {
                            let data = ConvertionData(currencies: currencies, bid: Double(bid)!, bf: bf, ask: Double(ask)!, af: af, spr: Double(spr)!)
                            Stats.instance.newConvertions.append(data)
                        }
                    }
                }
            }
        }
        
        if socket?.readyState != .open {
            socket?.open()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        if socket?.readyState != .closed {
            socket?.send("UNSUBSCRIBE: BTCUSD")
            socket?.close()
            socket = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
