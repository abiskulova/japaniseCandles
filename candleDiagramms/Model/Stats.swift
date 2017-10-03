//
//  Stats.swift
//  candleDiagramms
//
//  Created by Alexandra Gara on 9/29/17.
//  Copyright © 2017 Alexandra Gara. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    public static let StatsCandleDidAdd = NSNotification.Name("StatsCandleDidAdd")
}

class Stats {
    static let instance = Stats()
    
    var minBidEver : Double = 4250
    var maxBidEver : Double = 4300
    
    var newConvertions = [ConvertionData]()
    var candles = [Candle]()
    
    var timer : Timer? // to move convertions to candle each minute
    
    private init() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { timer in
            let convertions = self.newConvertions
            
            if convertions.count == 0{
                // add stub data for background fetch mode or if no data available for fire time
                let stub = ConvertionData(currencies: "", bid: (self.maxBidEver - self.minBidEver) / 2, bf: 1, ask: 0, af: 0, spr: 0)
                let candle = Candle(time: timer.fireDate, convertions: [stub])
                self.candles.append(candle)
                let info = ["candle" : candle, "idx" : self.candles.count - 1] as [String : Any]

                NotificationCenter.default.post(name: .StatsCandleDidAdd, object: nil, userInfo:info)
                Swift.print("CANDLE stub added at \(candle.time)")

                return
            }
            
            let candle = Candle(time: timer.fireDate, convertions: convertions)
            if (self.candles.isEmpty) {
                self.minBidEver = candle.minBid - 10
                self.maxBidEver = candle.maxBid + 10
            }
            
            if candle.minBid < self.minBidEver {
                self.minBidEver = candle.minBid - 10
            }

            if candle.maxBid > self.maxBidEver {
                self.maxBidEver = candle.maxBid + 10
            }
            self.candles.append(candle)
            
            // post notif to draw new candle on chart
            let info = ["candle" : candle, "idx" : self.candles.count - 1] as [String : Any]
            NotificationCenter.default.post(name: .StatsCandleDidAdd, object: nil, userInfo:info)
            Swift.print("CANDLE added at \(candle.time)")
            self.newConvertions = []
        })
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}
