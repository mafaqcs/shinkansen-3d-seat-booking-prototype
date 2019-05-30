//
//  AnimationStyle.swift
//  Shinkansen Tickets Booking Prototype
//
//  Created by Virakri Jinangkul on 5/29/19.
//  Copyright © 2019 Virakri Jinangkul. All rights reserved.
//

import UIKit
import Kumi

extension CABasicAnimationStyle {
    static let layerAnimationStyle = CABasicAnimationStyle(duration: 0.2,
                                                           delay: 0,
                                                           timingFunction: CAMediaTimingFunction(controlPoints: 0.2, 0, 0, 1),
                                                           isRemovedOnCompletion: false)
}