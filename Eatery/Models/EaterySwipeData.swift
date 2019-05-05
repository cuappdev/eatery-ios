//
//  EaterySwipeData.swift
//  Eatery
//
//  Created by Ethan Fine on 5/5/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import Foundation

class EaterySwipeData {
    
    private var swipeDataByHours = [Int : [SwipeDataPoint]]()
  
    init(swipeDataPoints: [SwipeDataPoint]) {
        mapSwipeDataPointToHours(swipeDataPoints: swipeDataPoints)
    }
    
    private func mapSwipeDataPointToHours(swipeDataPoints: [SwipeDataPoint]) {
        for swipeDataPoint in swipeDataPoints {
            if swipeDataForHour(hour: swipeDataPoint.militaryHour) == nil {
                swipeDataByHours[swipeDataPoint.militaryHour] = [swipeDataPoint]
            } else {
                swipeDataByHours[swipeDataPoint.militaryHour]!.append(swipeDataPoint)
            }
        }
    }
    
    func swipeDataForHour(hour: Int) -> [SwipeDataPoint]? {
        return swipeDataByHours[hour]
    }
    
    func waitTimeFor(hour: Int, minute: Int) -> (waitTimeLow: Int, waitTimeHigh: Int)? {
        let swipeDataPointsForHour = swipeDataForHour(hour: hour)
        guard swipeDataPointsForHour != nil else { return nil }
        
        for swipeDataPoint in swipeDataPointsForHour! {
            if swipeDataPoint.minuteRange.contains(minute) {
                return (waitTimeLow: swipeDataPoint.waitTimeLow, swipeDataPoint.waitTimeHigh)
            }
        }
        
        return nil
    }
    
    func averageSwipeDensityForHour(militaryHour: Int) -> Double {
        let swipeDataPointsForHour = swipeDataForHour(hour: militaryHour)
        guard swipeDataPointsForHour != nil else { return 0 }
        
        var averageSwipeDensity: Double = 0
        for swipeDataPoint in swipeDataPointsForHour! {
            averageSwipeDensity += swipeDataPoint.swipeDensity
        }
        
        return averageSwipeDensity / Double(swipeDataPointsForHour!.count)
    }
    
}
