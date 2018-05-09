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

import UIKit
import THEPageControl

extension PageControl.Dot {

    static var customStyle1: PageControl.Dot {
        let regularStyle = PageControl.Dot.Style(
            shape: .circle,
            radius: 10,
            fillColor: .red,
            strokeColor: .black,
            strokeWidth: 10
        )

        let activeStyle = PageControl.Dot.Style(
            shape: .circle,
            radius: 10,
            fillColor: .red,
            strokeColor: .black,
            strokeWidth: 5
        )

        return PageControl.Dot(
            regularStyle: regularStyle,
            activeStyle: activeStyle
        )
    }

    static var customStyle2: PageControl.Dot {
        let regularStyle = PageControl.Dot.Style(
            shape: .circle,
            radius: 10,
            fillColor: (UIColor.gray).withAlphaComponent(0.5),
            strokeColor: .clear,
            strokeWidth: 0
        )

        let activeStyle = PageControl.Dot.Style(
            shape: .circle,
            radius: 15,
            fillColor: .gray,
            strokeColor: .clear,
            strokeWidth: 0
        )

        return PageControl.Dot(
            regularStyle: regularStyle,
            activeStyle: activeStyle
        )
    }

    static var customStyle3: PageControl.Dot {
        let regularStyle = PageControl.Dot.Style(
            shape: .circle,
            radius: 10,
            fillColor: (UIColor.orange).withAlphaComponent(0.5),
            strokeColor: .clear,
            strokeWidth: 0
        )

        let activeStyle = PageControl.Dot.Style(
            shape: .circle,
            radius: 15,
            fillColor: .orange,
            strokeColor: .clear,
            strokeWidth: 0
        )

        return PageControl.Dot(
            regularStyle: regularStyle,
            activeStyle: activeStyle
        )
    }
}

struct DotPresets {

    static var presets: [[PageControl.Dot]] {
        return [
            self.preset1,
            self.preset2,
            self.preset3
        ]
    }

    static var preset1: [PageControl.Dot] {
        return Array(repeating: .default, count: 10)
    }

    static var preset2: [PageControl.Dot] {
        return Array(repeating: .customStyle1, count: 10)
    }

    static var preset3: [PageControl.Dot] {
        var result = Array(repeating: PageControl.Dot.customStyle2, count: 9)
        result.insert(.customStyle3, at: 0)
        return result
    }
}

class ViewController: UIViewController {

    @objc var pageControls = [PageControl]()
    @objc var slider: UISlider?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white

        let slider = UISlider()
        slider.frame.size = CGSize(width: 300, height: 50)
        slider.center = self.view.center
        slider.center.y += 200
        slider.addTarget(self, action: #selector(self.onSliderChange), for: .valueChanged)
        slider.minimumValue = 0
        slider.maximumValue = 10
        self.view.addSubview(slider)
        self.slider = slider

        var centerY: CGFloat = -200
        for preset in DotPresets.presets {
            let pageControl = self.makePageControl(dots: preset)
            pageControl.translatesAutoresizingMaskIntoConstraints = true
            pageControl.center = self.view.center
            pageControl.center.y += centerY
            self.view.addSubview(pageControl)
            centerY += 50
        }
    }

    private func makePageControl(dots: [PageControl.Dot]) -> PageControl {
        let pageControl = PageControl()
        pageControl.configuration.paddings = .init(top: 20, left: 20, bottom: 20, right: 20)
        pageControl.dots = dots
        pageControl.onActiveDotIndexChanged = { [weak self] in
            self?.slider?.value = $0
            self?.updatePageControls(with: $0, animated: true)
        }
        self.pageControls.append(pageControl)
        return pageControl
    }

    @objc
    private func onSliderChange(slider: UISlider) {
        self.updatePageControls(with: slider.value, animated: false)
    }

    private func updatePageControls(with index: Float, animated: Bool) {
        self.pageControls.forEach { $0.setActiveDotIndex(index, animated: animated) }
    }
}
