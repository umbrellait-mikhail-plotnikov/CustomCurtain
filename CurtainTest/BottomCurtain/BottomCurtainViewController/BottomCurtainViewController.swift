//
//  BottomCurtain.swift
//  CurtainTest
//
//  Created by Mikhail Plotnikov on 31.03.2021.
//

import UIKit

class BottomCurtainViewController: UIViewController {
    
    private var absolutePanPosition: CGFloat = 0
    private var cellClassArray = [AnyClass]()
    private var cellIdentifierArray = [String]()
    private let bottomCurtainNibName = "BottomCurtainViewController"
    private weak var creatorView: UIView?
    private var stateCurtain: BottomCurtainStateEnum = .close
    private let heightCurtain: CGFloat!
    private let maxHeightForOpen: CGFloat!
    
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.alpha = 0
        
        return blurredEffectView
    }()
    
    @IBOutlet private weak var sizeContentTableViewConstraint: NSLayoutConstraint!
    @IBOutlet public weak var contentTableView: UITableView!
    @IBOutlet private weak var handleSize: NSLayoutConstraint!
    @IBOutlet private weak var handleView: UIView!
    @IBOutlet private weak var handleViewBlackStick: UIView!
    @IBOutlet private weak var contentView: UIView!
    
    public func registerCell(nib: UINib, identifier: String) {
        contentTableView.register(nib, forCellReuseIdentifier: identifier)
    }
    
    public weak var delegate: (UIViewController & UITableViewDelegate & UITableViewDataSource)? {
        didSet {
            creatorView = delegate?.view
            self.view.frame = CGRect(x: 0, y: creatorView!.bounds.height - handleSize.constant, width: creatorView!.bounds.width, height: maxHeightForOpen)
            blurEffectView.frame = creatorView!.frame
            
            contentTableView.delegate = delegate
            contentTableView.dataSource = delegate
            
            creatorView!.addSubview(blurEffectView)
            creatorView!.addSubview(self.view)
        }
    }
    
    private func semiOpenCurtain(_ duration: TimeInterval = 0.1) {
        guard let creatorView = creatorView else { return }
        var height: CGFloat = 0
        UIView.animate(withDuration: duration) { [self] in
            if let firstCellHeight = contentTableView.cellForRow(at: IndexPath(row: 0, section: 0))?.bounds.height {
                height = creatorView.bounds.height - firstCellHeight - handleSize.constant
            } else {
                height = creatorView.bounds.height - self.heightCurtain / 2
            }
            
            self.view.frame.origin.y = height
            blurringBackground(0.5)
            updateHeightContentTableView()
        }
        stateCurtain = .semi
    }
    
    private func openCurtain(_ duration: TimeInterval = 0.1) {
        guard let creatorView = creatorView else { return }
        UIView.animate(withDuration: duration) { [self] in
            self.view.frame.origin.y = creatorView.bounds.height - (self.heightCurtain)
            blurringBackground(1)
            updateHeightContentTableView()
        }
        
        stateCurtain = .open
    }
    
    private func closeCurtain(_ duration: TimeInterval = 0.3) {
        guard let creatorView = creatorView else { return }
        UIView.animate(withDuration: duration) { [self] in
            self.view.frame.origin.y = creatorView.bounds.height - self.handleSize.constant
            self.blurringBackground(0)
            updateHeightContentTableView()
        }
        
        stateCurtain = .close
    }
    
    private func blurringBackground(_ alpha: CGFloat? = nil) {
        guard let creatorView = creatorView else { return }
        guard alpha == nil else {
            blurEffectView.alpha = alpha!
            return
        }
        let absoluteCurtainPosition = creatorView.frame.height - self.view.frame.origin.y
        let percent = 1 - ((heightCurtain - absoluteCurtainPosition) / heightCurtain)
        blurEffectView.alpha = percent > 1 ? 1 : percent
    }
    
    private func updateHeightContentTableView() {
        guard let creatorView = creatorView else { return }
        let height = creatorView.frame.height - self.view.frame.origin.y
        sizeContentTableViewConstraint.constant = height > 0 ? height : 0
    }
    
    @objc
    private func handlePanRecognizer(recognizer: UIPanGestureRecognizer) {
        guard let creatorView = creatorView else { return }
        let location = recognizer.location(in: creatorView.self)
        let positionY = location.y - handleSize.constant / 2
        absolutePanPosition = creatorView.frame.height - positionY
       
        updateHeightContentTableView()
        blurringBackground()
        
        if recognizer.state == .changed {
            
            if absolutePanPosition > maxHeightForOpen{
                openCurtain()
            } else {
                self.view.frame.origin.y = positionY
            }
            
        } else if recognizer.state == .ended {
            
            if absolutePanPosition > maxHeightForOpen || absolutePanPosition > maxHeightForOpen * 0.4 {
                openCurtain()
            } else {
                closeCurtain()
            }
        }
    }
    
    @objc
    private func handleTapRecognizer(recognizer: UITapGestureRecognizer) {
        
        if stateCurtain == .open {
            closeCurtain()
        } else if stateCurtain == .close {
            semiOpenCurtain(0.2)
        } else if stateCurtain == .semi {
            openCurtain(0.2)
        } else {
            fatalError()
        }
        
    }
    
    @objc
    private func handleCreatorViewTapRecognizer(recognizer: UITapGestureRecognizer) {
        closeCurtain()
    }
    
    init(heightCurtain: CGFloat) {
        self.heightCurtain = heightCurtain
        self.maxHeightForOpen = heightCurtain + 50
        super.init(nibName: bottomCurtainNibName, bundle: nil)
    }
    
    override func viewDidLoad() {
        
        contentTableView.contentInset = UIEdgeInsets(top: handleSize.constant / 2, left: 0, bottom: handleSize.constant / 2, right: 0)
        
        handleViewBlackStick.layer.cornerRadius = 3
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanRecognizer))
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapRecognizer))
        let creatorViewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleCreatorViewTapRecognizer))
        
        creatorViewTapRecognizer.delegate = self
        creatorView?.addGestureRecognizer(creatorViewTapRecognizer)
        handleView.addGestureRecognizer(tapRecognizer)
        handleView.addGestureRecognizer(panRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BottomCurtainViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: self.view) {
            return false
        }
        return true
    }
}

extension BottomCurtainViewController: BottomCurtainColorsProtocol {
    
    public func setBackgroundColor(color: UIColor) {
        self.view.backgroundColor = color
    }
    
    public func setHandleBackgroundColor(color: UIColor) {
        self.handleView.backgroundColor = color
    }
    
    public func setContentBackgroundColor(color: UIColor) {
        self.contentView.backgroundColor = color
    }
}
