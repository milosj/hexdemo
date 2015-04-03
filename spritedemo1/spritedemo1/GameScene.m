//
//  GameScene.m
//  spritedemo1
//
//  Created by Milos Jovanovic on 2015-04-02.
//  Copyright (c) 2015 ca.cbc. All rights reserved.
//

#import "GameScene.h"
#import "HexNode.h"

@import CoreGraphics;

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    
    self.rootNode = [SKNode node];
    self.rootNode.position = CGPointMake(0, 0);
    [self addChild:self.rootNode];

    self.arrow = [SKShapeNode node];
    self.arrow.position = self.rootNode.position;
    self.arrow.lineWidth = 5.0;
    self.arrow.lineCap = kCGLineCapButt;
    self.arrow.strokeColor = [SKColor redColor];
    [self addChild:self.arrow];
    
//    for (int x = 0; x < 20; x++) {
//        for (int y = 0; y < 20; y++) {
    int x = 5;
    int y = 5;
            HexNode* hex = [HexNode new];
            hex.name = @"HEX";
            hex.position = [self coordinatesForGamePositionX:x andY:y];
            if (y % 2 == 0) {
                hex.hexShapeNode.fillColor = [SKColor redColor];
            }
            [self.rootNode addChild:hex];
            
//        }
//    }
    
    self.selectionHex = [HexNode new];
    self.selectionHex.hexShapeNode.fillColor = [SKColor clearColor];
    self.selectionHex.hexShapeNode.strokeColor = [SKColor redColor];
    self.selectionHex.hidden = YES;
    [self.rootNode addChild:self.selectionHex];
}

- (CGPoint)coordinatesForGamePositionX:(int)x andY:(int)y {
    if ((y % 2) == 0) {
        return CGPointMake(x*HEX_W, 0.75*y*HEX_H);
    } else {
        return CGPointMake((x-0.5f)*HEX_W, 0.75*y*HEX_H);
    }
}

- (CGPoint)gamePositionForCoordinates:(CGPoint)coordinates {
    CGPoint pos1 = CGPointMake((int)(coordinates.x/HEX_W), (int)(coordinates.y/(0.75*HEX_H)));
    if (((int)pos1.y) % 2 == 0) {
        return pos1;
    } else {
        return CGPointMake((int)((coordinates.x+HEX_W/2)/HEX_W), pos1.y);
    }

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    SKNode* node = [self.rootNode nodeAtPoint:location];
    if (node && node != self.rootNode) {
        if (![node isKindOfClass:[HexNode class]]) {
            node = [node parent];
        }
        self.selectedNode = node;
    }
    self.target = location;
//        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
//        
//        [sprite runAction:[SKAction repeatActionForever:action]];
//        
//        [self addChild:sprite];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.selectedNode) {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:self];
        
        self.target = location;
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        self.arrow.position = CGPointMake(0, 0);
        CGRect frame = [self.selectedNode calculateAccumulatedFrame];
        CGPoint startPoint = CGPointMake(self.selectedNode.position.x+frame.size.width/2, self.selectedNode.position.y+frame.size.height/2);
        [bezierPath moveToPoint:startPoint];
        CGPoint gpos = [self gamePositionForCoordinates:location];
        CGPoint wpos = [self coordinatesForGamePositionX:gpos.x andY:gpos.y];
        [bezierPath addLineToPoint:location];
        NSLog(@"(%f,%f)->(%f,%f)->(%f,%f) (%f,%f)", location.x, location.y, gpos.x, gpos.y, wpos.x, wpos.y, self.selectedNode.position.x,self.selectedNode.position.y);
        self.arrow.path = [bezierPath CGPath];
        
        self.selectionHex.position = wpos;
        self.selectionHex.hidden = NO;

    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    if ([self.rootNode nodeAtPoint:location] == self.selectedNode) {
        
    }

    

    self.arrow.path = NULL;
    self.selectedNode = nil;
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
