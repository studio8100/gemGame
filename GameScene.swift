//
//  GameScene.swift
//  DiveIntoSpriteKit
//
//  Created by Paul Hudson on 16/10/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import SpriteKit

@objcMembers
class GameScene: SKScene {
    
    var cols = [[Item]]()
    let itemSize: CGFloat = 50
    let itemsPerColumn = 12
    let itemsPerRow = 18
    
    var currentMatches = Set<Item>()
    
    override func didMove(to view: SKView) {
        // this method is called when your game scene is ready to run
        
        let background = SKSpriteNode(imageNamed: "wood")
        background.zPosition = -2
        addChild(background)
        
        for x in 0 ..< itemsPerRow {
            var col = [Item]()

            for y in 0 ..< itemsPerColumn {
                let item = createItem(row: y, col: x)
                col.append(item)
            }

            cols.append(col)
        }


    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user touches the screen
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        guard let tappedItem = item(at: location) else { return }

        //1218
        isUserInteractionEnabled = false
        
        currentMatches.removeAll()
        
        if tappedItem.name == "bomb" {
                    triggerSpecialItem(tappedItem)
                }
        
        
        match(item: tappedItem)
        removeMatches()
        moveDown()

    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user stops touching the screen
    }

    override func update(_ currentTime: TimeInterval) {
        // this method is called before each frame is rendered
    }
    func position(for item: Item) -> CGPoint {
        let xOffset: CGFloat = -430
        let yOffset: CGFloat = -300

        let x = xOffset + itemSize * CGFloat(item.col)
        let y = yOffset + itemSize * CGFloat(item.row)
        return CGPoint(x: x, y: y)
    }
    
    func createItem(row: Int, col: Int, startOffScreen: Bool = false) -> Item {
//        let itemImages = ["shape-circle", "shape-diamond", "shape-heart", "shape-pentagon", "shape-square", "shape-star", "shape-triangle"]
//        let itemImage = itemImages.randomElement()!
        //1218
        let itemImage: String
        if startOffScreen && Int.random(in: 0...24) == 0 {
            itemImage = "bomb"
        } else {
            let itemImages = ["shape-circle", "shape-diamond", "shape-heart", "shape-pentagon", "shape-square", "shape-star", "shape-triangle"]
                itemImage = itemImages.randomElement()!
        }
        
        
        let item = Item(imageNamed: itemImage)
        item.name = itemImage
        item.row = row
        item.col = col
        
        //item.position = position(for: item)
        //1218
        if startOffScreen {
            let finalPosition = position(for: item)
            
            item.position = finalPosition
            item.position.y += 600
            
            let action = SKAction.move(to: finalPosition, duration: 0.4)
            
            item.run(action) {
                self.isUserInteractionEnabled = true
            }
        } else {
            item.position = position(for: item)
        }
        
        addChild(item)
        return item
        }

    
    func item(at point: CGPoint) -> Item? {
        let items = nodes(at: point).compactMap { $0 as? Item }
        return items.first
    }
    
    
    func match(item original: Item) {
        var checkItems = [Item?]()

        currentMatches.insert(original)
        let pos = original.position

        checkItems.append(item(at: CGPoint(x: pos.x, y: pos.y - itemSize)))
        checkItems.append(item(at: CGPoint(x: pos.x, y: pos.y + itemSize)))
        checkItems.append(item(at: CGPoint(x: pos.x - itemSize, y: pos.y)))
        checkItems.append(item(at: CGPoint(x: pos.x + itemSize, y: pos.y)))

        for case let check? in checkItems {
            if currentMatches.contains(check) { continue }

            if check.name == original.name || original.name == "bomb" {
                match(item: check)
            }
        }
    }
    
    func removeMatches() {
        let  sortedMatches = currentMatches.sorted {
            $0.row > $1.row
        }
        
        for item in sortedMatches {
            cols[item.col].remove(at: item.row)
            item.removeFromParent()
        }
        
        
//        for item in currentMatches {
//            item.removeFromParent()
//        }
    }
    
    //1218
    func moveDown() {
        for(columnIndex, col) in cols.enumerated() {
            for (rowIndex, item) in col.enumerated() {
                item.row = rowIndex
                
                let action = SKAction.move(to: position(for: item), duration: 0.1)
                item.run(action)
            }
            
            while cols[columnIndex].count < itemsPerColumn {
                let item = createItem(row: cols[columnIndex].count, col: columnIndex, startOffScreen: true)
                cols[columnIndex].append(item)
                
            }
            
        }
    }
    
    func triggerSpecialItem(_ item: Item){
       
    }

}

