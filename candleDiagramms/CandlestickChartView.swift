//
//  CandlestickChartView.swift
//  candleDiagramms
//
//  Created by Alexandra Gara on 10/3/17.
//  Copyright © 2017 Alexandra Gara. All rights reserved.
//

import UIKit

class CandlestickChartView : UIView {
    let diagrammOffset : CGFloat = 45.0

    let candleWidth : CGFloat = 20.0
    let candleOffset : CGFloat = 5.0
    let timeIntervalLinesWidth : CGFloat = 5.0
    
    func rectForCandle(_ candle : Candle, idx : Int) -> CGRect {
        let originX = diagrammOffset + CGFloat(idx) * (candleWidth + candleOffset)
        let diagrammHeight = bounds.height - diagrammOffset
        let originY = bounds.height - CGFloat((candle.maxBid - Stats.instance.minBidEver) * Double(diagrammHeight) / (Stats.instance.maxBidEver - Stats.instance.minBidEver))
        let candleHeight = CGFloat((candle.maxBid - candle.minBid) * Double(diagrammHeight) / (Stats.instance.maxBidEver - Stats.instance.minBidEver))

        return CGRect(x: originX, y: originY, width: candleWidth, height :candleHeight)
    }
    
    func drawLines(_ rect: CGRect) {
        // draw labels for bids
        var text = "\(Stats.instance.maxBidEver)" as NSString
        text.draw(at: CGPoint(x:0, y:bounds.minY), withAttributes: nil)
        text = "\(Stats.instance.minBidEver)" as NSString
        text.draw(at: CGPoint(x:0, y:bounds.maxY - diagrammOffset), withAttributes: nil)
        
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.move(to: CGPoint(x: diagrammOffset, y: bounds.minY))
        context?.addLine(to: CGPoint(x: diagrammOffset, y: bounds.maxY))
        context?.closePath()
        context?.move(to: CGPoint(x: bounds.minX, y: bounds.maxY - diagrammOffset))
        context?.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY - diagrammOffset))
        context?.closePath()
        context?.drawPath(using: .stroke)
        context?.restoreGState()
    }

    func drawCandles(_ rect: CGRect) {
        let candles = Stats.instance.candles
        for (idx, candle) in candles.enumerated() {
            // to avoid redrawing check if update rect intesects with Candle rect
            let candleRect = rectForCandle(candle, idx: idx)
            if (rect.intersects(candleRect)) {
                let context = UIGraphicsGetCurrentContext()
                context?.saveGState()

                if (candle.closeBid != candle.openBid) { // have candle body
                    let topY = candle.closeBid > candle.openBid ? candle.closeBid : candle.openBid
                    let bottomY = candle.closeBid < candle.openBid ? candle.closeBid : candle.openBid
                    let diagrammHeight = bounds.height - diagrammOffset
                    let originY = bounds.height - CGFloat((topY - Stats.instance.minBidEver) * Double(diagrammHeight) / (Stats.instance.maxBidEver - Stats.instance.minBidEver))
                    let candleHeight = CGFloat((topY - bottomY) * Double(diagrammHeight) / (Stats.instance.maxBidEver - Stats.instance.minBidEver))

                    let bodyRect = CGRect(x: candleRect.minX, y: originY, width: candleRect.width, height: candleHeight)
                    
                    context?.setStrokeColor(UIColor.black.cgColor)
                    context?.setFillColor(UIColor.black.cgColor)
                    context?.addRect(bodyRect)
                    if candle.maxBid > topY {
                        context?.move(to: CGPoint(x: candleRect.midX, y: candleRect.origin.y))
                        context?.addLine(to: CGPoint(x: candleRect.midX, y: bodyRect.origin.y))
                        context?.closePath()
                    }
                    
                    if candle.minBid < bottomY {
                        context?.move(to: CGPoint(x: candleRect.midX, y: bodyRect.maxY))
                        context?.addLine(to: CGPoint(x: candleRect.midX, y: candleRect.maxY))
                        context?.closePath()
                    }
                    context?.drawPath(using: candle.isGrowing ? .stroke : .fillStroke)
                } else if candle.convertions.count == 1 { // draw stub candle while in background
                    context?.setStrokeColor(UIColor.red.cgColor)
                    context?.move(to: CGPoint(x: candleRect.minX, y: candleRect.maxY))
                    context?.addLine(to: CGPoint(x: candleRect.maxX, y: candleRect.maxY))
                    context?.closePath()
                    context?.drawPath(using: candle.isGrowing ? .stroke : .fillStroke)

                }
                else {
                    // draw just shadow
                    context?.setStrokeColor(UIColor.black.cgColor)
                    context?.move(to: CGPoint(x: candleRect.midX, y: candleRect.origin.y))
                    context?.addLine(to: CGPoint(x: candleRect.midX, y: candleRect.maxY))
                    context?.closePath()
                    context?.drawPath(using: candle.isGrowing ? .stroke : .fillStroke)
                }
                context?.restoreGState()
            }
            // draw labels for time of candle
            if (idx % 5) == 0 {
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: candle.time)
                let minutes = calendar.component(.minute, from: candle.time)
                ("\(hour):\(minutes)" as NSString).draw(at: CGPoint(x: diagrammOffset + CGFloat(idx) * (candleWidth + candleOffset), y: bounds.maxY - diagrammOffset), withAttributes: nil)
            }
        }
    }

    override func draw(_ rect: CGRect) {
        drawLines(rect)
        drawCandles(rect)
    }
}
