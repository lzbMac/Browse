//
//  CZYIBTransitionManager.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/21.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CZYImageBrowser.h"

NS_ASSUME_NONNULL_BEGIN

@interface CZYIBTransitionManager : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, weak) CZYImageBrowser *imageBrowser;

@property (nonatomic, assign, readonly) BOOL isTransitioning;


@end

NS_ASSUME_NONNULL_END
