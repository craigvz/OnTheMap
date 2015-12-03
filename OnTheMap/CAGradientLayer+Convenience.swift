//
//  CAGradientLayer+Convenience.swift
//  OnTheMap
//
//  Created by Craig Vanderzwaag on 12/2/15.
//  Copyright © 2015 blueHula Studios. All rights reserved.
//

import UIKit

extension CAGradientLayer {
    
    func turquoiseColor() -> CAGradientLayer {
        
        let topColor = UIColor(red: (15/255.0), green: (118/255.0), blue: (128/255.0), alpha: 1)
        let bottomColor = UIColor(red: (84/255.0), green: (187/255.0), blue: (187/255.0), alpha: 1)
        
        let gradientBasicColors = [topColor.CGColor, bottomColor.CGColor]
        let gradientLocations = [0.0, 1.0]
        let gradientLayer = CAGradientLayer ()
        
        gradientLayer.colors = gradientBasicColors
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
    }

}
