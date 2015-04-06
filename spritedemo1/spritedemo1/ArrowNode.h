//
//  ArrowNode.h
//  spritedemo1
//
//  Created by Milos Jovanovic on 2015-04-03.
//  Copyright (c) 2015 ca.cbc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class DSMultilineLabelNode;

@interface ArrowNode : SKShapeNode

@property (assign, nonatomic) CGFloat thickness;    //final thickness of the arrow stem
@property (assign, nonatomic) CGFloat arrowheadScale; //width of the arrowhead scaled from thickness
@property (assign, nonatomic) CGFloat minThicknessScale; //starting thickness of the arrow, scaled from thickness

- (void)setArrowPath:(NSArray*)path;

@end
