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

import XCTest
@testable import THEPageControl

class PageControlTests: XCTestCase {

    var pageControl: PageControl!

    override func setUp() {
        super.setUp()
        self.pageControl = PageControl()
    }

    override func tearDown() {
        self.pageControl = nil
        super.tearDown()
    }

    func test_PageControl_ClampsIndex() {
        self.pageControl.dots = Array(repeating: .default, count: 5)

        self.pageControl.activeDotIndex = -1
        XCTAssertEqual(self.pageControl.activeDotIndex, 0)

        self.pageControl.activeDotIndex = 100
        XCTAssertEqual(self.pageControl.activeDotIndex, Float(self.pageControl.dots.count - 1))
    }

    func test_PageControl_SetIndexCorrectly() {
        self.pageControl.dots = Array(repeating: .default, count: 5)
        let index: Float = 3
        self.pageControl.setActiveDotIndex(index, animated: false)
        XCTAssertEqual(self.pageControl.activeDotIndex, index)
    }

    func test_PageControl_DoesHorizontalSizingCorrectly() {
        let configuration = PageControl.Configuration.default
        let dot = PageControl.Dot.default
        let dots: [PageControl.Dot] = Array(repeating: dot, count: 3)

        var expectedWidth: CGFloat = configuration.paddings.left
        expectedWidth += configuration.spacing * CGFloat(dots.count - 1)
        expectedWidth += CGFloat(dot.regularStyle.radius) * 2 * CGFloat(dots.count - 1)
        expectedWidth += CGFloat(dot.activeStyle.radius) * 2
        expectedWidth += configuration.paddings.right

        var expectedHeight: CGFloat = configuration.paddings.top
        expectedHeight += CGFloat(dot.activeStyle.radius) * 2
        expectedHeight += configuration.paddings.bottom

        self.pageControl.dots = dots
        self.pageControl.configuration = configuration
        self.pageControl.layoutIfNeeded()

        XCTAssertEqual(self.pageControl.frame.size.width, expectedWidth)
        XCTAssertEqual(self.pageControl.frame.size.height, expectedHeight)
    }

    func test_PageControl_DoesVerticalSizingCorrectly() {
        var configuration = PageControl.Configuration.default
        configuration.layoutAxis = .vertical
        let dot = PageControl.Dot.default
        let dots: [PageControl.Dot] = Array(repeating: dot, count: 3)

        var expectedHeight: CGFloat = configuration.paddings.top
        expectedHeight += configuration.spacing * CGFloat(dots.count - 1)
        expectedHeight += CGFloat(dot.regularStyle.radius) * 2 * CGFloat(dots.count - 1)
        expectedHeight += CGFloat(dot.activeStyle.radius) * 2
        expectedHeight += configuration.paddings.bottom

        var expectedWidth: CGFloat = configuration.paddings.left
        expectedWidth += CGFloat(dot.activeStyle.radius) * 2
        expectedWidth += configuration.paddings.right

        self.pageControl.dots = dots
        self.pageControl.configuration = configuration
        self.pageControl.layoutIfNeeded()

        XCTAssertEqual(self.pageControl.frame.size.width, expectedWidth)
        XCTAssertEqual(self.pageControl.frame.size.height, expectedHeight)
    }
}
