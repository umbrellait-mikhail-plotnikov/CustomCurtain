//
//  BottomCurtainViewProtocol.swift
//  CurtainTest
//
//  Created by Mikhail Plotnikov on 01.04.2021.
//

import Foundation
import UIKit

protocol BottomCurtainViewProtocol: class {
    func updateHeightContentTableView()
    func semiOpenCurtain(_ duration: TimeInterval)
    func openCurtain(_ duration: TimeInterval)
    func closeCurtain(_ duration: TimeInterval)
    func getOrigin() -> CGPoint
    func setOrigin(point: CGPoint)
    var blurEffectView: UIVisualEffectView {get}
    var handleSize: NSLayoutConstraint! {get}
}

extension BottomCurtainViewProtocol {
    func closeCurtain(_ duration: TimeInterval = 0.3) {
        closeCurtain(duration)
    }
    
    func openCurtain(_ duration: TimeInterval = 0.1) {
        openCurtain(duration)
    }
    
    func semiOpenCurtain(_ duration: TimeInterval = 0.1) {
        semiOpenCurtain(duration)
    }
}
