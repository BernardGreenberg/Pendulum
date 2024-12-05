//
//  SliderClasses.swift
//  Pendulum
//
//  Created by Bernard Greenberg on 12/12/22.
//

/*
 This doesn't do very much any more.  Upside-down (smallest at top) sliders have some
 physical resemblance to a longer pendulum, but the blue strip is supposed to be
 "how much you have chosen to have", so "more" has to be at top.
 
 With that done, and the ability to set arbitrary Doubles as limits, making logarithmic
 sliders is extremely straightforward.
 */

import Cocoa

class SliderBase : NSSlider {
    /* Simulate the slider having been moved, at init time, so the values get shown */
    func triggerReport() {
        if self.target != nil && self.action != nil {
            _ = self.target!.perform(self.action!, with: self)
        }
    }
}

class LinearSlider : SliderBase{
    // Just use it raw
    func setLinear(val: Double, top: Double, bottom:Double) {
        self.maxValue = top
        self.minValue = bottom
        self.doubleValue = val
        triggerReport()
    }
    
    func getVal() -> Double {
        return self.doubleValue
    }
}

class LogSlider : SliderBase {
    func setLog(val: Double, top: Double, bottom: Double) {
        self.maxValue = log(top)
        self.minValue = log(bottom)
        self.doubleValue = log(val)
        triggerReport()
    }

    func getVal() -> Double {
        return exp(self.doubleValue)
    }
}
