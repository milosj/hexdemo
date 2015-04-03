//
//  GameScene.h
//  spritedemo1
//

//  Copyright (c) 2015 ca.cbc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class HexNode;

@interface GameScene : SKScene

@property (strong, nonatomic) SKNode* rootNode;
@property (strong, nonatomic) SKNode* selectedNode;
@property (assign, nonatomic) CGPoint target;
@property (strong, nonatomic) SKShapeNode* arrow;
@property (strong, nonatomic) HexNode* selectionHex;
@end
