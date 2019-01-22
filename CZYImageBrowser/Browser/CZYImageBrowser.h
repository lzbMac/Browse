//
//  CZYImageBrowser.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/17.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZYImageBrowserDataSource.h"
#import "CZYImageBrowserDelegate.h"
#import "CZYImageBrowseCellData.h"
#import "CZYVideoBrowseCellData.h"
#import "CZYIBGestureInteractionProfile.h"
#import "CZYImageBrowserToolBarProtocol.h"
#import "CZYImageBrowserSheetViewProtocol.h"
#import "CZYImageBrowserToolBar.h"
#import "CZYImageBrowserSheetView.h"

typedef NS_ENUM(NSInteger, CZYImageBrowserTransitionType) {
    CZYImageBrowserTransitionTypeNone,
    CZYImageBrowserTransitionTypeFade,
    CZYImageBrowserTransitionTypeCoherent
};

NS_ASSUME_NONNULL_BEGIN

@interface CZYImageBrowser : UIViewController
/**
 数据源数组，数组元素类型可以为'CZYImageBrowseCellData', 'CZYVideoBrowseCellData'.
 */
@property (nonatomic, copy) NSArray<id<CZYImageBrowserCellDataProtocol>> *dataSourceArray;
/**
 数据源代理
 */
@property (nonatomic, weak) id<CZYImageBrowserDataSource> dataSource;
/**
 回调代理
 */
@property (nonatomic, weak) id<CZYImageBrowserDelegate> delegate;

/**
 当前idnex
 */
@property (nonatomic, assign) NSUInteger currentIndex;

/**
 展示
 */
- (void)show;

/**
 在目标vc下展示

 @param fromController presnettingvc
 */
- (void)showFromController:(UIViewController *)fromController;

/**
 隐藏
 */
- (void)hide;

/**
 刷新数据
 */
- (void)reloadData;

/**
 当前预览的数据

 @return 当前预览的数据
 */
- (id<CZYImageBrowserCellDataProtocol>)currentData;

/**
 默认YES
 */
@property (nonatomic, assign) BOOL shouldPreload;

/**
 默认 'UIInterfaceOrientationMaskAllButUpsideDown'.
 */
@property (nonatomic, assign) UIInterfaceOrientationMask supportedOrientations;

/**
 默认 20.
 */
@property (nonatomic, assign) CGFloat distanceBetweenPages;

/**
 默认黑色.
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/**
 自动隐藏 'SourceObject'. 'SourceObject'的说明见 'CZYImageBrowseCellData' 或 'CZYVideoBrowseCellData'的头文件
 */
@property (nonatomic, assign) BOOL autoHideSourceObject;

/**
 默认值 'CZYImageBrowserTransitionTypeCoherent'.
 */
@property (nonatomic, assign) CZYImageBrowserTransitionType enterTransitionType;

/**
 默认值 'CZYImageBrowserTransitionTypeCoherent'.
 */
@property (nonatomic, assign) CZYImageBrowserTransitionType outTransitionType;

/**
 默认值 0.25.
 */
@property (nonatomic, assign) NSTimeInterval transitionDuration;

/**
 手势动画参数配置
 */
@property (nonatomic, strong) CZYIBGestureInteractionProfile *giProfile;


/**
 默认的toolBar，可自行配置参数
 */
@property (nonatomic, weak, readonly) CZYImageBrowserToolBar *defaultToolBar;

/**
 该数组包含'defaultToolBar'和自定义的toolBar，无需关心toolBars的排列方式，只需根据协议更新其UI
 */
@property (nonatomic, copy) NSArray<__kindof UIView<CZYImageBrowserToolBarProtocol> *> *toolBars;

/**
 默认 'sheetView'， 可惜性配置一些参数
 */
@property (nonatomic, weak, readonly) CZYImageBrowserSheetView *defaultSheetView;

/**
 默认为'defaultSheetView'或者自定义的toolBar，无需关心sheetView的排列方式，只需根据协议更新其UI
 */
@property (nonatomic, strong) __kindof UIView<CZYImageBrowserSheetViewProtocol> *sheetView;

/**
 默认为 YES.
 */
@property (nonatomic, assign) BOOL shouldHideStatusBar;

/**
 数据内存限制，默认为6
 */
@property (nonatomic, assign) NSUInteger dataCacheCountLimit;

@end

NS_ASSUME_NONNULL_END
