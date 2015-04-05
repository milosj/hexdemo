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


@property (strong, nonatomic) UILabel* label;

@property (assign, nonatomic) CGFloat thickness;
@property (assign, nonatomic) CGFloat arrowheadScale;

- (void)setArrowPath:(NSArray*)path;

@end
