//
//  BottomCurtain.swift
//  CurtainTest
//
//  Created by Mikhail Plotnikov on 31.03.2021.
//

import UIKit

class BottomCurtainViewController: UIViewController, BottomCurtainViewProtocol {
    
    weak var creatorView: UIView? {
        presenter.creatorView
    }
    private var presenter: BottomCurtainPresenter
    
    var diff: CGFloat = 0
    let bottomCurtainNibName = "BottomCurtainViewController"
    let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.alpha = 0
    
        return blurredEffectView
    }()
    
    @IBOutlet private weak var sizeContentTableViewConstraint: NSLayoutConstraint!
    @IBOutlet public weak var contentTableView: UITableView!
    @IBOutlet weak var handleSize: NSLayoutConstraint!
    @IBOutlet private weak var handleView: UIView!
    @IBOutlet private weak var handleViewBlackStick: UIView!
    @IBOutlet private weak var contentView: UIView!
    
    public weak var delegate: (UIViewController & UITableViewDelegate & UITableViewDataSource)? {
        didSet {
            presenter.creatorView = delegate?.view
            presenter.checkHeight()
            self.view.frame = CGRect(x: 0, y: creatorView!.bounds.height - handleSize.constant, width: creatorView!.bounds.width, height: presenter.maxHeightForOpen)
            blurEffectView.frame = creatorView!.frame
            
            contentTableView.delegate = self
            contentTableView.dataSource = delegate
            
            creatorView!.addSubview(blurEffectView)
            creatorView!.addSubview(self.view)
        }
    }
    
    func getOrigin() -> CGPoint {
        return self.view.frame.origin
    }
    
    func setOrigin(point: CGPoint) {
        
        self.view.frame.origin = point
    }
    
    func semiOpenCurtain(_ duration: TimeInterval = 0.1) {
        presenter.stateCurtain = .block
        UIView.animate(withDuration: duration) { [self] in
            
            self.view.frame.origin.y = presenter.calculateSemiHeight(contentTableView: contentTableView)
            
            presenter.blurringBackground(0.5)
            updateHeightContentTableView()
        } completion: { [self] (finish) in
            if finish {
                presenter.stateCurtain = .semi
            }
        }
        
    }
    
    func openCurtain(_ duration: TimeInterval = 0.1) {
        presenter.stateCurtain = .block
        guard let creatorView = creatorView else { return }
        UIView.animate(withDuration: duration) { [self] in
            self.view.frame.origin.y = creatorView.bounds.height - (presenter.heightCurtain)
            presenter.blurringBackground(1)
            updateHeightContentTableView()
        } completion: { [self] finish in
            if finish {
                presenter.stateCurtain = .open
            }
        }
    }
    
    func closeCurtain(_ duration: TimeInterval = 0.3) {
        presenter.stateCurtain = .block
        guard let creatorView = creatorView else { return }
        UIView.animate(withDuration: duration) { [self] in
            self.view.frame.origin.y = creatorView.bounds.height - self.handleSize.constant
            presenter.blurringBackground(0)
            updateHeightContentTableView()
        } completion: { [self] (finish) in
            if finish {
                presenter.stateCurtain = .close
            }
        }
        
    }
    
    func updateHeightContentTableView() {
        guard let creatorView = creatorView else { return }
        let height = creatorView.frame.height - self.view.frame.origin.y
        sizeContentTableViewConstraint.constant = height > 0 ? height : 0
    }
    
    @objc
     func handlePanRecognizer(recognizer: UIPanGestureRecognizer) {
        presenter.handlePanRecognizer(recognizer: recognizer)
    }
    
    @objc
     func handleTapRecognizer(recognizer: UITapGestureRecognizer) {
        presenter.handleTapRecognizer(recognizer: recognizer)
    }
    
    @objc
     func handleCreatorViewTapRecognizer(recognizer: UITapGestureRecognizer) {
        closeCurtain()
    }
    
    
    init(heightCurtain: CGFloat) {
        
        
        self.presenter = BottomCurtainPresenter()
        super.init(nibName: bottomCurtainNibName, bundle: nil)
        presenter.delegate = self
        presenter.heightCurtain = heightCurtain
    }
    
    private func setupGestureRecognizers() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanRecognizer))
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapRecognizer))
        let creatorViewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleCreatorViewTapRecognizer))
        creatorViewTapRecognizer.delegate = self
        
    
        creatorView?.addGestureRecognizer(creatorViewTapRecognizer)
        handleView.addGestureRecognizer(tapRecognizer)
        handleView.addGestureRecognizer(panRecognizer)
    }
    
    override func viewDidLoad() {
        
        contentTableView.contentInset = UIEdgeInsets(top: handleSize.constant / 2, left: 0, bottom: handleSize.constant / 2, right: 0)
        handleViewBlackStick.layer.cornerRadius = 3
        
        setupGestureRecognizers()
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

extension BottomCurtainViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        presenter.didScroll(scrollView: scrollView, handleSize: handleSize.constant, tableView: contentTableView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        presenter.didTouch(scrollView: scrollView)
        print("touch")
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("end touch")
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
