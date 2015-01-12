//
//  ScanShapeView.swift
//  ScanQR
//
//  Created by 吕建耀 on 14/12/22.
//  Copyright (c) 2014年 吕建耀. All rights reserved.
//
import UIKit

class ScanShapeView : UIView {
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //corners属性数组包含了CGPoint对象，每一个都代表我们希望绘制图像路径的拐角处。
    var corners = []
    
    //使用一个CAShapeLayer来进行绘制这些点，并且这是非常有效率的方法来绘制图形:
    var outline = CAShapeLayer()
    
    
    override init(frame aRect: CGRect){
        super.init(frame: aRect)
        
        outline.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.8).CGColor
        outline.lineWidth = 2.0
        outline.fillColor = UIColor.clearColor().CGColor
        self.layer.addSublayer(outline)
        
    }
    
    //设置图形的路径
    func setCorners(corners: NSArray){
        
        if (corners != self.corners){
            self.corners = corners
            self.outline.path = self.createPathFromPoints(corners).CGPath
        }
        
    }
    
    //conrners属性发生变化则重现绘制图形
    func createPathFromPoints(points: NSArray) -> UIBezierPath{
        
        var path = UIBezierPath()
        path.moveToPoint(points.firstObject!.CGPointValue())
        
        for point in points {
            path.addLineToPoint(point.CGPointValue())
        }
        
        path.addLineToPoint(points.firstObject!.CGPointValue())
        
        return path
    }
    
}