//
//  MainMenu.swift
//  ColorMatch
//
//  Created by Jason Jackrel on 8/17/17.
//  Copyright © 2017 Jason Jackrel. All rights reserved.
//

import SpriteKit

class EndScene: SKScene {
    var l1: SKLabelNode!
    var l2: SKLabelNode!
    var l3: SKLabelNode!
    
    let defaults = UserDefaults.standard
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        scene?.scaleMode = .aspectFit
        self.view?.showsFPS = false
        self.view?.showsFields = false
        self.view?.showsPhysics = false
        self.view?.showsDrawCount = false
        self.view?.showsNodeCount = false
        
        l1 = self.childNode(withName: "scoreLabel") as! SKLabelNode
        l2 = self.childNode(withName: "highScoreLabel") as! SKLabelNode
        l3 = self.childNode(withName: "mode") as! SKLabelNode
        
        l1.text = String(score)
        switch(difficulty) {
        case 0: l2.text = String(defaults.integer(forKey: "HIGHSCOREEASY"))
                l3.text = "Easy Mode"
        case 1: l2.text = String(defaults.integer(forKey: "HIGHSCOREMEDIUM"))
                l3.text = "Medium Mode"
        case 2: l2.text = String(defaults.integer(forKey: "HIGHSCOREHARD"))
                l3.text = "Hard Mode"
        case 3: l2.text = String(defaults.integer(forKey: "HIGHSCOREINSANE"))
                l3.text = "Insane Mode"
        default: print("error")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        loadGame()
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
    func loadGame() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = MainMenu(fileNamed:"MainMenu") else {
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }
        
        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFill
        
        /* Show debug */
        skView.showsPhysics = true
        skView.showsDrawCount = true
        skView.showsFPS = true
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
}
