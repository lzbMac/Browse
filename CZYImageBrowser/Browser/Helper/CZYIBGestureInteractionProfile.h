//
//  CZYIBGestureInteractionProfile.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/21.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZYIBGestureInteractionProfile : NSObject
/**
 是否禁止手势
 */
@property (nonatomic, assign) BOOL disable;

@property (nonatomic, assign) CGFloat dismissScale;

@property (nonatomic, assign) CGFloat dismissVelocityY;

@property (nonatomic, assign) CGFloat restoreDuration;

@property (nonatomic, assign) CGFloat triggerDistance;

@end

NS_ASSUME_NONNULL_END
