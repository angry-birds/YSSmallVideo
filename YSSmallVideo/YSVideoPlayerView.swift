//
//  YSVideoPlayerView.swift
//  WeChatLiveDemo
//
//  Created by angrybirds on 2017/3/30.
//  Copyright © 2017年 YuanMedia. All rights reserved.
//

import UIKit
import AVFoundation

protocol YSVideoPlayerDelegate {
    func clickCancelButton(in playerView: YSVideoPlayerView)
    func clickOKButton(in playerView: YSVideoPlayerView, url:URL)
}


class YSVideoPlayerView: UIView {
    
    @IBOutlet weak var videoPlayView: UIView!
    
    var item: AVPlayerItem!
    
    override var isHidden: Bool{
        
        didSet{
            
            if isHidden == true {
                //移除通知
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
            }
            
        }
        
    }
    
    var delegate: YSVideoPlayerDelegate?
    
    var player: AVPlayer?
    
    var url: URL? {
        
        didSet{
            
            
            item = AVPlayerItem.init(url: url!)
            player = AVPlayer.init(playerItem: item)
            let playerLayer = AVPlayerLayer.init(player: player)
            playerLayer.frame = self.frame
            videoPlayView.layer.addSublayer(playerLayer)
            
            player?.play()
            
            //注册通知
            NotificationCenter.default.addObserver(self, selector: #selector(replayer), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    
    
    
    /// 点击❌按钮
    @IBAction func cancel(_ sender: Any) {
        
        delegate?.clickCancelButton(in: self)
        player?.pause()
    }
    
    /// 点击✅按钮
    @IBAction func ok(_ sender: Any) {
        
        delegate?.clickOKButton(in: self, url: url!)
        player?.pause()
    }
    
    /// 默认执行重复播放
    func replayer() {
        player?.seek(to: kCMTimeZero)
        player?.play()
    }
    
    
}
