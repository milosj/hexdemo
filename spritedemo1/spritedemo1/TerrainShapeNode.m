//
//  TerrainShapeNode.m
//  spritedemo1
//
//  Created by Milos Jovanovic on 2015-04-06.
//  Copyright (c) 2015 ca.cbc. All rights reserved.
//

#import "TerrainShapeNode.h"

@interface TerrainShapeNode()


@end

@implementation TerrainShapeNode

- (instancetype)init {
    self = [super init];
    
    if (self) {
    }
    
    return self;
}

- (void)setupInView:(SKView*)view {
//    UIBezierPath* testpath = [UIBezierPath new];
//    [testpath moveToPoint:CGPointMake(0, 0)];
//    [testpath addLineToPoint:CGPointMake(20, 90)];
//    [testpath addLineToPoint:CGPointMake(120, 300)];
//    [testpath addLineToPoint:CGPointMake(150, 310)];
//    [testpath addLineToPoint:CGPointMake(200, 260)];
//    [testpath addLineToPoint:CGPointMake(275, 255)];
//    [testpath addLineToPoint:CGPointMake(365, 160)];
//    [testpath addLineToPoint:CGPointMake(270, 80)];
//    [testpath addLineToPoint:CGPointMake(180, 10)];
//    [testpath closePath];
//    self.position = CGPointMake(160, 240);
//    self.polygon = testpath;
    self.zPosition = 100*self.height;
    //create a terrain-shaped node
    SKShapeNode* terrainShape = [SKShapeNode new];
    terrainShape.fillColor = [UIColor blackColor];
    terrainShape.strokeColor = [UIColor clearColor];
    terrainShape.path = [self.polygon CGPath];
    
    //use the terrain shaped node to create a texture mask
    SKTexture* mask = [view textureFromNode:terrainShape];
    SKSpriteNode* maskNode = [SKSpriteNode spriteNodeWithTexture:mask size:terrainShape.frame.size];
    maskNode.name = @"maskNode";
    maskNode.position = CGPointMake(CGRectGetMidX(terrainShape.frame), CGRectGetMidY(terrainShape.frame));
    
    SKCropNode* cropNode = [SKCropNode node];
    cropNode.maskNode = maskNode;
    cropNode.zPosition = self.zPosition;
    
    //load the actual texture and mask it
    SKTexture* paperTexture = [SKTexture textureWithImageNamed:@"paper1.jpg"];
    SKSpriteNode* textureNode = [SKSpriteNode spriteNodeWithTexture:paperTexture size:terrainShape.frame.size];
    textureNode.position = CGPointMake(CGRectGetMidX(terrainShape.frame), CGRectGetMidY(terrainShape.frame));
    textureNode.name = @"texture";
    [cropNode addChild:textureNode];
    [self addChild:cropNode];
    

    NSLog(@"terr %@  text %@ mask %@  crop %@", NSStringFromCGRect(terrainShape.frame), NSStringFromCGSize(mask.size), NSStringFromCGRect(maskNode.frame), NSStringFromCGRect(textureNode.frame));
    
    SKShapeNode* shadow = [terrainShape copy];
    shadow.name = @"shadow";
    shadow.zPosition = self.zPosition-10;
    shadow.alpha = 0.2f;

    shadow.position = CGPointMake(10, -10);
    [self addChild:shadow];

    SKShapeNode* outline = [SKShapeNode new];
    outline.name = @"outline";
    outline.fillColor = [SKColor clearColor];
    if (self.height == 0) {
        outline.strokeColor = [SKColor blackColor];
    } else if (self.height == 1) {
        outline.strokeColor = [SKColor darkGrayColor];
    } else if (self.height == 2) {
        outline.strokeColor = [SKColor lightGrayColor];
    } else if (self.height == 3) {
        outline.strokeColor = [SKColor whiteColor];
    } else {
        outline.strokeColor = [SKColor redColor];
    }
//    outline.fillColor = outline.strokeColor;
    outline.path = [self.polygon CGPath];
    outline.lineWidth = 10.0f;
    NSLog(@"outline %f, %f", outline.position.x, outline.position.y);
//    outline.position = CGPointMake(CGRectGetWidth(self.frame)/2,CGRectGetHeight(self.frame)/2);
//    outline.zPosition = self.zPosition+10;
    [self addChild:outline];
}

@end
