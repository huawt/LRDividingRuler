

import Foundation

public enum LRRulerAlignmentType: Int {
    case top, center, bottom
}
@objcMembers
open class LRDividingRulerConfig: NSObject {
    public var lineWidth: CGFloat = 1
    public var largeLineHeight: CGFloat = 20
    public var smallLineHeight: CGFloat = 12
    public var lineSpace: CGFloat = 3
    public var largeLineColor: UIColor = .darkGray
    public var smallLineColor: UIColor = .lightGray
    public var isLargeLine: Bool = false
    public var alignment: LRRulerAlignmentType = .center
    public var baseLineOffset: CGFloat = 10
}
