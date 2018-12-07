//
//  MenuScene.swift
//  Zombies
//
//  Created by Kieran Murphy on 06/12/2018.
//  Copyright © 2018 Kieran Murphy. All rights reserved.
//


import SpriteKit

class MenuScene: SKScene {
    var didWin: Bool
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    init(size: CGSize, didWin: Bool) {
        self.didWin = didWin
        super.init(size: size)
        scaleMode = .aspectFill
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(white: 0, alpha: 1)
        
        // Set up labels
        let text = didWin ? "You Won!!!" : "You lost :["
        let winLabel = SKLabelNode(text: text)
        winLabel.fontName = "AvenirNext-Bold"
        winLabel.fontSize = 65
        winLabel.fontColor = .white
        winLabel.position = CGPoint(x: frame.midX, y: frame.midY*1.5)
        addChild(winLabel)
        
        let label = SKLabelNode(text: "Press anywhere to play again!")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 55
        label.fontColor = .white
        label.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(label)
        
        // Play sound
        let soundToPlay = didWin ? "fear_win.mp3" : "fear_lose.mp3"
        run(SKAction.playSoundFileNamed(soundToPlay, waitForCompletion: false))
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let gameScene = GameScene(fileNamed: "GameScene") else {
            fatalError("GameScene not found")
        }
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        gameScene.scaleMode = .aspectFill
        view?.presentScene(gameScene, transition: transition)
    }
}

