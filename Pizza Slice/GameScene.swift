//
//  GameScene.swift
//  Pizza Slice
//
//  Created by William Entriken 2014-10-17
//  Copyright (c) 2014 William Entriken. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    
    let howto = SKSpriteNode(imageNamed: "howto")
    let eatSound = SKAction.playSoundFileNamed("eat.caf", waitForCompletion: false)
    let cwSound = SKAction.playSoundFileNamed("cw.caf", waitForCompletion: false)
    let ccwSound = SKAction.playSoundFileNamed("ccw.caf", waitForCompletion: false)
    let dieSound = SKAction.playSoundFileNamed("die.caf", waitForCompletion: false)
    var pacMan:SKShapeNode!

    let scoreLabel = SKLabelNode(fontNamed: "American Typewriter")
    let maxScoreLabel = SKLabelNode(fontNamed: "American Typewriter")
    let gameOverLabel = SKLabelNode(fontNamed: "American Typewriter")
    let achievementLabel = SKLabelNode(fontNamed: "American Typewriter")
    
    let pacManArc = M_PI * 0.4
    var viewRadius:CGFloat!
    var pacManRadius:CGFloat!
    var score:Int = 0
    var direction = 0
    var gameOver = false
    var readyToStartNewGame = true
    var nextPlaneLaunch:CFTimeInterval = 0
    
    /* Setup your scene here */
    override func didMoveToView(view: SKView) {
        self.gameOver = true
        self.viewRadius = hypot(view.frame.width, view.frame.height) / 2
        self.pacManRadius = self.viewRadius * 0.08
        
        var background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        background.name = "background"
        background.xScale = 2.0
        background.yScale = 2.0
        self.addChild(background)
        
        //        self.howto = SKSpriteNode(imageNamed: "howto")
        self.howto.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.howto.size = CGSizeMake(self.viewRadius * 0.2, self.viewRadius * 0.2)
        var actions = [SKAction]()
        actions.append(SKAction.rotateByAngle(CGFloat(-M_PI_2), duration: 0.5))
        actions.append(SKAction.waitForDuration(0.5))
        actions.append(SKAction.rotateByAngle(CGFloat(+M_PI_2), duration: 0))
        self.howto.runAction(SKAction.repeatActionForever(SKAction.sequence(actions)))
        self.addChild(self.howto)
        
        self.scoreLabel.text = "Score : 0"
        self.scoreLabel.fontColor = self.colorForScore(self.score)
        self.scoreLabel.fontSize = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 60 : 30
        self.scoreLabel.zPosition = 10
        self.scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - scoreLabel.frame.height * 2)
        self.addChild(scoreLabel)
        
        self.maxScoreLabel.text = "High Score : 0"
        self.maxScoreLabel.fontSize = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 60 : 30
        self.maxScoreLabel.zPosition = 10
        self.maxScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        self.maxScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - scoreLabel.frame.height * 3)
        
        self.gameOverLabel.text = "GAME OVER"
        self.gameOverLabel.fontSize = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 60 : 30
        self.gameOverLabel.zPosition = 9999999
        self.gameOverLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        self.gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - gameOverLabel.frame.height * 3.5)
        
//        self.gameOverLabel.text = "Acheivement: "
//        self.gameOverLabel.fontSize = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 60 : 30
//        self.gameOverLabel.zPosition = 9999999
//        self.gameOverLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
//        self.gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - gameOverLabel.frame.height * 3.5)
        
        var path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0, 0)
        CGPathAddArc(path, nil, 0, 0, self.pacManRadius, CGFloat(self.pacManArc/2), CGFloat(-self.pacManArc/2), false)
        self.pacMan = SKShapeNode(path:path)
        self.pacMan.fillColor = SKColor.yellowColor()
        self.pacMan.strokeColor = SKColor.clearColor()
        self.pacMan.zPosition = 9999999
        self.pacMan.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
    }

    func pointToLocation(point: CGPoint) {
        if readyToStartNewGame {
            self.startGame()
        }
        if gameOver {
            return
        }
        let rotation = atan2(point.y - self.frame.height/2, point.x - self.frame.width/2)
        let rotationDifference = rotation - self.pacMan.zRotation
        let differenceQuadrant14 = (rotationDifference + CGFloat(M_PI)) % CGFloat(2 * M_PI) - CGFloat(M_PI)
        if (differenceQuadrant14 > 0 && self.direction != 1) {
            self.runAction(self.ccwSound)
            self.direction = 1
        } else if (differenceQuadrant14 < 0 && self.direction == 1) {
            self.runAction(self.cwSound)
            self.direction = -1
        }
        self.pacMan.zRotation = rotation
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        let touch = touches.first as! UITouch
        self.pointToLocation(touch.locationInNode(self))
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        let touch = touches.first as! UITouch
        self.pointToLocation(touch.locationInNode(self))
    }
    
    func startGame() {
        self.howto.removeFromParent()
        self.score = 0
        self.gameOverLabel.removeFromParent()
        self.maxScoreLabel.removeFromParent()
        self.pacMan.zRotation = 0
        self.pacMan.fillColor = self.colorForScore(self.score)
        self.addChild(self.pacMan)
        self.scoreLabel.text = "Score : \(self.score)"
        self.scoreLabel.fontColor = self.colorForScore(self.score)
        self.readyToStartNewGame = false
        self.gameOver = false
    }
    
    func gameOver(attackingPiece: SKNode) {
        if self.gameOver {
            return
        }
        self.gameOver = true
        self.runAction(self.dieSound)

        self.enumerateChildNodesWithName("plane", usingBlock: { (plane:SKNode!, x) -> Void in
            plane.removeFromParent()
        })
        
        var maxScore = self.score
        if let savedMaxScore = NSUserDefaults.standardUserDefaults().objectForKey("maxScore") as? NSNumber {
            maxScore = max(self.score, Int(savedMaxScore))
        }
        NSUserDefaults.standardUserDefaults().setInteger(maxScore, forKey: "maxScore")
        self.maxScoreLabel.text = "High Score : \(maxScore)"
        self.maxScoreLabel.fontColor = self.colorForScore(maxScore)
        self.addChild(self.maxScoreLabel)
        self.addChild(self.gameOverLabel)
        
        var wait = SKAction.waitForDuration(1.5)
        var setReady = SKAction.runBlock {
            self.pacMan.removeFromParent()
            self.addChild(self.howto)
            self.readyToStartNewGame = true
        }
        self.runAction(SKAction.sequence([wait, setReady]))
        
        self.doShare(self.score)
    }
    
    /* Called before each frame is rendered */
    override func update(currentTime: CFTimeInterval) {
        if gameOver {return}
        if currentTime < self.nextPlaneLaunch {return}
        
        let interval:NSTimeInterval = 0.15 + 2/(Double(self.score) + 1)
        self.nextPlaneLaunch = currentTime + interval
        NSLog("launching")
        self.launchNewPlane()
    }
    
    func launchNewPlane() {
        let angle:CGFloat = CGFloat(Double(arc4random()) / 0x100000000 * 2 * M_PI)
        let startPoint = CGPointMake(self.viewRadius * cos(angle) + CGRectGetMidX(self.frame),
                                     self.viewRadius * sin(angle) + CGRectGetMidY(self.frame))
        let collisionPoint = CGPointMake(self.pacManRadius * cos(angle) + CGRectGetMidX(self.frame),
                                         self.pacManRadius * sin(angle) + CGRectGetMidY(self.frame))
        let middlePoint = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        var plane:SKSpriteNode = SKSpriteNode(imageNamed: "plane")
        plane.position = startPoint
        plane.name = "plane"
        plane.size = CGSizeMake(self.viewRadius * 0.05, self.viewRadius * 0.05)
        self.addChild(plane)
        
        var approachPacMac = SKAction.moveTo(collisionPoint, duration: 5)
        approachPacMac.timingMode = SKActionTimingMode.EaseIn
        
        var checkCollision:SKAction = SKAction.runBlock {
            if Double(cos(angle - self.pacMan.zRotation)) > Double(cos(self.pacManArc/2)) {
                self.score += 1
                self.scoreLabel.text = "Score : \(self.score)"
                self.runAction(self.eatSound)
                let color = self.colorForScore(self.score)
                self.pacMan.fillColor = color
                self.scoreLabel.fontColor = color
            } else {
                self.gameOver(plane)
            }
        }
        
        var approachCenter = SKAction.moveTo(middlePoint, duration: 0.4)
        approachCenter.timingMode = SKActionTimingMode.EaseOut
        
        var deleteNode:SKAction = SKAction.runBlock {
            plane.removeFromParent()
        }

        var sequence:SKAction = SKAction.sequence([approachPacMac, checkCollision, approachCenter, deleteNode])
        plane.runAction(sequence)
    }
    
    func doShare(score: Int) {
        let appName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleDisplayName") as? String
        let url = NSURL(string: "https://itunes.apple.com/us/app/pizza-slice/id931174800")
        let title = "I acheived the score \(score) in \(appName)"
        
        UIGraphicsBeginImageContext(self.view!.frame.size)
        self.view!.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        var itemsToShare = [AnyObject]()
        itemsToShare.append(image)
        itemsToShare.append(title)
        itemsToShare.append(url!)
        var activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeAssignToContact]
        //activityVC.completionWithItemsHandler = {// Google Tracker event  }()
        
        let rootVC = self.view!.window!.rootViewController
        rootVC?.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func colorForScore(score:Int) -> SKColor {
        switch score {
        case 0...9:
            return UIColor(red: 1, green: 1, blue: 0, alpha: 1)
        case 10...19:
            return SKColor.orangeColor()
        case 20...29:
            return SKColor.redColor()
        case 30...39:
            return SKColor.purpleColor()
        case 40...49:
            return SKColor.greenColor()
        case 50...59:
            return SKColor.blueColor()
        default:
            let tens = Int(score / 10)
            return UIColor(hue: CGFloat(tens), saturation: 1, brightness: 1, alpha: 1)
        }
    }

}
