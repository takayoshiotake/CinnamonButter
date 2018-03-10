//
//  CBBarrierView.swift
//  CinnamonButter
//
//  Created by OTAKE Takayoshi on 2018/03/11.
//

import UIKit

public class CBBarrierView: UIView {
    
    @IBOutlet public weak var barrierView: UIVisualEffectView!
    @IBOutlet public weak var activityIndicatorView: UIActivityIndicatorView!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        barrierView.layer.masksToBounds = true
        barrierView.layer.cornerRadius = 12
    }

}

public extension UIView {
    class func CBBarrier(block: (@escaping () -> Void) -> Void) {
        let barrierView = UIView.CBLoadFromNib() as CBBarrierView
        UIView.CBBarrier(barrierView, block: block)
    }
    
    class func CBBarrier(_ barrierView: UIView, block: (@escaping () -> Void) -> Void) {
        if let window = UIApplication.shared.windows.first {
            barrierView.frame = window.bounds
            barrierView.layoutIfNeeded()
            window.addSubview(barrierView)
        }
        block {
            if Thread.isMainThread {
                barrierView.removeFromSuperview()
            }
            else {
                DispatchQueue.main.async {
                    barrierView.removeFromSuperview()
                }
            }
        }
    }
}

