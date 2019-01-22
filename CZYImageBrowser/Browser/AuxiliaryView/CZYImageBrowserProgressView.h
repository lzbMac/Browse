//
//  CZYImageBrowserProgressView.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/17.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CZYImageBrowserProgressView;

@interface UIView (CZYImageBrowserProgressView)

- (void)czy_showProgressViewWithValue:(CGFloat)progress;

- (void)czy_showProgressViewLoading;

- (void)czy_showProgressViewWithText:(NSString *)text click:(nullable void(^)(void))click;

- (void)czy_hideProgressView;

@property (nonatomic, strong, readonly) CZYImageBrowserProgressView *czy_progressView;

@end


@interface CZYImageBrowserProgressView : UIView

- (void)showProgress:(CGFloat)progress;

- (void)showLoading;

- (void)showText:(NSString *)text click:(void(^)(void))click;

@end

NS_ASSUME_NONNULL_END
