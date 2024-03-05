
import Foundation
import UIKit
class LRDividingRulerCell: UICollectionViewCell {
    var config: LRDividingRulerConfig? {
        didSet {
            guard let config = config else { return }
            self.lineView.backgroundColor = config.isLargeLine ? config.largeLineColor : config.smallLineColor
            self.layoutIfNeeded()
        }
    }
    func updateCell(with showText: String?, font: UIFont, color: UIColor, textLargeLineSpace: CGFloat, isSelected: Bool) {
        self.showText = showText ?? ""
        self.scaleTextFont = font
        self.scaleTextColor = color
        self.textLargeLineSpace = textLargeLineSpace
        
        let size = (self.showText as NSString).size(withAttributes: [.font: font])
        self.titlesLabel.text = self.showText
        self.titlesLabel.isHidden = self.showText.isEmpty
        
        if isSelected {
            self.titlesLabel.textColor = .white
        } else {
            self.titlesLabel.textColor = self.scaleTextColor
        }
        self.titlesLabel.frame = CGRect(x: (self.frame.width - size.width - 2) / 2.0, y: self.lineView.frame.minY - textLargeLineSpace - size.height, width: size.width + 2, height: size.height)
    }
    func updateCellInPoint(with color: UIColor, width: CGFloat, space: CGFloat, isShow: Bool) {
        self.inPointView.frame = CGRect(x: (self.frame.width - width) / 2.0, y: self.lineView.frame.minY - width - space, width: width, height: width)
        self.inPointView.isHidden = !isShow
        self.inPointView.backgroundColor = color
        self.inPointView.layer.cornerRadius = width / 2.0
        self.inPointView.clipsToBounds = true
    }
    
    
    private lazy var lineView: UIView = UIView()
    private lazy var titlesLabel: UILabel = UILabel()
    private var scaleTextColor: UIColor = .clear
    private var scaleTextFont: UIFont = .systemFont(ofSize: 12)
    private var textLargeLineSpace: CGFloat = 3
    private var showText: String = ""
    private lazy var inPointView: UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupUI() {
        self.contentView.addSubview(self.lineView)
        self.contentView.addSubview(self.titlesLabel)
        self.contentView.addSubview(self.inPointView)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let config = config else { return }
        let lineWidth = config.lineWidth
        let lineHeight = config.isLargeLine ? config.largeLineHeight : config.smallLineHeight
        var bottomOffset: CGFloat = config.baseLineOffset
        switch config.alignment {
        case .top:
            bottomOffset = config.isLargeLine ? bottomOffset : bottomOffset + (config.largeLineHeight - config.smallLineHeight)
        case .center:
            bottomOffset = config.isLargeLine ? bottomOffset : bottomOffset + (config.largeLineHeight - config.smallLineHeight) / 2.0
        case .bottom:
            bottomOffset = config.baseLineOffset
        }
        self.lineView.frame = CGRect(x: (self.frame.width - lineWidth) / 2.0, y: self.frame.height - bottomOffset - lineHeight, width: lineWidth, height: lineHeight)
    }
    
}
