//
//  ScanQR.swift
//  ScanQR
//
//  Created by 吕建耀 on 14/12/28.
//  Copyright (c) 2014年 吕建耀. All rights reserved.
//

import UIKit
import AVFoundation

class ScanQR:AVCaptureMetadataOutput,AVCaptureMetadataOutputObjectsDelegate  {
    
    //判断是否已经读取二维码
    var isReading:Bool = false
    
    var superUICtrl:UIViewController!
    
    //获得摄像头设备
    let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    //为摄像头创建会话
    let session = AVCaptureSession()
    var layer:AVCaptureVideoPreviewLayer!
    var boundingBox:ScanShapeView!
    
    
    func setupCamera(superUIViewController:UIViewController){
        
        var error : NSError?
        
        superUICtrl = superUIViewController
        
        let superView = superUICtrl.view
        
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        //获得设备的输入
        let input = AVCaptureDeviceInput(device:device, error : &error)
        
        //将摄像头作为会话的输入
        if (error != nil) {
            println(error?.description)
            return
        }
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        //为获得视频内容，创建一个layer
        layer = AVCaptureVideoPreviewLayer(session: session)
        
        //让视频填充满整个屏幕
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        //显示当前的视频输入
        layer.bounds = superView.bounds
        layer.position = CGPointMake(CGRectGetMidX(layer.bounds), CGRectGetMidY(layer.bounds))
        superView.layer.addSublayer(layer)
        
        
        //从视频中提取元数据本身
        let output = AVCaptureMetadataOutput()
        
        if (self.session.canAddOutput(output)){
            
            //当代码从视频流中找到目标，会生成数据元并通知代理，由于AVFoundation被设计成允许线程访问，所以需要指定代理在那个线程中使用
            output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            
            //为会话添加输出
            self.session.addOutput(output)
            
            //注册查找的二维码类型
            output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
        }
        
        //开启会话
        self.session.startRunning()
        
        //初始化图形视图
        self.boundingBox = ScanShapeView(frame: superView.bounds)
        self.boundingBox.backgroundColor = UIColor.clearColor()
        self.boundingBox.hidden = true
        
        superView.addSubview(self.boundingBox)
        
    }
    
    //实现视频代理的方法
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        //用来保存二维码扫描到的值
        var stringValue:String!
        
        for metadata in metadataObjects{
            
            stringValue = metadata.stringValue
            
            var transformed = layer.transformedMetadataObjectForMetadataObject(metadata as AVMetadataObject) as AVMetadataMachineReadableCodeObject
            
            //在屏幕上进行绘制
            boundingBox.frame = transformed.bounds
            boundingBox.hidden = false
            
            var translatedCorners = self.translatePoints(transformed.corners, fromView: superUICtrl.view, toView: boundingBox)
            boundingBox.setCorners(translatedCorners)
            
        }
        
        self.session.stopRunning()
        
        self.finishScanQR(stringValue)
    }
    
    //现在我们需要改变系统坐标系，设置corners属性，让图形层能够正确的显示
    func translatePoints(points: NSArray,fromView: UIView,toView: UIView) -> NSArray{
        var translatePoints = NSMutableArray()
        
        for point in points {
            
            var pointValue = CGPointMake(point["X"] as CGFloat, point["Y"] as CGFloat)
            
            var translatedPoint = fromView.convertPoint(pointValue, toView: toView)
            
            translatePoints.addObject(NSValue(CGPoint: translatedPoint))
            
        }
        
        return translatePoints.copy() as NSArray
    }
    
    //扫描得到二维码后的操作
    func finishScanQR(stringValue:NSString) ->NSString{
        
        println("code is \(stringValue)")
        
        var alertView = UIAlertView()
        alertView.delegate=self
        alertView.title = "二维码"
        alertView.message = "扫到的二维码内容为:\(stringValue)"
        alertView.addButtonWithTitle("确认")
        alertView.show()
        
        return stringValue

    }
    
}