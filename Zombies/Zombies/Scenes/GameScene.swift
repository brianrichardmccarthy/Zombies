//
//  GameScene.swift
//  Zombies
//
//  Created by Kieran Murphy on 06/12/2018.
//  Copyright © 2018 Kieran Murphy. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // MARK: - Instance Variables
    
    let playerSpeed: CGFloat = 150.0
    let zombieSpeed: CGFloat = 75.0
    
    var goal: SKSpriteNode?
    var player: SKSpriteNode?
    var zombies: [SKSpriteNode] = []
    
    var lastTouch: CGPoint? = nil
    
    override func didMove(to view: SKView) {
        
        // Set up physics world's contact delegate
        physicsWorld.contactDelegate = self
        
        // Set up initial camera position
        updateCamera()
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        handleTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        handleTouches(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        handleTouches(touches)
    }
    
    fileprivate func handleTouches(_ touches: Set<UITouch>) {
        lastTouch = touches.first?.location(in: self)
    }
    
    override func didSimulatePhysics() {
        if player != nil {
            updatePlayer()
            updateZombies()
        }
    }
    
    // Determines whether the player's position should be updated
    fileprivate func shouldMove(currentPosition: CGPoint,
                                touchPosition: CGPoint) -> Bool {
        guard let player = player else { return false }
        return abs(currentPosition.x - touchPosition.x) > player.frame.width / 2 ||
            abs(currentPosition.y - touchPosition.y) > player.frame.height / 2
    }
    
    fileprivate func updatePlayer() {
        guard let player = player,
            let touch = lastTouch
            else { return }
        let currentPosition = player.position
        if shouldMove(currentPosition: currentPosition,
                      touchPosition: touch) {
            updatePosition(for: player, to: touch, speed: playerSpeed)
            updateCamera()
        } else {
            player.physicsBody?.isResting = true
        }
    }
    
    fileprivate func updateCamera() {
        guard let player = player else { return }
        camera?.position = player.position
    }
    
    // Updates the position of all zombies by moving towards the player
    func updateZombies() {
        guard let player = player else { return }
        let targetPosition = player.position
        
        for zombie in zombies {
            updatePosition(for: zombie, to: targetPosition, speed: zombieSpeed)
        }
    }
    
    fileprivate func updatePosition(for sprite: SKSpriteNode,
                                    to target: CGPoint,
                                    speed: CGFloat) {
        let currentPosition = sprite.position
        let angle = CGFloat.pi + atan2(currentPosition.y - target.y,
                                       currentPosition.x - target.x)
        let rotateAction = SKAction.rotate(toAngle: angle + (CGFloat.pi*0.5),
                                           duration: 0)
        sprite.run(rotateAction)
        
        let velocityX = speed * cos(angle)
        let velocityY = speed * sin(angle)
        
        let newVelocity = CGVector(dx: velocityX, dy: velocityY)
        sprite.physicsBody?.velocity = newVelocity
    }
}

// MARK: - SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // 1. Create local variables for two physics bodies
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        // 2. Assign the two physics bodies so that the one with the
        // lower category is always stored in firstBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 3. react to the contact between the two nodes
        if firstBody.categoryBitMask == player?.physicsBody?.categoryBitMask &&
            secondBody.categoryBitMask == zombies[0].physicsBody?.categoryBitMask {
            // Player & Zombie
            gameOver(false)
        } else if firstBody.categoryBitMask == player?.physicsBody?.categoryBitMask &&
            secondBody.categoryBitMask == goal?.physicsBody?.categoryBitMask {
            // Player & Goal
            gameOver(true)
        }
    }
    
    // MARK: - Helper Functions
    
    fileprivate func gameOver(_ didWin: Bool) {
        let menuScene = MenuScene(size: size, didWin: didWin)
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        view?.presentScene(menuScene, transition: transition)
    }
}
