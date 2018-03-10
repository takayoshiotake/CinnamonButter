//
//  CBBarrierViewTestViewController.swift
//  CinnamonButterSampler
//
//  Created by OTAKE Takayoshi on 2018/03/11.
//

import UIKit
import CinnamonButter

class CBBarrierViewTestViewController: UIViewController {
    
    @IBAction func didTapBarrierButton(_ sender: UIButton) {
        // TEST: Wait 3 seconds
        UIView.CBBarrier { (endBarrier) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                endBarrier()
            }
        }
    }

}
