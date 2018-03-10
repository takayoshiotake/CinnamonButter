//
//  CBDialogController.swift
//  CinnamonButter
//
//  Created by OTAKE Takayoshi on 2018/03/10.
//

import UIKit

public protocol CBDialogControllerDelegate: NSObjectProtocol {
    func dialogController(_ dialog: CBDialogController, didAction action: CBDialogControllerAction)
}

public enum CBDialogControllerAction {
    case affirm
    case negate
    case cancel
}

/// - SeeAlso: extension UIViewController.CBPresentOrReplace(dialogControllerToPresent:animated:completion:)
open class CBDialogController: UIViewController, UIGestureRecognizerDelegate {
    public var dialogTitle: String?
    public var contentView: UIView
    public var affirmativeTitle: String
    public var negativeTitle: String?
    public var isCancellable: Bool
    public var priority: Int
    
    public weak var delegate: CBDialogControllerDelegate?
    public var userInfo: Any?

    @IBOutlet public weak var dialogView: UIView!
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var affirmativeButton: UIButton!
    @IBOutlet public weak var negativeButton: UIButton!
    
    public init(title: String?, contentView: UIView, affirmativeTitle: String, negativeTitle: String?, cancellable: Bool, priority: Int) {
        dialogTitle = title
        self.contentView = contentView
        self.affirmativeTitle = affirmativeTitle
        self.negativeTitle = negativeTitle
        self.isCancellable = cancellable
        self.priority = priority
        super.init(nibName: "CBDialogController", bundle: Bundle.init(for: CBDialogController.self))
        
        // Setup
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reload(from dialog: CBDialogController) {
        precondition(isViewLoaded)
        dialogTitle = dialog.dialogTitle
        contentView.removeFromSuperview()
        contentView = dialog.contentView
        affirmativeTitle = dialog.affirmativeTitle
        negativeTitle = dialog.negativeTitle
        isCancellable = dialog.isCancellable
        priority = dialog.priority
        
        delegate = dialog.delegate
        userInfo = dialog.userInfo
        
        reload()
    }
    
    private func reload() {
        // Setup view
        titleLabel.text = dialogTitle
        titleLabel.isHidden = titleLabel.text == nil
        affirmativeButton.setTitle(affirmativeTitle, for: .normal)
        negativeButton.setTitle(negativeTitle, for: .normal)
        negativeButton.isHidden = negativeTitle == nil
        // HACK:
        (titleLabel.superview as! UIStackView).addArrangedSubview(contentView)
    }
    
    // MARK: -
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        let recognizer = UITapGestureRecognizer.init()
        recognizer.delegate = self
        view.addGestureRecognizer(recognizer)
        
        reload()
    }
    
    // MARK: -
    
    @IBAction func didTapAffirmativeButton(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.dialogController(self, didAction: .affirm)
        }
        else {
            // Warning
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapNegativeButton(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.dialogController(self, didAction: .negate)
        }
        else {
            // Warning
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard isCancellable else {
            return false
        }
        if !dialogView.bounds.contains(touch.location(in: dialogView)) {
            if let delegate = delegate {
                delegate.dialogController(self, didAction: .cancel)
            }
            else {
                // Warning
                dismiss(animated: true, completion: nil)
            }
        }
        return false
    }

}

// MARK: - Extensions

public extension UIViewController {
    func CBPresentOrReplace(_ dialogControllerToPresent: CBDialogController, animated: Bool, completion: (() ->Void)?) {
        if presentedViewController == nil {
            present(dialogControllerToPresent, animated: animated, completion: completion)
        }
        else if let presentedDialog = presentedViewController as? CBDialogController {
            if presentedDialog.priority > dialogControllerToPresent.priority {
                // Warning, already presented a highly priority dialog
                present(dialogControllerToPresent, animated: animated, completion: completion)
            }
            else {
                // Replace the dialog to keep dim
                presentedDialog.reload(from: dialogControllerToPresent)
            }
        }
        else {
            // Warning, already presented a UIViewController
            present(dialogControllerToPresent, animated: animated, completion: completion)
        }
    }
}
