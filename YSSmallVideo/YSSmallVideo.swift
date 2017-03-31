//
//  YSSmallVideo.swift
//  WeChatLiveDemo
//
//  Created by angrybirds on 2017/3/31.
//  Copyright © 2017年 YuanMedia. All rights reserved.
//

import UIKit
import AVFoundation

protocol YSSmallVideoDelegate {
    
    func clickBack(in ysSmoallVideo: YSSmallVideo)
    func recordVideo(in ysSmoallVideo: YSSmallVideo, url:URL)
    
}


class YSSmallVideo: UIView, YSVideoRecordDelegate, YSVideoPlayerDelegate {

    var delegate:YSSmallVideoDelegate?
    var recordView = Bundle.main.loadNibNamed("YSVideoRecordView", owner: nil, options: nil)?.first as! YSVideoRecordView
    var playerView = Bundle.main.loadNibNamed("YSVideoPlayerView", owner: nil, options: nil)?.first as! YSVideoPlayerView
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        
    }
    
    init(frame: CGRect, isFront:Bool) {
        super.init(frame: frame)
        setupView()
        recordView.isFrontDevice = isFront
        recordView.setVideoInput()
    }
    
    
// MARK: YSSmallVideoDelegate
    func clickBack(in videoRecordView: YSVideoRecordView) {
        
        delegate?.clickBack(in: self)
        
    }
    
    //拍摄完成 按钮回调
    func recordedVideo(in recordView: YSVideoRecordView, fileURL: URL) {
        
        playerView.isHidden = false
        playerView.url = fileURL
    }
    
    //点击 cancel 按钮回调
    func clickCancelButton(in playerView: YSVideoPlayerView) {
        playerView.isHidden = true
    }
    
    
    //点击 ok 按钮回调
    func clickOKButton(in playerView: YSVideoPlayerView, url: URL) {
        playerView.isHidden = true
        
        let asset = AVURLAsset.init(url: url, options: nil)
        let exportSession = AVAssetExportSession.init(asset: asset, presetName: AVAssetExportPresetMediumQuality)
        exportSession!.shouldOptimizeForNetworkUse = true
        
        
        let outputFilePath = NSTemporaryDirectory() + "export.mp4"        
        
        let isExist = FileManager.default.fileExists(atPath: outputFilePath)
        if isExist {
            try! FileManager.default.removeItem(atPath: outputFilePath)
        }
        
        let outputURL: URL = URL.init(fileURLWithPath: outputFilePath)
        
        exportSession!.outputURL = outputURL;
        exportSession!.outputFileType = AVFileTypeMPEG4;
        
        
        exportSession!.exportAsynchronously(completionHandler: {
            
            switch exportSession!.status {
                
            case .failed:
                print(exportSession!.error!)
                
            case .completed:
                self.delegate?.recordVideo(in: self, url: outputURL)
                
            default:
                break
                
                
            }
        })
        
    }
    
//MARK: PrivateResponse
    private func setupView() {
        
        self.addSubview(recordView)
        recordView.delegate = self
        
        self.addSubview(playerView)
        playerView.delegate = self
        playerView.isHidden = true
        
    }
}
