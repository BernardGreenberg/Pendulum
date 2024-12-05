//
//  Models.swift
//  Pendulum
//
//  Created by Bernard Greenberg on 12/11/22.
//

/* It don't mean a thing if it ain't got that swing.  */

import Foundation

let  g_AT_SURFACE = 32.1740

/* This is the guts of the program, the model mathematics.  A virtual copy
 of the Python code, including the inheritance lattice, but quite a bit cleaned up
 fron its progenitor. */

protocol PendulumModel {
    func ComputeTheta (t : Double, dt: Double) -> Double
    func keyName () -> String
    func setParms(length : Double, maxAng : Double)
    func report() -> String
    init()
}

var ModelsByKeys : [String : PendulumModel] = [:]

class modBasic : PendulumModel{
    var maxAng : Double!
    var length : Double!
    var ω0 : Double!
    func keyName() ->  String {"Basic"}
    required init() {}
    func setParms(length : Double, maxAng : Double) {
        self.length = length
        self.maxAng = maxAng
        ω0 = sqrt(g_AT_SURFACE/length)
    }
    func ComputeTheta(t : Double, dt: Double) -> Double {
        return maxAng * cos(ω0*t)
    }
    func report() -> String {
        return String(format: "Basic SHM\nFake period = %.3f sec", 2*π/ω0)
    }
}

class modHarmonic : modBasic
{
    var m : Double!, k : Double!, bigK : Double!, ω : Double!

    override func keyName() -> String {"Harmonic"}
    override func setParms(length : Double, maxAng : Double) {
        super.setParms(length: length, maxAng: maxAng)
        k = sin(maxAng/2)
        m = k*k
        bigK = EllipticBridge.k(m)
        ω = ω0/(bigK/(π/2))
    }
    override func ComputeTheta(t : Double, dt: Double) -> Double {
        /* Same as Basic, but real ω */
        return maxAng * cos(ω * t)
    }
    override func report() ->String {
        return String(format: "Real-period SHM\n2π√(L/g) = %.3f sec\nReal period %.3f", 2*π/ω0, 2*π/ω)
    }
}

class modElliptic: modHarmonic{
    override func keyName() -> String {"Elliptic"}
    override func ComputeTheta(t : Double, dt: Double) -> Double {
        let sn = EllipticBridge.sn(bigK - ω0 * t, m: m)
        return 2*asin(k*sn)
    }
    override func report() ->String {
        return String(format: "Accurate motion\n2π√(L/g) = %.3f sec\nReal period %.3f",2*π/ω0, 2*π/ω)
    }
}

class modIntegrate: modElliptic {
    var retained_theta : Double!, velocity : Double!
    override func keyName() -> String {"Integration"}
    override func report() ->String {
        return String(format: "Numeric integration\n2π√(L/g) = %.3f sec\nComp. ellip pd %.3f", 2*π/ω0, 2*π/ω)
    }
    override func setParms(length: Double, maxAng:Double) {
        super.setParms(length:length, maxAng:maxAng)
        self.retained_theta = maxAng
        self.velocity = 0.0
    }

    override func ComputeTheta(t: Double, dt: Double) -> Double {
        let acceleration = -pow(self.ω0,2) * sin(self.retained_theta)
        self.velocity += acceleration * dt
        self.retained_theta += self.velocity * dt
        return self.retained_theta
    }
}

/* Too bad we don't have metaclasses like Python */
func AllModelClasses() -> [PendulumModel.Type]  {
    return  [modBasic.self, modHarmonic.self, modElliptic.self, modIntegrate.self]
}
