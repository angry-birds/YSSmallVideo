//
//  YSVideoRecordView.swift
//  WeChatLiveDemo
//
//  Created by angrybirds on 2017/3/30.
//  Copyright © 2017年 YuanMedia. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

protocol YSVideoRecordDelegate {
    
    func recordedVideo(in recordView: YSVideoRecordView, fileURL: URL)
    
    func clickBack(in videoRecordView: YSVideoRecordView)
}


class YSVideoRecordView: UIView, AVCaptureFileOutputRecordingDelegate{
    
    var delegate: YSVideoRecordDelegate?
    
    //视频捕获会话。它是input和output的桥梁。它协调着intput到output的数据传输
    let captureSession = AVCaptureSession()
    //前置摄像头
    var frontVideoDevice = AVCaptureDevice.init(uniqueID: "com.apple.avfoundation.avcapturedevice.built-in_video:1")


    //后置摄像头
    var backVideoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)

    //默认前置
    var isFrontDevice = true
    
    //音频输入设备
    let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
    //将捕获到的视频输出到文件
    let fileOutput = AVCaptureMovieFileOutput()
    
    var videoInput: AVCaptureDeviceInput?
    var audioInput: AVCaptureDeviceInput?
    
    //拍摄view
    @IBOutlet weak var view: UIView!
    //进度条底条
    @IBOutlet weak var progressBgView: UIView!
    
    //翻转相机
    @IBOutlet weak var overturnButton: UIButton!
    //返回
    @IBOutlet weak var backButton: UIButton!
    //拍摄按钮
    @IBOutlet weak var recordingButton: UIButton!
    
    //按钮颜色
    let recordingColor = UIColor.init(red: 182/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
    let recordFinishColor = UIColor.init(red: 28/255.0, green: 166/255.0, blue: 29/255.0, alpha: 1.0)
    
    //是否前置
    var frontCamera: Bool = false
    
    //进度条
    var progressView: UIView!
    
    //是否拍摄
    var isRecording = false
    
    
    
// MARK: init
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        progressView = UIView.init(frame: progressBgView.frame)
        progressView.backgroundColor = UIColor.init(colorLiteralRed: 29/255.0, green: 166/255.0, blue: 30/255.0, alpha: 1)
        self.addSubview(progressView)
        
        
        //添加视频、音频输入设备
        videoInput = try! AVCaptureDeviceInput(device: frontVideoDevice)
        captureSession.addInput(videoInput)
        
        audioInput = try! AVCaptureDeviceInput(device: audioDevice)
        captureSession.addInput(audioInput);
        
        //添加视频捕获输出
        captureSession.addOutput(fileOutput)
        
        //使用AVCaptureVideoPreviewLayer可以将摄像头的拍摄的实时画面显示在ViewController上
        if let videoLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            videoLayer.frame = view.bounds
            videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            view.layer.addSublayer(videoLayer)
        }
        
        //启动session会话
//        captureSession.startRunning()

        }
    
    
    //录像开始的代理方法
    func capture(_ captureOutput: AVCaptureFileOutput!,
                 didStartRecordingToOutputFileAt fileURL: URL!,
                 fromConnections connections: [Any]!) {
        
        
    }
    
// MARK: AVCaptureFileOutputRecordingDelegate
    
    //录像结束的代理方法
    func capture(_ captureOutput: AVCaptureFileOutput!,
                 didFinishRecordingToOutputFileAt outputFileURL: URL!,
                 fromConnections connections: [Any]!, error: Error!) {
        
        if let url = outputFileURL {
            delegate?.recordedVideo(in: self, fileURL: url)
            
        }
    }
    
    
    
// MARK: eventMethod
    
    /// 拍摄开始
    @IBAction func recordBegin(_ sender: Any) {
        
        if !isRecording {
            let documentsDirectory = NSTemporaryDirectory()
            
            let filePath = "\(documentsDirectory)/temp.mp4"
            
            let isExist = FileManager.default.fileExists(atPath: filePath)
            
            if isExist {
                try! FileManager.default.removeItem(atPath: filePath)
            }
            
            let fileURL = URL(fileURLWithPath: filePath)
            
            //启动视频编码输出
            fileOutput.startRecording(toOutputFileURL: fileURL, recordingDelegate: self)
            
            //记录状态：录像中...
            isRecording = true
            //开始、结束按钮颜色改变
            updateButtonColor()
            
            UIView.animate(withDuration: 10, delay: 0, options: .curveLinear, animations: {
                
                self.progressView.frame =
                    CGRect(x: self.progressView.frame.size.width/2, y: self.progressView.frame.origin.y, width: 0, height: 4)
                
            }, completion: { (true) in
                
                if self.isRecording {
                    self.recordFinish(sender)
                }
            })

            
        }
        
        
        
    }
    
    /// 拍摄结束
    @IBAction func recordFinish(_ sender: Any) {
        
        isRecording = false
        self.progressView.layer.removeAllAnimations()
        
        progressView.frame = progressBgView.frame
        
        //停止视频编码输出
        fileOutput.stopRecording()
        updateButtonColor()
        
    }
    
    
    
    
    /// 点击翻转摄像头
    @IBAction func overturn(_ sender: Any) {

        isFrontDevice = !isFrontDevice
        self.setVideoInput()
    }
    
    
    
    
    
    /// 点击返回
    ///
    /// - Parameter sender:
    @IBAction func back(_ sender: Any) {

        delegate?.clickBack(in: self)
    }
    

    
    /// 设置前后摄像头
    func setVideoInput() {
        
        if !isRecording {
            
            captureSession.removeInput(videoInput)
            
            
            if !isFrontDevice {
                videoInput = try! AVCaptureDeviceInput(device: backVideoDevice)
            } else {
                videoInput = try! AVCaptureDeviceInput(device: frontVideoDevice)
            }
            
            captureSession.addInput(videoInput)
            //启动session会话
            captureSession.startRunning()

            
        }
    }
    
    
// MARK: PrivateMethod
    
    /// 点击更换按钮颜色
    func updateButtonColor() {
        
        if isRecording {
            recordingButton.backgroundColor = recordingColor
        } else {
            recordingButton.backgroundColor = recordFinishColor
        }
        
    }

}







