//
//  PendulumGraphicsView.swift
//  Pendulum
//
//  Created by Bernard Greenberg on 12/10/22.
//

/*
 
 This class embodies all the pendulum graphics, including setting up and handling timers.
 It deals with the correct placement of the pendulum so the whole arc is visible.
 All of the mathematics of the modeling are not here, but in Models.swift.
 This only knows how to draw the pendulum given an angle (θ), including choosing
 a good "size" ("length" in feet, which determines the period, of course, is not
 important here, although, like max angle, it lives here).
 
 */
import Cocoa

let π = Double.pi
let toRadians = π/180
let toDegrees = 180/π

class PendulumGraphicsView: NSView {
    
    /* Fundamental -- these can be adjusted by the sliders */
    var maxang_degrees = 80.0
    var length = 32.2 // feet
    var dt = 0.01


    /* graphics */
    let textHeight = 70.0 // no longer used
    var textFontAttributes : [NSAttributedString.Key : Any] = [:] // no longer used

    let ballr = 10.0
    let topoff = 20.0
    let ballColor =  NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)

    var topPoint : CGPoint?

    /* derived */
    var t = 0.0
    var θ = 0.0
    var r = 0.0
    
    @IBOutlet var ReportLabel : NSTextField!
    var timer : Timer?
    
    let startup_model_name = "Harmonic"
    var currentModel : PendulumModel!
    
    required init?(coder: NSCoder) {
        super.init(coder:coder)

/*        self.textFontAttributes = [ //this isn't needed anu
            .font: NSFont(name: "Helvetica", size: 14.0) as Any
        ]
*/  //not needed any more.

        // Can't run yet -- model not yet chosen or installed by superview.
        // setInterval from init of interval slider will start the timer.
        // setAngle init will do the ViewEndLiveResize to compute the radius.
    }
    
    func setTheTimer() {
        if (self.timer != nil) {
            self.timer?.invalidate()
        }
        self.timer = Timer.scheduledTimer(timeInterval: self.dt, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    func compute_parms() {
        /* Ask the current model to set its 3 parms, and report the conclusion, */
        currentModel.setParms(length:self.length, maxAng:self.maxang_degrees*toRadians)
        Report()
    }

    @objc func update() {
        /* Called when the timer (repeatedly) matures. Get θ from the current model. */
        θ = currentModel.ComputeTheta(t: t, dt: dt)
        t += dt

        setNeedsDisplay(self.frame)
    }

    func Report() {
        /* Note that this not getting called until outer and other frames set up matters. */
        ReportLabel.stringValue = currentModel.report()
    }
    
    func DrawTextReport__Obsolete() {
        /* This is no longer used, wrong way to do it, but it was too difficult a birth...*/
        //https://stackoverflow.com/questions/26201844/swift-drawing-text-with-drawinrectwithattributes
        let height = frame.size.height
        let width = frame.size.width

        // let textColor = NSColor(calibratedRed: 0.147, green: 0.222, blue: 0.162, alpha: 1.0)
        let textRect = NSMakeRect(5, height-textHeight, width, textHeight)
        currentModel.report().draw(in: textRect, withAttributes: textFontAttributes)
    }

    override func draw(_ dirtyRect: NSRect) {
        /* This actually draws the actual stem and ball, when called by the Framework */

        super.draw(dirtyRect)
        
        let x = topPoint!.x + r*sin(θ)
        let y = topPoint!.y - r*cos(θ)
        
        let stem = NSBezierPath() /* cannot reuse this, must recreate afresh */
        stem.move(to: topPoint!)
        stem.line(to: CGPoint(x: x, y: y))
        stem.stroke()
        
        let ballRect = NSMakeRect(x - ballr, y - ballr, 2*ballr, 2*ballr)
        let ball = NSBezierPath(ovalIn:ballRect);
        ballColor.setFill()
        ball.fill()
    }
    

    /* Called by the containing frame in response to clicking the radio buttons
       The calls to compute_parms() sends it out to the current model and the report
       sheetlet.
     */
    func setModel(newModel : PendulumModel) {
        currentModel = newModel
        compute_parms()
        /* Make it try to keep the arc point */
    }
    
    /* These 3 setFoo's are called by the containing frame in response to slider motion */
    func setLength(length : Double) {
        self.length = length
        compute_parms()
    }
    
    func setMaxAngle(angle: Int) {
        self.maxang_degrees = Double(angle)
        compute_parms()
        viewDidEndLiveResize()  // Might need new conception of radius/placement.
    }
    
    func setInterval(dt: Double) {
        self.dt = dt
        setTheTimer()
    }
    
    struct ParmCapture {var angle: Double, length :Double, dt :Double, model: String}
    /* Called by the containing frame to get values to set the sliders with */
    func getInitialParms() -> ParmCapture {
        return ParmCapture(angle: maxang_degrees, length: length, dt: dt, model:startup_model_name)
    }
    
    /* Called either by mouse resize, initialization, or when parms changed.*/
    override func viewDidEndLiveResize() {
        self.topPoint = CGPoint(x: self.frame.size.width/2.0, y: self.frame.size.height-topoff)
        let usable_height = self.frame.size.height - ballr - topoff
        let usable_halfwidth =  self.frame.size.width/2.0 - ballr
        r = min(usable_height, usable_halfwidth)
        /* When ball goes up above the topPoint, we have to move the latter down */
        let factor = (maxang_degrees > 90.0) ? (1.0 + sin((maxang_degrees-90)*toRadians)) : 1.0
        r = r/factor
        
        self.topPoint?.y = usable_height + ballr -  r * (factor - 1.0)
    }
}
