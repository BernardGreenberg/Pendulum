//
//  ViewController.swift
//  Pendulum
//
//  Created by Bernard Greenberg on 12/10/22.
//

import Cocoa

/* This is the view controller for the "big view" that contains the two subviews, the
 unnamed one with the sliders, radio buttons, and description sheetlet, and the
 PendulumGraphicsView on bottom.  This view is used as the target view for all the
 aforementioned controls, fielding interaction with them, as well as initializing them
 (see SliderClasses.swift).
 
 Note that this doesn't get fully initialized until those two subviews have been initialized.
 
 */


class ViewController: NSViewController {
    
    @IBOutlet var ControlView : NSView!
    @IBOutlet var PendGraphicsView : PendulumGraphicsView! // the actual P.G.V.

    /* The labels in the upper view showing the values indicated by the sliders. */
    @IBOutlet var LengthLabel: NSTextField!
    @IBOutlet var AngleLabel: NSTextField!
    @IBOutlet var IntervalLabel: NSTextField!
    @IBOutlet var MetersLabel: NSTextField!
    
    /* IBOutlets are upper case, corresponding IBActions camel-case */
    @IBOutlet var LengthSlider: LogSlider!
    @IBOutlet var AngleSlider: LinearSlider!
    @IBOutlet var IntervalSlider: LogSlider!

    override func viewDidLoad() {

        super.viewDidLoad()

        /* Both subviews are guaranteed to be fully initialized when this runs. */

        let capture = PendGraphicsView.getInitialParms() /* get initial parms */

        /* Make a map from names as they appear in the controls to instantiated modes
           The "funny prefix" is because we have no other way of identifying the
           relevant controls among possible other buttons.  User props look good,
           but were too difficult to make work in the Cocoa (not SwiftUI) environment.
         */

        var modelMap : [String : PendulumModel] = [:]
        for clazz in AllModelClasses() {
            let model = type(of: clazz.init()).init()
            modelMap["Pendmode-" + model.keyName()] = model
        }

        /* Find all buttons in ControlView that have identifiers appearing in that map */
        for subview in ControlView.subviews {
            guard let button = subview as? NSButton else {continue} //buttons only, please
            guard let cell = button.cell else {continue}
            guard let identifier : NSUserInterfaceItemIdentifier = cell.identifier else {continue} // with identifiers
            guard let model = modelMap[identifier.rawValue] else {continue} // and in the map

            /* Install the instantiated model as its representedObject property*/
            cell.representedObject = model

            /* If this is the wanted initial model, install it and turn the button on. */
            if model.keyName() == capture.model {
                PendGraphicsView.setModel(newModel: model)
                cell.state = .on
            }
        }
        
        /* Now that correct model is installed, set up the other parameters into sliders
           (will call back into Graphics to alter model's parameters) */
        AngleSlider.setLinear(val: capture.angle, top: 178, bottom: 2)
        LengthSlider.setLog(val: capture.length, top: 256, bottom: 0.25)
        IntervalSlider.setLog(val: capture.dt, top: 0.5, bottom: 0.001)
    }

   // override var representedObject: Any? {didSet {...     removed

    /* All the radio buttons have this as their handler. Pretty simple now that
       all the connections have been made! */

    @IBAction func radioClick(_ sender: Any) {
        let button = sender as! NSButton
        let model = button.cell?.representedObject as! PendulumModel
        PendGraphicsView.setModel(newModel: model)
    }
    
    /* Handle motion or initialization of the sliders. See SliderClasses.swift. */
    @IBAction func lengthSlider(_ sender: Any) {
        let feet = LengthSlider.getVal()
        if (feet >= 2.0) {
            LengthLabel.stringValue = String(format: "%.2f ft", feet)
        } else {
            LengthLabel.stringValue = String(format: "%.2f in", feet*12)
        }
        let meters = feet*0.3048
        if (meters >= 1.0) {
            MetersLabel.stringValue = String(format: "%.2f m", meters)
        } else {
            MetersLabel.stringValue = String(format: "%.1f cm", meters*100)
        }
        PendGraphicsView.setLength(length: feet)
    }
    
    @IBAction func angleSlider(_ sender: Any) {
        let val = Int(0.5 + AngleSlider.getVal())
        AngleLabel.stringValue = String(val) + "°"
        PendGraphicsView.setMaxAngle(angle: val)
    }
    
    @IBAction func intervalSlider(_ sender: Any) {
        let val = IntervalSlider.getVal()
        IntervalLabel.stringValue = String(format: "%.3f sec", val)
        PendGraphicsView.setInterval(dt: val)
    }
}



