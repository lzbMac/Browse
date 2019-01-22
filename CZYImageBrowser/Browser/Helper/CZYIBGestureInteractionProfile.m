//
//  CZYIBGestureInteractionProfile.m
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/21.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import "CZYIBGestureInteractionProfile.h"

@implementation CZYIBGestureInteractionProfile

- (instancetype)init {
    self = [super init];
    if (self) {
        self.disable = NO;
        self.dismissScale = 0.22;
        self.dismissVelocityY = 800;
        self.restoreDuration = 0.15;
        self.triggerDistance = 3;
    }
    return self;
}

@end
