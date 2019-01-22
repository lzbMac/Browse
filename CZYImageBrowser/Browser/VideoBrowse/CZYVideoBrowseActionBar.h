//
//  CZYVideoBrowseActionBar.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/22.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CZYVideoBrowseActionBar;

@protocol CZYVideoBrowseActionBarDelegate <NSObject>

- (void)czy_videoBrowseActionBar:(CZYVideoBrowseActionBar *)actionBar clickPlayButton:(UIButton *)playButton;
- (void)czy_videoBrowseActionBar:(CZYVideoBrowseActionBar *)actionBar clickPauseButton:(UIButton *)pauseButton;
- (void)czy_videoBrowseActionBar:(CZYVideoBrowseActionBar *)actionBar changeValue:(float)value;

@end

@interface CZYVideoBrowseActionBar : UIView

@property (nonatomic, weak) id<CZYVideoBrowseActionBarDelegate> delegate;

- (CGRect)getFrameWithContainerSize:(CGSize)containerSize;

- (void)pause;
- (void)play;

- (void)setMaxValue:(float)value;
- (void)setCurrentValue:(float)value;

@end

NS_ASSUME_NONNULL_END
