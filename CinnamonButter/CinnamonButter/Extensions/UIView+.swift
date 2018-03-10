//
//  UIView+.swift
//  CinnamonButter
//
//  Created by OTAKE Takayoshi on 2018/03/10.
//

import UIKit

public extension UIView {
    class func CBLoadFromNib<T: UIView>(owner: Any? = nil) -> T {
        // You must name *.xib file the same name as class.
        return Bundle.init(for: T.self).loadNibNamed("\(T.self)", owner: owner, options: nil)?.first as! T
    }
}
