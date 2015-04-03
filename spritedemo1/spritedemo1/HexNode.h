//
//  HexNode.h
//  spritedemo1
//
//  Created by Milos Jovanovic on 2015-04-02.
//  Copyright (c) 2015 ca.cbc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#define HEX_W 80
#define HEX_H 92


@interface HexNode : SKNode

@property (strong, nonatomic) SKShapeNode* hexShapeNode;
@property (readonly, nonatomic) CGPoint center;

@end
