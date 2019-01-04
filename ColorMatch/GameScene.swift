import SpriteKit
import AVFoundation
import GoogleMobileAds

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    var toHexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(
            format: "%02X%02X%02X",
            Int(r * 0xff),
            Int(g * 0xff),
            Int(b * 0xff)
        )
    }
}

extension Array
{
    /** Randomizes the order of an array's elements. */
    mutating func shuffle()
    {
        for _ in 0..<10
        {
            sort { (_,_) in arc4random() < arc4random() }
        }
    }
}

var score: Int!
var difficulty = 0

class GameScene: SKScene {
    
    var p1: SKSpriteNode!
    var p2: SKSpriteNode!
    var p3: SKSpriteNode!
    var p4: SKSpriteNode!
    var p5: SKSpriteNode!
    var p6: SKSpriteNode!
    var p7: SKSpriteNode!
    var p8: SKSpriteNode!
    var p9: SKSpriteNode!
    
    var b1: SKSpriteNode!
    var b2: SKSpriteNode!
    var b3: SKSpriteNode!
    var b4: SKSpriteNode!
    
    var pb: SKSpriteNode!
    
    var timeLabel: SKLabelNode!
    
    var changing1 = 10
    var changing2 = 11
    
    var scorelabel: SKLabelNode!
    
    var fixedDelta: CFTimeInterval = 1.0/60.0
    var timer: CFTimeInterval = 0.0
    
    var bottomColor = ["","","","","","","","",""]
    var bottomBlocks = [SKSpriteNode] ()
    
    var currentPointer = 4
    var correctPointer = 0
    var blockSpeed = 3.0
    let multiplier = 1.05
    let maxSpeed = 4.6
    let maxSpeedEasy = 6.0
    let maxSpeedHard = 3.8
    
    var x = 0.0
    
    var highScoreLabel: SKLabelNode!
    var starting = false
    var delay = 0
    var nDelay = false
    var startDelay = false
    
    var prevRed = 0
    var prevGrn = 0
    var prevBlu = 0
    
    var changeColors = false
    var paused1 = false
    
    var colors = ["FF5500","FFAA00","FFFF00","AAFF00","55FF00","00FF00","00FF55","00FFAA","00FFFF","00AAFF","0055FF","0000FF","5500FF","AA00FF","FF00FF","FF00AA","FF0055"]
    var easycolors = ["FF0000", "FFAA00", "FFFF00", "00FF00", "00FFFF", "0000FF", "FF00FF", "555555", "FFFFFF"]
    var defaults = UserDefaults.standard
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        
        self.view?.showsFPS = false
        self.view?.showsFields = false
        self.view?.showsPhysics = false
        self.view?.showsDrawCount = false
        self.view?.showsNodeCount = false
        scene?.scaleMode = .aspectFit
        
        p1 = self.childNode(withName: "pos1") as! SKSpriteNode
        p2 = self.childNode(withName: "pos2") as! SKSpriteNode
        p3 = self.childNode(withName: "pos3") as! SKSpriteNode
        p4 = self.childNode(withName: "pos4") as! SKSpriteNode
        p5 = self.childNode(withName: "pos5") as! SKSpriteNode
        p6 = self.childNode(withName: "pos6") as! SKSpriteNode
        p7 = self.childNode(withName: "pos7") as! SKSpriteNode
        p8 = self.childNode(withName: "pos8") as! SKSpriteNode
        p9 = self.childNode(withName: "pos9") as! SKSpriteNode
        
        b1 = self.childNode(withName: "brick1") as! SKSpriteNode
        b2 = self.childNode(withName: "brick2") as! SKSpriteNode
        b3 = self.childNode(withName: "brick3") as! SKSpriteNode
        b4 = self.childNode(withName: "brick4") as! SKSpriteNode
        
        pb = self.childNode(withName: "pauseButton") as! SKSpriteNode
        
        highScoreLabel = self.childNode(withName: "hsLabel") as! SKLabelNode
        
        scorelabel = self.childNode(withName: "Score") as! SKLabelNode
        
        timeLabel = self.childNode(withName: "insaneLabel") as! SKLabelNode
        
        bottomBlocks = [p1,p2,p3,p4,p5,p6,p7,p8,p9]
        //set color
        randomizeColors()
        setColors()
        
        score = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        for t in touches {
            let position = t.location(in: self)
            let node = atPoint(position)
            if node.name == "leftButton" {
                if(b1.position.x > 20) {
                    if(paused1 == false) {
                    brickMoveLeft()
                    }
                    currentPointer -= 1
                }
            }
            if node.name == "rightButton" {
                if(b4.position.x < 290) {
                    if(paused1 == false) {
                        brickMoveRight()
                    }
                    currentPointer += 1
                }
            }
            
            if node.name == "pb" {
                if(paused1 == false){
                paused1 = true
                highScoreLabel.isHidden = false
                highScoreLabel.text = "Paused"
                }
                else{
                    paused1 = false
                    highScoreLabel.isHidden = true
                }
            }
            if node.name == "speakerButton" {
                print("tapped")
                if(defaults.bool(forKey: "SOUND") != true) {
                    highScoreLabel.isHidden = false
                    highScoreLabel.text = "Music off"
                    nDelay = true
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
                    highScoreLabel.isHidden = false
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
        }
        //returnColor(p5)
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        if(nDelay == true) {
            delay += 1
        }
        if(delay > 120) {
            delay = 0
            nDelay = false
            if(paused1 == true) {
                highScoreLabel.text = "Paused"
            }else {
            highScoreLabel.isHidden = true
            }
        }
        if(difficulty > 1) {
            if(score > 2) {
                timeLabel.alpha -= 0.03
            }
        }
        else {
            timeLabel.alpha = 0
        }
        if(paused1 == false) {
        timer += fixedDelta
        //setCurrentPointer()
        if(difficulty > 2) {
            /*if(bottomBlocks[changing1].color == hexStringToUIColor(hex: "000000")) {
             changeColors = true
             }
             if(changeColors == true) {*/
            
            let newColor = UIColor.init(hue: CGFloat(x), saturation: CGFloat(0.5), brightness: CGFloat(0.8), alpha: CGFloat(1))
            bottomBlocks[changing1].color = newColor
            bottomBlocks[changing2].color = newColor
            x += 0.025
            //}
        }

        
        if(startDelay == false) {
        if(b1.position.y < CGFloat(126)) {
            if(startDelay == false) {
                brickMoveToTop()
            }
                                    /*print("****")
            print("correct pointer: ", correctPointer)
            print("current pointer: ", currentPointer)
            print("Match? ", checkBrickForMatch())
            print("****")*/
            switch(difficulty) {
            case 0: if blockSpeed < maxSpeedEasy {
                blockSpeed *= multiplier
                }
            case 1: if blockSpeed < maxSpeed {
                blockSpeed *= multiplier
                }
            case 2: if blockSpeed < maxSpeedHard {
                blockSpeed *= multiplier
                }
            case 3: if blockSpeed < maxSpeedHard {
                blockSpeed *= multiplier
                }
            default: if blockSpeed < maxSpeed {
                blockSpeed *= multiplier
                }
            }
            print("blockspeed: ", blockSpeed)
            if(checkBrickForMatch() == true) {
                score = score + 1
                changeColors = false
            }
            else
            {
                //score = 0
                blockSpeed = 2.5
                switch(difficulty) {
                case 0:if (defaults.integer(forKey: "HIGHSCOREEASY") < score){
                    defaults.set(score, forKey: "HIGHSCOREEASY")
                }
                highScoreLabel.text = String(defaults.integer(forKey: "HIGHSCOREEASY"))
                case 1:if (defaults.integer(forKey: "HIGHSCOREMEDIUM") < score){
                    defaults.set(score, forKey: "HIGHSCOREMEDIUM")
                }
                highScoreLabel.text = String(defaults.integer(forKey: "HIGHSCOREMEDIUM"))
                case 2:if (defaults.integer(forKey: "HIGHSCOREHARD") < score){
                    defaults.set(score, forKey: "HIGHSCOREHARD")
                }
                highScoreLabel.text = String(defaults.integer(forKey: "HIGHSCOREHARD"))
                case 3:if (defaults.integer(forKey: "HIGHSCOREINSANE") < score){
                    defaults.set(score, forKey: "HIGHSCOREINSANE")
                }
                highScoreLabel.text = String(defaults.integer(forKey: "HIGHSCOREINSANE"))
                default: print("Error")
                }
                
               /* if (defaults.integer(forKey: "HIGHSCOREMEDIUM") < score){
                defaults.set(score, forKey: "HIGHSCOREMEDIUM")
                }
                highScoreLabel.text = String(defaults.integer(forKey: "HIGHSCOREMEDIUM"))*/
                
                if(starting==false) {
                    starting=true
                }
                else{
                    startDelay = true
                    loadGame()
                    highScoreLabel.isHidden = false
                }
                
            }
            scorelabel.text = String(score)
            correctPointer = Int(arc4random_uniform(5))
            if(startDelay == false) {
            randomizeColors()
            setColors()
            
            updateBrickColors()
            }
        }
        else{
            brickMoveDown()
        }
        }
        else{
            delay += 1
            brickMoveOutOfSight()
        }
        if(delay > 90) {
            
        }
    }
    }
    func selectUpperColor() -> String{
        let x = Int(arc4random_uniform(9))
        return bottomColor[x]
    }
    func brickMoveDown() {
        b1.position.y -= CGFloat(blockSpeed)
        b2.position.y -= CGFloat(blockSpeed)
        b3.position.y -= CGFloat(blockSpeed)
        b4.position.y -= CGFloat(blockSpeed)
    }
    func brickMoveLeft() {
        b1.position.x -= CGFloat(35)
        b2.position.x -= CGFloat(35)
        b3.position.x -= CGFloat(35)
        b4.position.x -= CGFloat(35)
    }
    func brickMoveRight(){
        b1.position.x += CGFloat(35)
        b2.position.x += CGFloat(35)
        b3.position.x += CGFloat(35)
        b4.position.x += CGFloat(35)
    }
    func brickMoveToTop() {
        b1.position.y = CGFloat(560)
        b2.position.y = CGFloat(560)
        b3.position.y = CGFloat(560)
        b4.position.y = CGFloat(560)
    }
    func brickMoveOutOfSight() {
        b1.position.y = CGFloat(5200)
        b2.position.y = CGFloat(5200)
        b3.position.y = CGFloat(5200)
        b4.position.y = CGFloat(5200)
    }
    func checkBrickForMatch() -> Bool{
        if(currentPointer == correctPointer) {
            return true
        }
        else{
            return false
        }
    }
    func updateBrickColors() {
        b1.color = hexStringToUIColor(hex: bottomColor[correctPointer])
        b2.color = hexStringToUIColor(hex: bottomColor[correctPointer+1])
        b3.color = hexStringToUIColor(hex: bottomColor[correctPointer+2])
        b4.color = hexStringToUIColor(hex: bottomColor[correctPointer+3])
    }
    func returnColor(_ x: SKSpriteNode!) {
        print(x.color.toHexString)
    }
    func randomizeColors(){
        for i in 0 ..< 9 {
            switch(difficulty) {
            case 0: easyColorSelect()
            case 1: bottomColor[i] = selectColor()
            case 2: hardColorSelect()
            case 3: self.bottomColor[i] = selectColor()
            default: bottomColor[i] = selectColor()
            }
            
        }
    }
    func setColors() {
        for j in 0 ..< 9 {
            bottomBlocks[j].texture = nil
            bottomBlocks[j].color = hexStringToUIColor(hex: bottomColor[j])
        }
        if(difficulty > 1) {
            let k = Int(arc4random_uniform(9))
            bottomBlocks[k].color = hexStringToUIColor(hex: "000000")
            if(difficulty == 2) {
                bottomBlocks[k].texture = SKTexture(imageNamed: "questionblock")
            }
            var l = Int(arc4random_uniform(9))
            while(abs(k-l) < 2) {
                l = Int(arc4random_uniform(9))
            }
            bottomBlocks[l].color = hexStringToUIColor(hex: "000000")
            if(difficulty == 2) {
              bottomBlocks[l].texture = SKTexture(imageNamed: "questionblock")
            }
            
            changing1 = k
            changing2 = l
            print("******")
            print(changing1)
            print(changing2)
        }
    }
    func easyColorSelect() {
        easycolors.shuffle()
        for i in 0 ..< 9 {
            bottomColor[i] = easycolors[i]
            
        }
    }
    func hardColorSelect() {
        easyColorSelect()
        var n = [String] ()
        n = bottomColor
        easyColorSelect()
        var q = [String] ()
        q = bottomColor
        var u = [String] ()
        for j in 0..<bottomColor.count {
            let k = arc4random_uniform(2)
            if(k < 1) {
                u.append(q[j])
            }
            else{
                u.append(n[j])
            }
        }
        bottomColor = u
    }
    func setCurrentPointer() {
        if(b1.position.y > 18 && b1.position.y < 20) {
            currentPointer = 0
        }
        else if(b1.position.y > 53 && b1.position.y < 56) {
            currentPointer = 1
        }
        else if(b1.position.y > 88 && b1.position.y < 91) {
            currentPointer = 2
        }
        else if(b1.position.y > 123 && b1.position.y < 126) {
            currentPointer = 3
        }
        else if(b1.position.y > 158 && b1.position.y < 161) {
            currentPointer = 4
        }
    }
    func selectColor() -> String{/*
        var r = (Int(arc4random_uniform(3)))
        var g = (Int(arc4random_uniform(3)))
        var b = (Int(arc4random_uniform(3)))
        if((prevRed+prevBlu+prevGrn) - (r+b+g) < 4) {
            r = (Int(arc4random_uniform(3)))
            g = (Int(arc4random_uniform(3)))
            b = (Int(arc4random_uniform(3)))
        }
        let n = numberToHex(r)+numberToHex(g)+numberToHex(b)
        prevRed = r
        prevGrn = g
        prevBlu = b
        return n*/
        
        let n = (Int(arc4random_uniform(17)))
        return colors[n]
    }
    func numberToHex(_ x:Int) -> String {
        switch(x) {
        case 0: return "33"
        case 1: return "AA"
        case 2: return "FF"
        case 3: return "FF"
        default: return "22"
        }
    }
    
    func loadGame() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = EndScene(fileNamed:"EndScene") else {
            print("Could not make MainMenu, check the name is spelled correctly")
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
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    }




