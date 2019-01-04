//
//  MainMenu.swift
//  ColorMatch
//
//  Created by Jason Jackrel on 8/17/17.
//  Copyright © 2017 Jason Jackrel. All rights reserved.
//

import SpriteKit
import AVFoundation

var bombSoundEffect: AVAudioPlayer!

let path = Bundle.main.path(forResource: "core.mp3", ofType:nil)!
let url = URL(fileURLWithPath: path)

class MainMenu: SKScene {
    var ds: SKSpriteNode!
    var l1: SKLabelNode!
    var l2: SKLabelNode!
    var nDelay = false
    var delay = 0
    var highScoreLabel: SKLabelNode!
    let defaults = UserDefaults.standard
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        self.view?.showsFPS = false
        self.view?.showsFields = false
        self.view?.showsPhysics = false
        self.view?.showsDrawCount = false
        self.view?.showsNodeCount = false
        scene?.scaleMode = .aspectFit
        
        ds = self.childNode(withName: "diffSelect") as! SKSpriteNode
        l1 = self.childNode(withName: "diff3") as! SKLabelNode
        l2 = self.childNode(withName: "score") as! SKLabelNode
        highScoreLabel = self.childNode(withName: "mbg") as! SKLabelNode
        if defaults.bool(forKey: "SOUND") != false {
            highScoreLabel.text = "Music Off"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        for t in touches {
            let position = t.location(in: self)
            let node = atPoint(position)
            
            if node.name == "start" {
                loadGame()
            }
            if node.name == "clearbutton" {
                loadClear()
            }
            if node.name == "muteButton" {
                print("tapped")
                if(defaults.bool(forKey: "SOUND") != true) {
                    highScoreLabel.text = "Music off"
                    do {
                        let sound = try AVAudioPlayer(contentsOf: url)
                        bombSoundEffect = sound
                        sound.pause()
                    } catch {
                        // couldn't load file :(
                    }
                    defaults.set(true, forKey: "SOUND")
                }
                else
                {
                    highScoreLabel.text = "Music on"
                    nDelay = true
                    do {
                        let sound = try AVAudioPlayer(contentsOf: url)
                        bombSoundEffect = sound
                        bombSoundEffect.numberOfLoops = -1
                        sound.play()
                    } catch {
                        // couldn't load file :(
                    }
                    
                    defaults.set(false, forKey: "SOUND")
                }
            }

            if node.name == "selector" {
                if(difficulty > 2) {
                    difficulty = 0
                }
                else{
                    difficulty += 1
                }
                switch(difficulty) {
                case 0: ds.color = UIColor.green
                case 1: ds.color = UIColor.yellow
                case 2: ds.color = UIColor.orange
                case 3: ds.color = UIColor.red
                default: ds.color = UIColor.blue
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        if(nDelay == true) {
            delay = delay + 1
        }
        if(delay > 120) {
            delay = 0
            nDelay = false
            highScoreLabel.text = "Music by Ghidorah"
        }
        switch(difficulty) {
        case 0: ds.color = UIColor.green
            l1.text = "Easy"
        l2.text = String(defaults.integer(forKey: "HIGHSCOREEASY"))
        case 1: ds.color = UIColor.yellow
             l1.text = "Medium"
            l2.text = String(defaults.integer(forKey: "HIGHSCOREMEDIUM"))
        case 2: ds.color = UIColor.orange
            l1.text = "Hard"
            l2.text = String(defaults.integer(forKey: "HIGHSCOREHARD"))
        case 3: l1.text = "Insane"
            ds.color = UIColor.red
            l2.text = String(defaults.integer(forKey: "HIGHSCOREINSANE"))
        default: ds.color = UIColor.blue
            l1.text="Error!"
        }
        
        
    }
    
    func loadClear() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = ClearScreen(fileNamed:"ClearScreen") else {
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }
        
        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFit
        
        /* Show debug */
        skView.showsPhysics = true
        skView.showsDrawCount = true
        skView.showsFPS = true
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
    
    func loadGame() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = GameScene(fileNamed:"GameScene") else {
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }
        
        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFit
        
        /* Show debug */
        skView.showsPhysics = true
        skView.showsDrawCount = true
        skView.showsFPS = true
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
}
