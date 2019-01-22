//
//  CZYIBLayoutDirectionManager.m
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/18.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import "CZYIBLayoutDirectionManager.h"
#import "CZYIBUtilities.h"

@implementation CZYIBLayoutDirectionManager

#pragma mark - life cycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - public

- (void)startObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

+ (CZYImageBrowserLayoutDirection)getLayoutDirectionByStatusBar {
    UIInterfaceOrientation obr = [UIApplication sharedApplication].statusBarOrientation;
    if ((obr == UIInterfaceOrientationPortrait) || (obr == UIInterfaceOrientationPortraitUpsideDown)) {
        return CZYImageBrowserLayoutDirectionVertical;
    } else if ((obr == UIInterfaceOrientationLandscapeLeft) || (obr == UIInterfaceOrientationLandscapeRight)) {
        return CZYImageBrowserLayoutDirectionHorizontal;
    } else {
        return CZYImageBrowserLayoutDirectionUnknown;
    }
}

#pragma mark - notification

- (void)applicationDidChangeStatusBarOrientationNotification:(NSNotification *)note {
    if (self.layoutDirectionChangedBlock) {
        self.layoutDirectionChangedBlock([self.class getLayoutDirectionByStatusBar]);
    }
}

@end
