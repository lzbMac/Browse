//
//  CZYIBLayoutDirectionManager.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/18.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CZYImageBrowserLayoutDirection) {
    CZYImageBrowserLayoutDirectionUnknown,
    CZYImageBrowserLayoutDirectionVertical,
    CZYImageBrowserLayoutDirectionHorizontal
};

NS_ASSUME_NONNULL_BEGIN

@interface CZYIBLayoutDirectionManager : NSObject

- (void)startObserve;

@property (nonatomic, copy) void(^layoutDirectionChangedBlock)(CZYImageBrowserLayoutDirection);

+ (CZYImageBrowserLayoutDirection)getLayoutDirectionByStatusBar;

@end

NS_ASSUME_NONNULL_END
