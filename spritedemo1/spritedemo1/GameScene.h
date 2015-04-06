//
//  GameScene.h
//  spritedemo1
//

//  Copyright (c) 2015 ca.cbc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class HexNode, Map, ArrowNode;

@interface GameScene : SKScene

@property (strong, nonatomic) SKNode* rootNode;
@property (strong, nonatomic) HexNode* selectedNode;
@property (assign, nonatomic) CGPoint target;
@property (strong, nonatomic) ArrowNode* arrow;
@property (strong, nonatomic) HexNode* selectionHex;

@property (strong, nonatomic) Map* map;

@property (strong, nonatomic) NSMutableArray* arrowPath;


+ (CGPoint)gamePositionForCoordinates:(CGPoint)coordinates;
+ (CGPoint)coordinatesForGamePositionX:(int)x andY:(int)y;

@end
