//
//  CZYVideoBrowseTopBar.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/22.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CZYVideoBrowseTopBar;

@protocol CZYVideoBrowseTopBarDelegate <NSObject>

- (void)czy_videoBrowseTopBar:(CZYVideoBrowseTopBar *)topBar clickCancelButton:(UIButton *)button;

@end

@interface CZYVideoBrowseTopBar : UIView

@property (nonatomic, weak) id<CZYVideoBrowseTopBarDelegate> delegate;

- (CGRect)getFrameWithContainerSize:(CGSize)containerSize;

@end

NS_ASSUME_NONNULL_END
