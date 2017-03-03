/*
    The MIT License (MIT)
    Copyright (c) 2015-present Badoo Trading Limited.
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
*/

import Foundation
import UIKit

public class PageControl: UIView {

    // MARK: - Public

    public struct Dot {
        public struct Style {
            public var radius: Float
            public var fillColor: UIColor
            public var strokeColor: UIColor
            public var strokeWidth: Float

            public init(radius: Float,
                        fillColor: UIColor,
                        strokeColor: UIColor,
                        strokeWidth: Float) {
                self.radius = radius
                self.fillColor = fillColor
                self.strokeColor = strokeColor
                self.strokeWidth = strokeWidth
            }
        }

        public var regularStyle: Style
        public var activeStyle: Style

        public init(regularStyle: Style, activeStyle: Style) {
            self.regularStyle = regularStyle
            self.activeStyle = activeStyle
        }
    }

    public var dots = [Dot]() {
        didSet {
            self.reloadDotViews()
        }
    }

    /// [0..self.dots.count-1] interval, non-integer values will interpolate between sibling dots. Default is 0
    public var activeDotIndex: Float = 0 {
        didSet {
            self.activeDotIndex = self.activeDotIndex.clamped(0, Float(self.dots.count - 1))
            self.updateDotViews()
        }
    }

    public var onActiveDotIndexChanged: ((Float) -> Void)? = nil

    public func setActiveDotIndex(_ index: Float, animated: Bool) {
        if !animated {
            self.activeDotIndex = index
            return
        }

        let oldIndex = self.activeDotIndex
        self.activeDotIndexAnimator?.cancel()
        self.activeDotIndexAnimator = Animator.animate(
            duration: self.configuration.animationDuration,
            work: { lerpValue in
                self.activeDotIndex = oldIndex + (index - oldIndex) * lerpValue
            }
        )
    }

    public struct Configuration {
        public enum LayoutAxis {
            case horizontal
            case vertical
        }

        public var layoutAxis: LayoutAxis
        public var spacing: CGFloat
        public var paddings: UIEdgeInsets
        public var changesActiveDotOnTap: Bool
        public var animationDuration: TimeInterval

        public init(layoutAxis: LayoutAxis,
                    spacing: CGFloat,
                    paddings: UIEdgeInsets,
                    changesActiveDotOnTap: Bool,
                    animationDuration: TimeInterval) {
            self.layoutAxis = layoutAxis
            self.spacing = spacing
            self.paddings = paddings
            self.changesActiveDotOnTap = changesActiveDotOnTap
            self.animationDuration = animationDuration
        }
    }

    /// Default is .default
    public var configuration: Configuration = .default {
        didSet {
            self.reloadTapGestureRecognizer()
            self.reloadDotViews()
        }
    }

    // MARK: - UIView

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if self.dots.count < 1 { return }

        let rectW: (CGRect) -> CGFloat
        let rectH: (CGRect) -> CGFloat
        let pointX: (CGPoint) -> CGFloat
        let pointY: (CGPoint) -> CGFloat
        let pointSetX: (inout CGPoint, CGFloat) -> Void
        let pointSetY: (inout CGPoint, CGFloat) -> Void

        switch self.configuration.layoutAxis {
        case .horizontal:
            rectW = { $0.width }
            rectH = { $0.height }
            pointX = { $0.x }
            pointY = { $0.y }
            pointSetX = { $0.x = $1 }
            pointSetY = { $0.y = $1 }
        case .vertical:
            rectW = { $0.height }
            rectH = { $0.width }
            pointX = { $0.y }
            pointY = { $0.x }
            pointSetX = { $0.y = $1 }
            pointSetY = { $0.x = $1 }
        }

        // The algorithm is written for horizontal left-to-right case, any else are just mirroring

        let spacing = self.configuration.spacing
        let paddings = self.configuration.paddings
        let contentRect = CGRect(x: paddings.left,
                                 y: paddings.top,
                                 width: self.bounds.width - paddings.left - paddings.right,
                                 height: self.bounds.height - paddings.top - paddings.bottom)
        var center: CGPoint = contentRect.origin
        pointSetX(&center, pointX(center) - spacing)
        pointSetY(&center, pointY(center) + rectH(contentRect) / 2)
        for dotView in self.dotViews {
            pointSetX(&center, pointX(center) + spacing)

            pointSetX(&dotView.center, pointX(center) + rectW(dotView.frame) / 2)
            pointSetY(&dotView.center, pointY(center))

            pointSetX(&center, pointX(center) + rectW(dotView.frame))
        }
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let spacing = self.configuration.spacing
        let initialSize = CGSize(width: -spacing, height: -spacing)
        let result = self.dotViews.reduce(initialSize) { result, dotView -> CGSize in
            switch self.configuration.layoutAxis {
            case .horizontal: return CGSize(
                width: result.width + spacing + dotView.frame.size.width,
                height: max(result.height, dotView.frame.height)
            )
            case .vertical: return CGSize(
                width: max(result.width, dotView.frame.size.width),
                height: result.height + spacing + dotView.frame.size.height
            )
            }
        }
        let paddings = self.configuration.paddings
        return CGSize(
            width: paddings.left + result.width + paddings.right,
            height: paddings.top + result.height + paddings.bottom
        )
    }

    public override func sizeToFit() {
        self.frame.size = self.sizeThatFits(self.frame.size)
        self.invalidateIntrinsicContentSize()
        self.setNeedsLayout()
    }

    public override var intrinsicContentSize: CGSize {
        return self.sizeThatFits(self.frame.size)
    }

    // MARK: - Private

    private var dotViews = [DotView]()
    private weak var activeDotIndexAnimator: Animator? = nil

    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        recognizer.addTarget(self, action: #selector(self.handleTap))
        return recognizer
    }()

    private func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.activeDotIndex = 0
        self.configuration = .default
        self.accessibilityIdentifier = "page_control"
    }

    private func reloadTapGestureRecognizer() {
        if self.configuration.changesActiveDotOnTap {
            self.addGestureRecognizer(self.tapGestureRecognizer)
        } else {
            self.removeGestureRecognizer(self.tapGestureRecognizer)
        }
    }

    @objc
    private func handleTap(recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: self)
        let paddings = self.configuration.paddings
        let center = CGPoint(
            x: (self.bounds.width + paddings.left - paddings.right) / 2,
            y: (self.bounds.height + paddings.top - paddings.bottom) / 2
        )

        let diff: CGFloat
        switch self.configuration.layoutAxis {
        case .horizontal:
            diff = tapLocation.x - center.x
        case .vertical:
            diff = tapLocation.y - center.y
        }

        let newIndex = round(self.activeDotIndex) + ((diff > 0) ? 1 : -1)
        self.setActiveDotIndex(newIndex, animated: true)
        self.onActiveDotIndexChanged?(newIndex)
    }

    private func reloadDotViews() {
        self.dotViews.forEach { $0.removeFromSuperview() }
        self.dotViews = self.dots.map { DotView(dot: $0) }
        self.dotViews.forEach { self.addSubview($0) }
        self.updateDotViews()
        self.sizeToFit()
    }

    private func updateDotViews() {
        self.dotViews.forEach { $0.applyRegularStyle() }

        let floorIdx = Int(floor(self.activeDotIndex))
        let ceilIdx = Int(ceil(self.activeDotIndex))
        let lerpValue = self.activeDotIndex - Float(floorIdx)

        if 0 <= ceilIdx && ceilIdx < self.dotViews.count {
            self.dotViews[ceilIdx].applyIntermediateStyle(lerpValue: lerpValue)
        }

        if 0 <= floorIdx && floorIdx < self.dotViews.count {
            self.dotViews[floorIdx].applyIntermediateStyle(lerpValue: 1 - lerpValue)
        }

        self.setNeedsLayout()
    }
}

private class Animator: NSObject {

    @discardableResult
    static func animate(duration: TimeInterval, work: @escaping (Float) -> Void) -> Animator {
        let animator = Animator(duration: duration, work: work)
        animator.run()
        return animator
    }

    private let duration: TimeInterval
    private let work: (Float) -> Void
    private var initialTimestamp: TimeInterval? = nil
    private var selfHolder: Animator? = nil
    private var displayLink: CADisplayLink? = nil

    func cancel() {
        self.displayLink?.invalidate()
        self.selfHolder = nil
    }

    private init(duration: TimeInterval, work: @escaping (Float) -> Void) {
        self.duration = duration
        self.work = work
        super.init()
        self.selfHolder = self
    }

    private func run() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(self.onFire))
        self.displayLink?.add(to: RunLoop.main, forMode: .commonModes)
        self.work(0)
    }

    @objc
    private func onFire(displayLink: CADisplayLink) {
        if self.initialTimestamp == nil {
            self.initialTimestamp = displayLink.timestamp
        }

        let initialTimestamp = self.initialTimestamp!
        let lerpValue = (displayLink.timestamp - initialTimestamp) / self.duration
        self.work(Float(lerpValue).clamped(0, 1))

        if displayLink.timestamp - initialTimestamp > self.duration {
            self.cancel()
        }
    }
}

private extension PageControl {

    class DotView: UIView {

        required init?(coder aDecoder: NSCoder) {
            self.dot = .default
            super.init(coder: aDecoder)
            self.commonInit()
        }

        init(dot: Dot) {
            self.dot = dot
            super.init(frame: .zero)
            self.commonInit()
        }

        func applyRegularStyle() {
            self.applyStyle(style: self.dot.regularStyle)
        }

        func applyActiveStyle() {
            self.applyStyle(style: self.dot.activeStyle)
        }

        /// [0..1] means [regular..active]
        func applyIntermediateStyle(lerpValue: Float) {
            let blendedStyle = lerpValue.clamped(0, 1).lerp(self.dot.regularStyle, self.dot.activeStyle)
            self.applyStyle(style: blendedStyle)
        }

        private let dot: Dot

        private func commonInit() {
            self.applyRegularStyle()
            self.accessibilityIdentifier = "page_control.dot"
        }

        private func applyStyle(style: Dot.Style) {
            self.frame.size = CGSize(width: CGFloat(style.radius * 2), height: CGFloat(style.radius * 2))
            self.backgroundColor = style.fillColor
            self.layer.cornerRadius = CGFloat(style.radius)
            self.layer.borderWidth = CGFloat(style.strokeWidth)
            self.layer.borderColor = style.strokeColor.cgColor
        }
    }
}

private extension Float {

    func clamped(_ min: Float, _ max: Float) -> Float {
        return Swift.max(min, Swift.min(self, max))
    }

    func lerp(_ from: Float, _ to: Float) -> Float {
        return from + (self.clamped(0, 1) * (to - from))
    }

    func lerp(_ from: CGFloat, _ to: CGFloat) -> CGFloat {
        return from + (CGFloat(self.clamped(0, 1)) * (to - from))
    }

    func lerp(_ from: UIColor, _ to: UIColor) -> UIColor {
        var (fromRed, fromGreen, fromBlue, fromAlpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        from.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)

        var (toRed, toGreen, toBlue, toAlpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        to.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)

        if fromAlpha == 0 {
            (fromRed, fromGreen, fromBlue) = (toRed, toGreen, toBlue)
        }

        if toAlpha == 0 {
            (toRed, toGreen, toBlue) = (fromRed, fromGreen, fromBlue)
        }

        return UIColor(
            red: self.lerp(fromRed, toRed),
            green: self.lerp(fromGreen, toGreen),
            blue: self.lerp(fromBlue, toBlue),
            alpha: self.lerp(fromAlpha, toAlpha)
        )
    }

    func lerp(_ from: PageControl.Dot.Style, _ to: PageControl.Dot.Style) -> PageControl.Dot.Style {
        return PageControl.Dot.Style(
            radius: self.lerp(from.radius, to.radius),
            fillColor: self.lerp(from.fillColor, to.fillColor),
            strokeColor: self.lerp(from.strokeColor, to.strokeColor),
            strokeWidth: self.lerp(from.strokeWidth, to.strokeWidth)
        )
    }
}

extension PageControl.Configuration {

    public static var `default`: PageControl.Configuration {
        return PageControl.Configuration(
            layoutAxis: .horizontal,
            spacing: 5,
            paddings: .zero,
            changesActiveDotOnTap: true,
            animationDuration: 0.15
        )
    }
}

extension PageControl.Dot {

    public static var `default`: PageControl.Dot {
        let regularStyle = PageControl.Dot.Style(
            radius: 10,
            fillColor: .clear,
            strokeColor: .black,
            strokeWidth: 2
        )

        let activeStyle = PageControl.Dot.Style(
            radius: 10,
            fillColor: .black,
            strokeColor: .clear,
            strokeWidth: 0
        )

        return PageControl.Dot(
            regularStyle: regularStyle,
            activeStyle: activeStyle
        )
    }
}
