//
//  LiveViewController.swift
//  WeChatLiveDemo
//
//  Created by angrybirds on 2017/3/30.
//  Copyright © 2017年 YuanMedia. All rights reserved.
//

import UIKit


class LiveViewController: UIViewController, YSSmallVideoDelegate{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let smallVideo = YSSmallVideo.init(frame: view.frame, isFront: true)
        view.addSubview(smallVideo)
        smallVideo.delegate = self

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func clickBack(in ysSmoallVideo: YSSmallVideo) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func recordVideo(in ysSmoallVideo: YSSmallVideo, url: URL) {
        
        //上传数据库代码
        
    }
}
