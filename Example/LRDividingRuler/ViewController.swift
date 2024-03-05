//
//  ViewController.swift
//  LRDividingRuler
//
//  Created by huawt on 03/04/2024.
//  Copyright (c) 2024 huawt. All rights reserved.
//

import UIKit
import LRDividingRuler

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = .black
        
        self.setUpRuler(index: 0)
        self.setUpRuler(index: 1)
        self.setUpRuler(index: 2)
    }
    
    func setUpRuler(index: Int) {
        let ruler: LRDividingRulerView = LRDividingRulerView(frame: CGRect(x: 0, y: CGFloat((index + 2) * 100), width: self.view.frame.width, height: 100))
        ruler.scaleTextFont = UIFont.boldSystemFont(ofSize: 12)
        ruler.scaleTextColor = .red
        ruler.minValue = 0
        ruler.maxValue = 1000000
        ruler.defaultValue = 50000
        ruler.unitValue = 1
        ruler.currentRulerAlignment = LRRulerAlignmentType(rawValue: index) ?? .top
        ruler.isShowCurrentValue = true
        ruler.isShowBaseLine = false
        ruler.currentTextFont = UIFont.boldSystemFont(ofSize: 14)
        ruler.currentTextColor = UIColor.red
        ruler.indicatorWidth = 11
        ruler.indicatorHeight = 11
        ruler.areaTextFont = UIFont.boldSystemFont(ofSize: 12)
        ruler.areaTextColor = .yellow
        ruler.isShowAreaText =  true
        ruler.minAreaText = "0"
        ruler.maxAreaText = "1000000"
        var indicatorViewColor: UIColor = .blue
        if let image = UIImage(named: "indicator") {
            indicatorViewColor = UIColor(patternImage: image)
        }
        ruler.indicatorViewColor = indicatorViewColor
        ruler.dividingRulerDidScrollHandler = { (value, point) in
            return String(format: "%.f", value)
        }
        ruler.dividingRulerDidEndScrollingHandler = { (value) in
            return String(format: "%.f", value)
        }
        ruler.updateRuler()
        self.view.addSubview(ruler)
    }
    
}

