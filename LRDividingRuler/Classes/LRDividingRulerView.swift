import UIKit
import Foundation
import AudioToolbox
import UIKit
@objcMembers
open class LRDividingRulerView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public var isScrollEnable: Bool = true
    public var isShowBothEndsOfGradient: Bool = false
    public var isShowCurrentValue: Bool = true
    public var isShowScaleText: Bool = false
    public var isShowInPoint: Bool = false
    public var isShowIndicator: Bool = true
    public var isCustomScalesValue: Bool = false
    public var isShouldAdsorption: Bool = true
    public var isShouldHighlightText: Bool = true
    public var isShowBaseLine: Bool = false
    public var isShowAreaText: Bool = true
    
    public var lineSpace: CGFloat = 3
    public var lineWidth: CGFloat = 1
    public var largeLineHeight: CGFloat = 20
    public var smallLineHeight: CGFloat = 12
    public var largeLineColor: UIColor = .darkGray
    public var smallLineColor: UIColor = .lightGray
    public var scalesCountBetweenLargeLine: Int = 5
    public var scalesCountBetweenScaleText: Int = 5
    public var currentRulerAlignment: LRRulerAlignmentType = .center
    
    public var scaleTextColor: UIColor = .white
    public var scaleTextFont: UIFont = .systemFont(ofSize: 12)
    public var scaleTextFormatHandler: ((_ currentValue: CGFloat, _ scaleIndex: Int)->String)?
    public var scaleTextLargeLineSpace: CGFloat = 5
    
    public var maxValue: CGFloat = 10000000
    public var minValue: CGFloat = 0
    public var unitValue: CGFloat = 1
    public var defaultValue: CGFloat = 1000
    public var currentTextColor: UIColor = .white
    public var currentTextFont: UIFont = UIFont.systemFont(ofSize: 12)
    
    public var areaTextColor: UIColor = .white
    public var areaTextFont: UIFont = UIFont.systemFont(ofSize: 12)
    public var minAreaText: String = ""
    public var maxAreaText: String = ""
    
    public var indicatorViewColor: UIColor = .blue
    public var indicatorWidth: CGFloat = 1
    public var indicatorHeight: CGFloat = 30
    
    public var inPointColor: UIColor = .lightGray
    public var inPointSize: CGFloat = 5
    public var inPointLargeLineSpace: CGFloat = 3
    public var inPointCurrentValue: CGFloat = 0
    public var inPointCurrentScale: CGFloat = 0
    
    public var gradientLayerWidth: CGFloat = 20
    
    public var baseLineColor: UIColor = .white
    public var baseLineHeight: CGFloat = 1
    public var baseLineOffset: CGFloat = 10
    
    public var dividingRulerDidEndScrollingHandler: ((_ value: CGFloat)->String?)?
    public var dividingRulerDidScrollHandler: ((_ value: CGFloat, _ rulerContentOffset: CGPoint)->String?)?
    
    public var customScalesCount: Int = 5
    public var defaultScale: CGFloat = 0
    public var customScaleTextFormatHandler: ((_ currentCalibrationIndex: Int)->String?)?
    public var dividingRulerCustomScaleDidEndScrollingHandler: ((_ index: CGFloat)->String?)?
    public var dividingRulerCustomScaleDidScrollHandler: ((_ index: CGFloat)->String?)?
    
    public func updateRuler() {
        self.setupCollectionView()
        self.setupIndicatorView()
        self.setupCurrentValueLabel()
        self.setupAreaValueLabel()
        self.setupBottomLineView()
        self.setupBothEndsOfGradientLayer()
        self.setupDataSource()
        
        self.setNeedsLayout()
    }
    
    public func updateRuler(by value: CGFloat) {
        if self.isCustomScalesValue {
            self.selectedIndex = Int(value)
        } else {
            self.selectedIndex = Int((value - self.minValue) / self.unitValue)
        }

        let defaultOffset: CGFloat = CGFloat(self.selectedIndex) * (self.lineWidth + self.lineSpace) - self.collectionView.contentInset.left
        self.updateScrollerView(contentOffset: CGPoint(x: defaultOffset, y: 0))
    }
    
    public func updateScrollerView(contentOffset pointOffset: CGPoint) {
        self.collectionView.contentOffset = pointOffset
    }
    
    private lazy var collectionView: UICollectionView = {
        let l = UICollectionViewFlowLayout()
        l.scrollDirection = .horizontal
        let c = UICollectionView(frame: self.bounds, collectionViewLayout: l)
        c.delegate = self
        c.dataSource = self
        c.showsHorizontalScrollIndicator = false
        c.showsVerticalScrollIndicator = false
        c.backgroundColor = .clear
        c.register(LRDividingRulerCell.self, forCellWithReuseIdentifier: "LRDividingRulerCell")
        self.addSubview(c)
        return c
    }()
    private lazy var indicatorView: UIView = {
        let v = UIView()
        self.addSubview(v)
        return v
    }()
    private lazy var baseLineView: UIView = {
        let v = UIView()
        self.collectionView.addSubview(v)
        return v
    }()
    private lazy var leftGradientLayer: CAGradientLayer = {
        let g = CAGradientLayer()
        g.startPoint = .zero
        g.endPoint = CGPoint(x: 1, y: 0)
        g.colors = [UIColor.lightGray.withAlphaComponent(0.9).cgColor, UIColor.lightGray.withAlphaComponent(0).cgColor]
        self.layer.addSublayer(g)
        return g
    }()
    private lazy var rightGradientLayer: CAGradientLayer = {
        let g = CAGradientLayer()
        g.startPoint = CGPoint(x: 1, y: 0)
        g.endPoint = .zero
        g.colors = [UIColor.lightGray.withAlphaComponent(0.9).cgColor, UIColor.lightGray.withAlphaComponent(0).cgColor]
        self.layer.addSublayer(g)
        return g
    }()
    private lazy var dataArray: [LRDividingRulerConfig] = []
    private lazy var currentValueLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 12)
        l.textColor = .white
        self.addSubview(l)
        return l
    }()
    private lazy var leftAreaLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.font = .systemFont(ofSize: 12)
        l.textColor = .white
        self.addSubview(l)
        return l
    }()
    private lazy var rightAreaLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .right
        l.font = .systemFont(ofSize: 12)
        l.textColor = .white
        self.addSubview(l)
        return l
    }()
    private var selectedIndex: Int = 0
    private var inPointIndex: Int = 0
    private var totalScale: Int = 0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setConfigurations()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setConfigurations()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.setConfigurations()
    }
    private func setConfigurations() {
        
    }
    
    private func setupCollectionView() {
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: (self.frame.width - self.lineWidth) / 2.0, bottom: 0, right: (self.frame.width - self.lineWidth) / 2.0)
        self.collectionView.bounces = false
    }
    
    private func setupIndicatorView() {
        self.indicatorView.backgroundColor = self.indicatorViewColor
        self.indicatorView.isHidden = !self.isShowIndicator
    }
    
    private func setupCurrentValueLabel() {
        self.currentValueLabel.textAlignment = .center
        self.currentValueLabel.isHidden = !self.isShowCurrentValue
        self.currentValueLabel.textColor = self.currentTextColor
        self.currentValueLabel.font = self.currentTextFont
    }
    
    private func setupAreaValueLabel() {
        self.leftAreaLabel.isHidden = !self.isShowAreaText
        self.leftAreaLabel.textColor = self.areaTextColor
        self.leftAreaLabel.font = self.areaTextFont
        self.rightAreaLabel.isHidden = !self.isShowAreaText
        self.rightAreaLabel.textColor = self.areaTextColor
        self.rightAreaLabel.font = self.areaTextFont
        
        self.leftAreaLabel.text = self.minAreaText
        self.rightAreaLabel.text = self.maxAreaText
    }
    
    private func setupBottomLineView() {
        self.baseLineView.backgroundColor = self.baseLineColor
        self.baseLineView.isHidden = !self.isShowBaseLine
    }
    
    private func setupBothEndsOfGradientLayer() {
        self.leftGradientLayer.isHidden = !self.isShowBothEndsOfGradient
        self.rightGradientLayer.isHidden = !self.isShowBothEndsOfGradient
    }
    
    private func setupDataSource() {
        if ((self.maxValue <= self.minValue || self.unitValue == 0) && !self.isCustomScalesValue) {
            print("Parameter error or maxValue cannot be greater than or equal to minuValue,each cannot be 0")
        }
        if (self.isShowInPoint && self.isCustomScalesValue && ((self.inPointCurrentScale > CGFloat(self.customScalesCount))||(self.inPointCurrentScale<0))) {
            print("Parameter error inPointCurrentScale cannot be greater than the maximum scale value cannot be less than 0")
        }
        if (self.isShowInPoint && !self.isCustomScalesValue && ((self.inPointCurrentValue > self.maxValue)||(self.inPointCurrentValue<self.minValue))) {
            print("Parameter error inPointCurrentValue cannot be greater than the maximum value or less than the minimum value");
        }
        if (self.isCustomScalesValue && ((self.defaultScale < 0)||(self.defaultScale>CGFloat(self.customScalesCount)))) {
            print("Parameter Error defaultScale cannot be greater than the maximum scale value and cannot be less than 0");
        }
        if (self.scalesCountBetweenScaleText == 0 && self.isShowScaleText) {
            print("Parameter error scalesCountBetweenScaleText cannot to 0");
        }
        if (self.isCustomScalesValue && self.customScalesCount == 10000000) {
            print("Parameter Error Scale Value Non-incremental Please set customScalesCount to determine the number of scales");
        }
        if (!self.isCustomScalesValue && self.maxValue == 10000000) {
            print("Parameter error Scale value increase Please set maxValue, minValue, unitValue to determine the number of scales");
        }
        
        self.dataArray.removeAll()
        for index in 0 ..< self.scalesCountBetweenLargeLine {
            let config = LRDividingRulerConfig()
            config.lineWidth = self.lineWidth
            config.largeLineHeight = self.largeLineHeight
            config.smallLineHeight = self.smallLineHeight
            config.largeLineColor = self.largeLineColor
            config.smallLineColor = self.smallLineColor
            config.alignment = self.currentRulerAlignment
            config.isLargeLine = index == 0
            config.baseLineOffset = self.baseLineOffset
            self.dataArray.append(config)
        }
        
        if self.isCustomScalesValue {
            self.selectedIndex = Int(self.defaultScale)
        } else {
            self.selectedIndex = Int((self.defaultValue - self.minValue) / self.unitValue)
        }
        
        if self.isCustomScalesValue {
            self.totalScale = self.customScalesCount
        } else {
            self.totalScale = Int((self.maxValue - self.minValue) / self.unitValue)
        }
        
        if self.isShowInPoint {
            if self.isCustomScalesValue {
                self.inPointIndex = Int(self.defaultScale)
            } else {
                self.inPointIndex = Int((self.inPointCurrentValue - self.minValue) / self.unitValue)
            }
        }
        
        let defaultOffset: CGFloat = CGFloat(self.selectedIndex) * (self.lineWidth + self.lineSpace) - self.collectionView.contentInset.left
        self.collectionView.setContentOffset(CGPoint(x: defaultOffset, y: 0), animated: false)
        self.collectionView.isScrollEnabled = self.isScrollEnable
        self.collectionView.reloadData()
        
        if self.isCustomScalesValue {
            let _ = self.dividingRulerCustomScaleDidScrollHandler?(self.defaultScale)
            let _ = self.dividingRulerCustomScaleDidEndScrollingHandler?(self.defaultScale)
        } else {
            if let handler = self.dividingRulerDidScrollHandler {
                self.currentValueLabel.text = handler(self.defaultValue, CGPoint(x: defaultOffset, y: 0))
            }
            if let handler = self.dividingRulerDidEndScrollingHandler {
                self.currentValueLabel.text = handler(self.defaultValue)
            }
        }
    }
    
    open override func layoutSubviews() {

        self.indicatorView.frame = CGRect(x: (self.frame.width - self.indicatorWidth) / 2.0, y: self.frame.height - self.baseLineOffset - self.largeLineHeight - 4, width: self.indicatorWidth, height: self.indicatorHeight)
        let textY: CGFloat = self.frame.height - self.baseLineOffset - self.largeLineHeight - 4 - 3 - 20
        self.currentValueLabel.frame = CGRect(x: (self.frame.width - 80) / 2.0, y: textY, width: 80, height: 20)
        self.leftAreaLabel.frame = CGRect(x: 5, y: textY, width: 100, height: 20)
        self.rightAreaLabel.frame = CGRect(x: self.frame.width - 5 - 100, y: textY, width: 100, height: 20)
        
        self.baseLineView.isHidden = !self.isShowBaseLine
        switch self.currentRulerAlignment {
        case .top:
            self.baseLineView.frame = CGRect(x: 0, y: self.frame.height - self.baseLineOffset - self.largeLineHeight - self.baseLineHeight, width: CGFloat(self.totalScale) * (self.lineSpace + self.lineWidth), height: self.baseLineHeight)
        case .center:
            self.baseLineView.frame = CGRect(x: 0, y: self.frame.height - self.baseLineOffset - self.largeLineHeight - self.baseLineHeight, width: CGFloat(self.totalScale) * (self.lineSpace + self.lineWidth), height: self.baseLineHeight)
            self.baseLineView.isHidden = true
        case .bottom:
            self.baseLineView.frame = CGRect(x: 0, y: self.frame.height - self.baseLineOffset - self.baseLineHeight, width: CGFloat(self.totalScale) * (self.lineSpace + self.lineWidth), height: self.baseLineHeight)
        }

        self.leftGradientLayer.frame = CGRect(x: 0, y: 0, width: self.gradientLayerWidth, height: self.frame.height)
        self.rightGradientLayer.frame = CGRect(x: self.frame.width - self.gradientLayerWidth, y: 0, width: self.gradientLayerWidth, height: self.frame.height)
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isCustomScalesValue {
            return self.customScalesCount + 1
        } else {
            return Int(abs((self.maxValue - self.minValue) / self.unitValue) + 1)
        }
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LRDividingRulerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LRDividingRulerCell", for: indexPath) as! LRDividingRulerCell
        let config = self.dataArray[indexPath.item % self.scalesCountBetweenLargeLine]
        cell.config = config
        var text: String?
        if self.isCustomScalesValue {
            if indexPath.item % self.scalesCountBetweenScaleText == 0 {
                if let handler = self.customScaleTextFormatHandler {
                    text = handler(indexPath.item)
                }
            }
        } else {
            if indexPath.item % self.scalesCountBetweenScaleText == 0 {
                if let hander = self.scaleTextFormatHandler {
                    text = hander(self.minValue + self.unitValue * CGFloat(indexPath.item), indexPath.item)
                }
            }
        }
        if !self.isShowScaleText {
            text = nil
        }
        
        let isCurrentTextHighlight: Bool = self.selectedIndex == indexPath.item && self.isShouldHighlightText
        cell.updateCell(with: text, font: self.scaleTextFont, color: self.scaleTextColor, textLargeLineSpace: self.scaleTextLargeLineSpace, isSelected: isCurrentTextHighlight)
        
        let showInPoint = self.inPointIndex == indexPath.item && self.selectedIndex != self.inPointIndex && self.isShowInPoint
        cell.updateCellInPoint(with: self.inPointColor, width: self.inPointSize, space: self.inPointLargeLineSpace, isShow: showInPoint)
        
        return cell
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.lineWidth, height: self.bounds.height)
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.lineSpace
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.updateRulerLocation()
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.updateRulerLocation()
        }
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var maxOffset: CGFloat = 0
        if self.isCustomScalesValue {
            maxOffset = CGFloat(self.customScalesCount) * (self.lineWidth + self.lineSpace) - self.collectionView.contentInset.left
        } else {
            maxOffset = (self.maxValue - self.minValue) / self.unitValue * (self.lineWidth + self.lineSpace) - self.collectionView.contentInset.left
        }
        let minOffset: CGFloat = -self.collectionView.contentInset.left
        guard scrollView.contentOffset.x < maxOffset || scrollView.contentOffset.x > minOffset else { return }
        
        let offset: CGFloat = self.collectionView.contentInset.left + self.collectionView.contentOffset.x
        
        var count: Int = 0
        if self.isShouldAdsorption {
            count = Int((offset / (self.lineWidth + self.lineSpace)) + 0.5)
        } else {
            count = Int(offset / (self.lineWidth + self.lineSpace))
        }
        
        if self.isCustomScalesValue {
            if let handler = self.dividingRulerCustomScaleDidScrollHandler {
                self.currentValueLabel.text = handler(CGFloat(count))
            }
        } else {
            if let handler = self.dividingRulerDidScrollHandler {
                self.currentValueLabel.text = handler(self.minValue + CGFloat(count) * self.unitValue, scrollView.contentOffset)
            }
        }
    }
    private func updateRulerLocation() {
        let offset: CGFloat = self.collectionView.contentInset.left + self.collectionView.contentOffset.x
        
        var count: Int = 0
        if self.isShouldAdsorption {
            count = Int((offset / (self.lineWidth + self.lineSpace)) + 0.5)
        } else {
            count = Int(offset / (self.lineWidth + self.lineSpace))
        }
        
        self.selectedIndex = count
        self.collectionView.reloadData()
        self.collectionView.contentOffset = CGPoint(x: CGFloat(count) * (self.lineWidth + self.lineSpace) - self.collectionView.contentInset.left, y: 0)
        
        if self.isCustomScalesValue {
            if let handler = self.dividingRulerCustomScaleDidScrollHandler {
                self.currentValueLabel.text = handler(CGFloat(count))
            }
        } else {
            if let handler = self.dividingRulerDidEndScrollingHandler {
                self.currentValueLabel.text = handler(self.minValue + CGFloat(count) * self.unitValue)
            }
        }
        
        if self.isShouldAdsorption {
            AudioServicesPlaySystemSound(1519)
        }
    }
}
