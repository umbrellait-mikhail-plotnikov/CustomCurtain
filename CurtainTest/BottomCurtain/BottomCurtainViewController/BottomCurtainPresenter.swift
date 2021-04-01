//
//  BottomCurtainPresenter.swift
//  CurtainTest
//
//  Created by Mikhail Plotnikov on 01.04.2021.
//
import UIKit
import Foundation

class BottomCurtainPresenter {
    weak var creatorView: UIView?
    weak var delegate: BottomCurtainViewProtocol!
    
    var stateCurtain: BottomCurtainStateEnum = .close
    var absolutePanPosition: CGFloat = 0
    var maxHeightForOpen: CGFloat!
    var heightCurtain: CGFloat! {
       didSet {
           maxHeightForOpen = heightCurtain + 50
       }
    }
    
    func handlePanRecognizer(recognizer: UIPanGestureRecognizer) {
        guard let creatorView = creatorView else { return }
        let location = recognizer.location(in: creatorView.self)
        let positionY = location.y - delegate.handleSize.constant / 2
        absolutePanPosition = creatorView.frame.height - positionY
       
        delegate.updateHeightContentTableView()
        blurringBackground()
        
        if recognizer.state == .changed {
            
            if absolutePanPosition > maxHeightForOpen {
                delegate.openCurtain()
            } else {
                delegate.setOrigin(point: CGPoint(x: 0, y: positionY))
            }
            
        } else if recognizer.state == .ended {
            
            if absolutePanPosition > maxHeightForOpen || absolutePanPosition > maxHeightForOpen * 0.4 {
                delegate.openCurtain()
            } else {
                delegate.closeCurtain()
            }
        }
    }
    
    func calculateSemiHeight(contentTableView: UITableView) -> CGFloat {
        if let firstCellHeight = contentTableView.cellForRow(at: IndexPath(row: 0, section: 0))?.bounds.height {
            return creatorView!.bounds.height - firstCellHeight - delegate.handleSize.constant
        } else {
            return creatorView!.bounds.height - heightCurtain / 2
        }
    }
    
    func handleTapRecognizer(recognizer: UITapGestureRecognizer) {
        
        if stateCurtain == .open {
            delegate.closeCurtain()
        } else if stateCurtain == .close {
            delegate.semiOpenCurtain(0.2)
        } else if stateCurtain == .semi {
            delegate.openCurtain(0.2)
        } else {
            fatalError()
        }
        
    }
    
    func checkHeight() {
        if creatorView!.frame.height - 50 < heightCurtain {
            print("WARNING! Your view has a hieght of \(creatorView!.frame.height)px, but you init BottomCurtainViewController with a height of \(heightCurtain!)px. Automatic height resizing to \(creatorView!.frame.height - 50)px")
            heightCurtain = creatorView!.frame.height - 50
        }
    }
    
    func blurringBackground(_ alpha: CGFloat? = nil) {
        guard let creatorView = creatorView else { return }
        guard alpha == nil else {
            delegate.blurEffectView.alpha = alpha!
            return
        }
        let absoluteCurtainPosition = creatorView.frame.height - delegate.getOrigin().y
        let percent = 1 - ((heightCurtain - absoluteCurtainPosition) / heightCurtain)
        delegate.blurEffectView.alpha = percent > 1 ? 1 : percent
    }
    
}
