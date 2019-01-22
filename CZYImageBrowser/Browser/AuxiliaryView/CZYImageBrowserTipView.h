//
//  CZYImageBrowserTipView.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/17.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CZYImageBrowserTipType) {
    CZYImageBrowserTipTypeNone,
    CZYImageBrowserTipTypeHook,
    CZYImageBrowserTipTypeFork
};

@class CZYImageBrowserTipView;

@interface UIView (CZYImageBrowserTipView)

- (void)czy_showHookTipView:(NSString *)text;

- (void)czy_showForkTipView:(NSString *)text;

- (void)czy_hideTipView;

@property (nonatomic, strong, readonly) CZYImageBrowserTipView *czy_tipView;


@end

NS_ASSUME_NONNULL_BEGIN

@interface CZYImageBrowserTipView : UIView

- (void)startAnimationWithText:(NSString *)text type:(CZYImageBrowserTipType)tipType;

@end

NS_ASSUME_NONNULL_END
