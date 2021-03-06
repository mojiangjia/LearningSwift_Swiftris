//
//  GameScene.swift
//  Swiftris
//
//  Created by MoJ on 5/26/17.
//  Copyright © 2017 MoJ. All rights reserved.
//

import SpriteKit
import GameplayKit

// s or ms?
let TickLengthLevelOne = TimeInterval(600)

// Point size of each block sprite, in our case 20.0 x 20.0
let BlockSize: CGFloat = 20.0

class GameScene: SKScene {
    
    let gameLayer = SKNode()
    let shapeLayer = SKNode()
    //  Layer position which will give us an offset from the edge of the screen
    let LayerPosition = CGPoint(x: 6, y: -6)
    
    var tick : (() -> ())?
    var tickLengthMillis = TickLengthLevelOne
    var lastTick : NSDate?
    
    var textureCache = Dictionary<String, SKTexture>()
    
//    private var label : SKLabelNode?
//    private var spinnyNode : SKShapeNode?
    
//    override func didMove(to view: SKView) {
//        
//        // Get label node from scene and store it for use later
//        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
//        if let label = self.label {
//            label.alpha = 0.0
//            label.run(SKAction.fadeIn(withDuration: 2.0))
//        }
//        
//        // Create shape node to use during mouse interaction
//        let w = (self.size.width + self.size.height) * 0.05
//        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
//        
//        if let spinnyNode = self.spinnyNode {
//            spinnyNode.lineWidth = 2.5
//            
//            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
//            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                              SKAction.fadeOut(withDuration: 0.5),
//                                              SKAction.removeFromParent()]))
//        }
//    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0, y: 1.0)
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = CGPoint(x: 0, y: 1.0)
        
        addChild(background)
        addChild(gameLayer)
        
        let gameBoardTexture = SKTexture(imageNamed: "gameboard")
        let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSize(width: BlockSize * CGFloat(NumColumns), height: BlockSize * CGFloat(NumRows)))
        gameBoard.anchorPoint = CGPoint(x:0, y:1.0)
        gameBoard.position = LayerPosition

        shapeLayer.position = LayerPosition
        shapeLayer.addChild(gameBoard)
        gameLayer.addChild(shapeLayer)
        
        // don't need to add Sounds/theme.mp3
        run(SKAction.repeatForever(SKAction.playSoundFileNamed("theme.mp3", waitForCompletion: true)))
    }
    
    func playSound(sound: String) {
        run(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        guard let lastTick = lastTick else {
            return
        }
        let timePassed = lastTick.timeIntervalSinceNow * -1000.0
        if timePassed > tickLengthMillis {
            self.lastTick = NSDate()
            tick?()
            // shorthand
//            if tick != nil {
//                tick!()
//            }
        }
    }
    
    func startTicking() {
        lastTick = NSDate()
    }
    
    func stopTicking() {
        lastTick = nil
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        let x = LayerPosition.x + (CGFloat(column) * BlockSize) + (BlockSize / 2)
        let y = LayerPosition.y - ((CGFloat(row) * BlockSize) + (BlockSize / 2))
        return CGPoint(x: x, y: y)
    }
    
    func addPreviewShapeToScene(shape: Shape, completion: @escaping () -> ()) {
        for block in shape.blocks {
            var texture = textureCache[block.spriteName]
            if texture == nil {
                texture = SKTexture(imageNamed: block.spriteName)
                textureCache[block.spriteName] = texture
            }
            let sprite = SKSpriteNode(texture: texture)
            // start it at row - 2, such that the preview piece animates smoothly into place from a higher location.
            sprite.position = pointForColumn(column: block.column, row: block.row - 2)
            shapeLayer.addChild(sprite)
            block.sprite = sprite
            
            // Animation
            sprite.alpha = 0
            
            let moveToAction = SKAction.move(to: pointForColumn(column: block.column, row: block.row), duration: TimeInterval(0.2))
            moveToAction.timingMode = .easeOut
            let fadeInAction = SKAction.fadeAlpha(to: 0.7, duration: 0.4)
            fadeInAction.timingMode = .easeOut
            sprite.run(SKAction.group([moveToAction, fadeInAction]))
        
        }
        run(SKAction.wait(forDuration: 0.4), completion: completion)
    }
    
    
    func movePreviewShape(shape:Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(column: block.column, row:block.row)
            let moveToAction:SKAction = SKAction.move(to: moveTo, duration: 0.2)
            moveToAction.timingMode = .easeOut
            sprite.run(
                SKAction.group([moveToAction, SKAction.fadeAlpha(to: 1.0, duration: 0.2)]), completion: {})
        }
        run(SKAction.wait(forDuration: 0.2), completion: completion)
    }
    
    func redrawShape(shape:Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(column: block.column, row:block.row)
            let moveToAction = SKAction.move(to: moveTo, duration: 0.05)
            moveToAction.timingMode = .easeOut
            if block == shape.blocks.last {
                sprite.run(moveToAction, completion: completion)
            } else {
                sprite.run(moveToAction)
            }
        }
    }
    
    func animateCollapsingLines(linesToRemove: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>, completion:@escaping () -> ()) {
        // determine precisely how long we should wait before calling the completion closure
        var longestDuration: TimeInterval = 0
        
        
        for (columnIdx, column) in fallenBlocks.enumerated() {
            for (blockIdx, block) in column.enumerated() {
                // newPosition is the final position to settle
                let newPosition = pointForColumn(column: block.column, row: block.row)
                // original position: display position on the scence
                let sprite = block.sprite!
                
                let delay = (TimeInterval(columnIdx) * 0.05) + (TimeInterval(blockIdx) * 0.05)
                
                let duration = TimeInterval(((sprite.position.y - newPosition.y) / BlockSize) * 0.1)
                
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.run(SKAction.sequence([SKAction.wait(forDuration: delay), moveAction]))
                longestDuration = max(longestDuration, duration + delay)
            }
        }
        
        for rowToRemove in linesToRemove {
            for block in rowToRemove {
                let randomRadius = CGFloat(UInt(arc4random_uniform(400) + 100))
                let goLeft = arc4random_uniform(100) % 2 == 0
                
                var point = pointForColumn(column: block.column, row: block.row)
                
                point = CGPoint(x: point.x + (goLeft ? -randomRadius : randomRadius), y: point.y)
                
                let randomDuration = TimeInterval(arc4random_uniform(2)) + 0.5
                
                var startAngle = CGFloat(Double.pi)
                var endAngle = startAngle * 2
                if goLeft {
                    endAngle = startAngle
                    startAngle = 0
                }
                
                let archPath = UIBezierPath(arcCenter: point, radius: randomRadius, startAngle: startAngle, endAngle: endAngle, clockwise: goLeft)
                
                let archAction = SKAction.follow(archPath.cgPath, asOffset: false, orientToPath: true, duration: randomDuration)
                
                archAction.timingMode = .easeIn
                
                let sprite = block.sprite!
                
                /* place the block sprite above the others such that they animate above the other blocks 
                and begin the sequence of actions which concludes with removing the sprite from the scene.*/
                sprite.zPosition = 100
                
                sprite.run(SKAction.sequence([SKAction.group([archAction, SKAction.fadeOut(withDuration: TimeInterval(randomDuration))]), SKAction.removeFromParent()]))
            }
        }
        
        // run the completion action after a duration matching the time it will take to drop the last block to its new resting place
        run(SKAction.wait(forDuration: longestDuration), completion: completion)
    }
}
