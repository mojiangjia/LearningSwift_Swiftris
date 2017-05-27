//
//  GameViewController.swift
//  Swiftris
//
//  Created by MoJ on 5/26/17.
//  Copyright © 2017 MoJ. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var scene: GameScene!
    var swiftris: Swiftris!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        // Create and configure the scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        scene.tick = didTick

        swiftris = Swiftris()
        swiftris.beginGame()
        
        // Present the scene
        skView.presentScene(scene)
        
        // add nextShape to the game layer at the preview location
        // Remember the closure completion
        scene.addPreviewShapeToScene(shape: swiftris.nextShape!) {
            self.swiftris.nextShape?.moveTo(column: StartingColumn, row: StartingRow)
            self.scene.movePreviewShape(shape: self.swiftris.nextShape!) {
                let nextShapes = self.swiftris.newShape()
                self.scene.startTicking()
                self.scene.addPreviewShapeToScene(shape: nextShapes.nextShape!) {}
            }
        }
        
//        if let view = self.view as! SKView? {
//            // Load the SKScene from 'GameScene.sks'
//            if let scene = SKScene(fileNamed: "GameScene") {
//                // Set the scale mode to scale to fit the window
//                scene.scaleMode = .aspectFill
//                
//                // Present the scene
//                view.presentScene(scene)
//            }
//            
//            view.ignoresSiblingOrder = true
//            
//            view.showsFPS = true
//            view.showsNodeCount = true
//        }
    }

//    override var shouldAutorotate: Bool {
//        return true
//    }
//
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        if UIDevice.current.userInterfaceIdiom == .phone {
//            return .allButUpsideDown
//        } else {
//            return .all
//        }
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Release any cached data, images, etc that aren't in use.
//    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // lower the falling shape by one row and then asks GameScene to redraw the shape at its new location
    func didTick() {
        swiftris.fallingShape?.lowerShapeByOneRow()
        scene.redrawShape(shape: swiftris.fallingShape!, completion: {})
    }
}
