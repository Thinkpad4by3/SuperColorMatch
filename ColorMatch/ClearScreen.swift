import SpriteKit
import AVFoundation


class ClearScreen: SKScene {
    
    let defaults = UserDefaults.standard
    var scoreLabel: SKLabelNode!
    var diffLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        self.view?.showsFPS = false
        self.view?.showsFields = false
        self.view?.showsPhysics = false
        self.view?.showsDrawCount = false
        self.view?.showsNodeCount = false
        scene?.scaleMode = .aspectFit
        
        scoreLabel = self.childNode(withName: "sc") as! SKLabelNode
        diffLabel = self.childNode(withName: "di") as! SKLabelNode
        
        switch(difficulty) {
        case 0: scoreLabel.text = String(defaults.integer(forKey: "HIGHSCOREEASY"))
        diffLabel.text = "Easy Mode"
        case 1: scoreLabel.text = String(defaults.integer(forKey: "HIGHSCOREMEDIUM"))
        diffLabel.text = "Medium Mode"
        case 2: scoreLabel.text = String(defaults.integer(forKey: "HIGHSCOREHARD"))
        diffLabel.text = "Hard Mode"
        case 3: scoreLabel.text = String(defaults.integer(forKey: "HIGHSCOREINSANE"))
        diffLabel.text = "Insane Mode"
        default: print("error")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        for t in touches {
            let position = t.location(in: self)
            let node = atPoint(position)
            
            if node.name == "yes" {
                switch(difficulty) {
                case 0: defaults.set(0, forKey: "HIGHSCOREEASY")
                case 1: defaults.set(0, forKey: "HIGHSCOREMEDIUM")
                case 2: defaults.set(0, forKey: "HIGHSCOREHARD")
                case 3: defaults.set(0, forKey: "HIGHSCOREINSANE")
                default: print("error")
                }
                loadGame()
            }
            if node.name == "no" {
                loadGame()
            }
        }
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
