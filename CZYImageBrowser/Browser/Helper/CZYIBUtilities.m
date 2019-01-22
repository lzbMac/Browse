//
//  CZYIBUtilities.m
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/18.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import "CZYIBUtilities.h"
#import <sys/utsname.h>

UIWindow *CZYIBGetNormalWindow(void) {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow *temp in windows) {
            window = temp; break;
        }
    }
    return window;
}

UIViewController *CZYIBGetTopController(void) {
    UIViewController *topController = nil;
    UIWindow *window = CZYIBGetNormalWindow();
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:UIViewController.class]) {
        topController = nextResponder;
    } else {
        topController = window.rootViewController;
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
    }
    return topController;
}

@implementation CZYIBUtilities
+ (BOOL)isIphoneX {
    static BOOL isIphoneX = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSSet *platformSet = [NSSet setWithObjects:@"iPhone10,3", @"iPhone10,6", @"iPhone11,8", @"iPhone11,2", @"iPhone11,4", @"iPhone11,6", nil];
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        if ([platform isEqualToString:@"x86_64"] || [platform isEqualToString:@"i386"]) {
            platform = NSProcessInfo.processInfo.environment[@"SIMULATOR_MODEL_IDENTIFIER"];
        }
        isIphoneX = [platformSet containsObject:platform];
    });
    return isIphoneX;
}

+ (void)countTimeConsumingOfCode:(void(^)(void))code {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    code?code():nil;
    CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
    CZYIBLOG(@"TimeConsuming: %f ms", linkTime *1000.0);
}

@end
