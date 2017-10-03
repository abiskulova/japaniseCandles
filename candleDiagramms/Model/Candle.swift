//
//  Candle.swift
//  candleDiagramms
//
//  Created by Alexandra Gara on 10/3/17.
//  Copyright © 2017 Alexandra Gara. All rights reserved.
//

import Foundation

class Candle {
    let time: Date
    let convertions : [ConvertionData]
    
    init(time: Date, convertions : [ConvertionData]) {
        self.time = time
        self.convertions = convertions
    }
    var isGrowing : Bool {
        return openBid < closeBid
    }
    
    var minBid : Double {
        return convertions.map{ $0.bid }.min()!
    }
    var maxBid : Double {
        return convertions.map{ $0.bid }.max()!
    }
    var openBid : Double {
        return (convertions.first?.bid)!
    }
    var closeBid : Double {
        return (convertions.last?.bid)!
    }
}
