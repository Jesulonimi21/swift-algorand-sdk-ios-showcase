//
//  AutoLayoutUiButton.swift
//  swift-algorand-sdk-ios-showcase
//
//  Created by Jesulonimi on 3/15/21.
//

import Foundation
import UIKit
class AutoLayoutButton: UIButton {
     override var intrinsicContentSize: CGSize {
         var size = titleLabel!.sizeThatFits(CGSize(width: titleLabel!.preferredMaxLayoutWidth - contentEdgeInsets.left - contentEdgeInsets.right, height: .greatestFiniteMagnitude))
         size.height += contentEdgeInsets.left + contentEdgeInsets.right
         return size
     }
     override func layoutSubviews() {
         titleLabel?.preferredMaxLayoutWidth = frame.size.width
         super.layoutSubviews()
     }
 }
