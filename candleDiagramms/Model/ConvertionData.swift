//
//  ConvertionData.swift
//  candleDiagramms
//
//  Created by Alexandra Gara on 10/3/17.
//  Copyright © 2017 Alexandra Gara. All rights reserved.
//

import Foundation

class ConvertionData {
    let currencies : String
    let bid : Double
    let bf : Int
    let ask : Double
    let af : Int
    let spr : Double
    
    init(currencies : String, bid : Double, bf : Int, ask : Double, af : Int, spr : Double) {
        self.currencies = currencies
        self.bid = bid
        self.bf = bf
        self.ask = ask
        self.af = af
        self.spr = spr
    }
}
