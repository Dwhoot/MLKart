//  Converted to Swift 4 by Swiftify v4.1.6640 - https://objectivec2swift.com/
//
//  PVN64ControllerViewController.swift
//  Provenance
//
//  Created by Joe Mattiello on 11/28/2016.
//  Copyright (c) 2016 James Addyman. All rights reserved.
//

import PVSupport
import AVFoundation

fileprivate extension JSButton {
    var buttonTag: PVN64Button {
        get {
            return PVN64Button(rawValue: tag)!
        }
        set {
            tag = newValue.rawValue
        }
    }
}

// These should override the default protocol but theyu're not.
// I made a test Workspace with the same protocl inheritance with assoicated type
// and the extension overrides in this format overrode the default extension implimentations.
// I give up after many many hours figuringn out why. Just use a descrete subclass for now.

//extension ControllerVC where Self == PVN64ControllerViewController {
//extension ControllerVC where ResponderType : PVN64SystemResponderClient {

class PVN64ControllerViewController: PVControllerViewController<PVN64SystemResponderClient> {
    private var currentButtons: [String?] = []
    private var isON: Bool = false
    private var displayLink: CADisplayLink?
    private var A: Bool = false
    private var R: Bool = false
    private var L: Bool = false
//    private var driver: KartDriver = KartDriver(model: MarioKart64.model)
    
    override func layoutViews() {
        buttonGroup?.subviews.forEach {
            guard let button = $0 as? JSButton else {
                return
            }
            if (button.titleLabel?.text == "A") {
                button.buttonTag = .a
            } else if (button.titleLabel?.text == "B") {
                button.buttonTag = .b
            } else if (button.titleLabel?.text == "C▲") {
                button.buttonTag = .cUp
            } else if (button.titleLabel?.text == "C▼") {
                button.buttonTag = .cDown
            } else if (button.titleLabel?.text == "C◀") {
                button.buttonTag = .cLeft
            } else if (button.titleLabel?.text == "C▶") {
                button.buttonTag = .cRight
            }
        }

        leftShoulderButton?.buttonTag = .l
        rightShoulderButton?.buttonTag = .r
        zTriggerButton?.buttonTag = .z
        startButton?.buttonTag = .start
    }

    override func dPad(_ dPad: JSDPad, didPress direction: JSDPadDirection) {
        emulatorCore.didMoveJoystick(.analogUp, withValue: 0, forPlayer: 0)
        emulatorCore.didMoveJoystick(.analogLeft, withValue: 0, forPlayer: 0)
        emulatorCore.didMoveJoystick(.analogRight, withValue: 0, forPlayer: 0)
        emulatorCore.didMoveJoystick(.analogDown, withValue: 0, forPlayer: 0)
//        var text: String = ""
        switch direction {
            case .upLeft:
                emulatorCore.didMoveJoystick(.analogUp, withValue: 1, forPlayer: 0)
                emulatorCore.didMoveJoystick(.analogLeft, withValue: 1, forPlayer: 0)
//            text = "L"
            case .up:
                emulatorCore.didMoveJoystick(.analogUp, withValue: 1, forPlayer: 0)
            case .upRight:
                emulatorCore.didMoveJoystick(.analogUp, withValue: 1, forPlayer: 0)
                emulatorCore.didMoveJoystick(.analogRight, withValue: 1, forPlayer: 0)
//            text = "R"
            case .left:
                emulatorCore.didMoveJoystick(.analogLeft, withValue: 1, forPlayer: 0)
//            text = "L"
            case .right:
                emulatorCore.didMoveJoystick(.analogRight, withValue: 1, forPlayer: 0)
//            text = "R"
            case .downLeft:
                emulatorCore.didMoveJoystick(.analogDown, withValue: 1, forPlayer: 0)
                emulatorCore.didMoveJoystick(.analogLeft, withValue: 1, forPlayer: 0)
//            text = "L"
            case .down:
                emulatorCore.didMoveJoystick(.analogDown, withValue: 1, forPlayer: 0)
            case .downRight:
                emulatorCore.didMoveJoystick(.analogDown, withValue: 1, forPlayer: 0)
                emulatorCore.didMoveJoystick(.analogRight, withValue: 1, forPlayer: 0)
//            text = "R"
            default:
                break
        }
//        if text == "R" { R = true } else if text == "L" { L = true }
        vibrate()
    }

    override func dPadDidReleaseDirection(_ dPad: JSDPad) {
        emulatorCore.didMoveJoystick(.analogUp, withValue: 0, forPlayer: 0)
        emulatorCore.didMoveJoystick(.analogLeft, withValue: 0, forPlayer: 0)
        emulatorCore.didMoveJoystick(.analogRight, withValue: 0, forPlayer: 0)
        emulatorCore.didMoveJoystick(.analogDown, withValue: 0, forPlayer: 0)
//        R = false
//        L = false
    }

    override func buttonPressed(_ button: JSButton) {
        emulatorCore.didPush(button.buttonTag, forPlayer: 0)
        vibrate()
//        if button.buttonTag == .a {
//            A = true
//        }
    }

    override func buttonReleased(_ button: JSButton) {
        emulatorCore.didRelease(button.buttonTag, forPlayer: 0)
        if button.titleLabel.text == "L" && isON == false {
            self.displayLink = CADisplayLink.init(target: self, selector: #selector(timerTick))
            displayLink?.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
            return
        } else {
            displayLink?.invalidate()
            displayLink = nil
        }
//        A = false
    }

    override func pressStart(forPlayer player: Int) {
        emulatorCore.didPush(.start, forPlayer: player)
        vibrate()
    }

    override func releaseStart(forPlayer player: Int) {
        emulatorCore.didRelease(.start, forPlayer: player)
    }

    @objc func timerTick() {
        ELOG("tick")
//        saveData()
    }

    private func saveData() {
        let windah = UIApplication.shared.keyWindow
        var image: UIImage = UIImage()
        if let view = windah?.subviews.first?.subviews.first?.subviews.first as? GLKView {
            image = view.snapshot
        }
        do {
            var strings: String = ""
            if R && A {
                strings = "R-A"
            } else if L && A {
                strings = "L-A"
            } else if R {
                strings = "R"
            } else if L {
                strings = "L"
            } else if A {
                strings = "A"
            }
            let time = Date().asSQL()
            let tmpURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
            let logURL = tmpURL.appendingPathComponent( strings + time + ".jpg")
            do {
                if let imageData = UIImageJPEGRepresentation(image, 0.5) {
                    try imageData.write(to: logURL)
                }
            } catch { print(error) }
        }
    }
    
    private func getDirection() {
        var driver: KartDriver = KartDriver(model: MarioKart64())
        let windah = UIApplication.shared.keyWindow
        var image: UIImage
        if let view = windah?.subviews.first?.subviews.first?.subviews.first as? GLKView {
            image = view.snapshot
        }
        driver.predict(image: image) { (control) in
            switch control {
            case .accelerate:
                emulatorCore.didPush(.a, forPlayer: 0)
                
            case .accelerateLeft:
                emulatorCore.didPush(.a, forPlayer: 0)
                
            case .accelerateRight:
                emulatorCore.didPush(.a, forPlayer: 0)
                
            }
        }
    }
}
