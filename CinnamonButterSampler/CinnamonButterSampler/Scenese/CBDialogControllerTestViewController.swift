//
//  CBDialogControllerTestViewController.swift
//  CinnamonButterSampler
//
//  Created by OTAKE Takayoshi on 2018/03/10.
//

import UIKit
import CinnamonButter

class CBDialogControllerTestViewController: UIViewController, CBDialogControllerDelegate {

    var helloDialogTimeout: DispatchWorkItem!
    
    @IBAction func didTapShowDialogButton(_ sender: Any) {
        let contentView = UIView.CBLoadFromNib() as GuruguruDialogContentView
        contentView.messageLabel.text = "Hello!"
        let dialog = CBDialogController.init(title: nil, contentView: contentView, affirmativeTitle: "HELLO", negativeTitle: nil, cancellable: true, priority: 0)
        dialog.delegate = self
        dialog.userInfo = "HelloDialog"
        CBPresentOrReplace(dialog, animated: true, completion: nil)
        
        helloDialogTimeout = DispatchWorkItem.init(block: {
            let contentView = UIView.CBLoadFromNib() as MessageDialogContentView
            contentView.messageLabel.text = "Please retry"
            let dialog = CBDialogController.init(title: "Timeout", contentView: contentView, affirmativeTitle: "OK", negativeTitle: nil, cancellable: false, priority: 0)
            dialog.delegate = self
            dialog.userInfo = "TimeoutDialog"
            self.CBPresentOrReplace(dialog, animated: true, completion: nil)
        })
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0, execute: helloDialogTimeout)
    }
    
    // MARK: - CBDialogControllerDelegate
    
    func dialogController(_ dialog: CBDialogController, didAction action: CBDialogControllerAction) {
        switch dialog.userInfo as! String {
        case "HelloDialog":
            helloDialogTimeout.cancel()
            if action == .affirm {
                let contentView = UIView.CBLoadFromNib() as SliderDialogContentView
                contentView.messageLabel.text = "How sleepy do you have?"
                let dialog = CBDialogController.init(title: nil, contentView: contentView, affirmativeTitle: "OK", negativeTitle: nil, cancellable: true, priority: 0)
                dialog.delegate = self
                dialog.userInfo = "SliderDialog"
                CBPresentOrReplace(dialog, animated: true, completion: nil)
            } else {
                dismiss(animated: true, completion: nil)
            }
        case "SliderDialog":
            let contentView = dialog.contentView as! SliderDialogContentView
            print("slider.value=\(contentView.slider.value)")
            if contentView.slider.value > 0.8 {
                let contentView = UIView.CBLoadFromNib() as MessageDialogContentView
                contentView.messageLabel.text = "You'd better go to bed."
                let dialog = CBDialogController.init(title: nil, contentView: contentView, affirmativeTitle: "IGNORE", negativeTitle: nil, cancellable: true, priority: 0)
                dialog.delegate = self
                dialog.userInfo = "WarningDialog"
                CBPresentOrReplace(dialog, animated: true, completion: nil)
            } else {
                dismiss(animated: true, completion: nil)
            }
        case "TimeoutDialog":
            fallthrough
        case "WarningDialog":
            dismiss(animated: true, completion: nil)
        default:
            fatalError()
        }
    }
    
}
