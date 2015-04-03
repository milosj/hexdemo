//
//  HexNode.m
//  spritedemo1
//
//  Created by Milos Jovanovic on 2015-04-02.
//  Copyright (c) 2015 ca.cbc. All rights reserved.
//

#import "HexNode.h"


@implementation HexNode

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.hexShapeNode = [[SKShapeNode alloc] init];
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPoint newloc = CGPointMake(0, 0);

        CGPathMoveToPoint(path, NULL, newloc.x + HEX_W/2, newloc.y + HEX_H/4);
        CGPathAddLineToPoint(path, NULL, newloc.x + 0, newloc.y + HEX_H/2);
        CGPathAddLineToPoint(path, NULL, newloc.x - HEX_W/2, newloc.y + HEX_H/4);
        CGPathAddLineToPoint(path, NULL, newloc.x - HEX_W/2, newloc.y - HEX_H/4);
        CGPathAddLineToPoint(path, NULL, newloc.x + 0, newloc.y - HEX_H/2);
        CGPathAddLineToPoint(path, NULL, newloc.x + HEX_W/2, newloc.y - HEX_H/4);
//        CGPathMoveToPoint(path, NULL, newloc.x, newloc.y);
//        CGPathAddLineToPoint(path, NULL, newloc.x+HEX_W/2, newloc.y+HEX_H/2);
//        CGPathAddLineToPoint(path, NULL, newloc.x+HEX_W/2, newloc.y-HEX_H/2);
//        CGPathAddLineToPoint(path, NULL, newloc.x-HEX_W/2, newloc.y-HEX_H/2);
//        CGPathAddLineToPoint(path, NULL, newloc.x-HEX_W/2, newloc.y+HEX_H/2);
        
        CGPathCloseSubpath(path);
        self.hexShapeNode.path = path;
        
        self.hexShapeNode.lineWidth = 1.0;
        self.hexShapeNode.fillColor = [SKColor blueColor];
        self.hexShapeNode.strokeColor = [SKColor whiteColor];
        self.hexShapeNode.glowWidth = 0.5;
        self.hexShapeNode.position = CGPointMake(HEX_W/2, HEX_H/2);
        [self addChild:self.hexShapeNode];
    }
    
    return self;
}

- (CGPoint)center {
    return CGPointMake(self.position.x + self.frame.size.width/2, self.position.y + self.frame.size.height/2);
}

@end
