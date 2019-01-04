//
//  GameViewController.swift
//  ColorMatch
//
//  Created by Jason Jackrel on 8/15/17.
//  Copyright © 2017 Jason Jackrel. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation
import GoogleMobileAds
import AudioToolbox



class GameViewController: UIViewController,GADBannerViewDelegate {
    
    var googleBannerView: GADBannerView!
    
    override func viewDidLoad() {
        let defaults = UserDefaults.standard
        
        super.viewDidLoad()
        
        googleBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        
        googleBannerView.adUnitID = "ca-app-pub-6662258286660475/4898029469"
        googleBannerView.rootViewController = self
        googleBannerView.delegate = self
        var request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        googleBannerView.load(request)
        googleBannerView.frame = CGRect(x:0,y:0,width:googleBannerView.frame.size.width,height:googleBannerView.frame.size.height)
        
        self.view.addSubview(googleBannerView!)
        
        if(defaults.bool(forKey: "SOUND") != true) {
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            bombSoundEffect = sound
            bombSoundEffect.numberOfLoops = -1
            sound.play()
        } catch {
            // couldn't load file :(
        }
        }

        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = MainMenu(fileNamed: "MainMenu") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                // Present the scene
                view.presentScene(scene)
              /*  adBannerView = GADBannerView(frame: CGRect(x:0,y:0,width:self.view.frame.size.width,height:50))
                adBannerView.delegate = self
                adBannerView.rootViewController = self
                adBannerView.adUnitID = "YOUR AD ID"
                
                var reqAd = GADRequest()
               // reqAd.testDevices = [GAD_SIMULATOR_ID] // If you want test ad's
                adBannerView.load(reqAd)
                self.view.addSubview(adBannerView)
                adBannerView.adUnitID = "***"
                adBannerView.rootViewController = self
                adBannerView.load(GADRequest())*/
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    }
