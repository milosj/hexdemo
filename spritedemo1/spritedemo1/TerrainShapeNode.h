//
//  TerrainShapeNode.h
//  spritedemo1
//
//  Created by Milos Jovanovic on 2015-04-06.
//  Copyright (c) 2015 ca.cbc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface TerrainShapeNode : SKNode

@property (assign, nonatomic) int height;
@property (strong, nonatomic) UIBezierPath* polygon;

- (void)setupInView:(SKView*)view;

@end
