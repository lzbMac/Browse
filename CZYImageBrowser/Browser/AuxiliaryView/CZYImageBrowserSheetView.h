//
//  CZYImageBrowserSheetView.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/22.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZYImageBrowserSheetViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString * const kCZYImageBrowserSheetActionIdentitySaveToPhotoAlbum;

typedef void(^CZYImageBrowserSheetActionBlock)(id<CZYImageBrowserCellDataProtocol> data);

@interface CZYImageBrowserSheetAction : NSObject

/** The name of 'action' */
@property (nonatomic, copy) NSString *name;

/**
 如果 'identity' 设置为 'kCZYImageBrowserSheetActionIdentitySaveToPhotoAlbum', 会自动保存图片，不走回调.
 */
@property (nonatomic, copy, nullable) NSString *identity;

/** Callback. */
@property (nonatomic, copy, nullable) CZYImageBrowserSheetActionBlock action;

+ (instancetype)actionWithName:(NSString *)name identity:(NSString * _Nullable)identity action:(_Nullable CZYImageBrowserSheetActionBlock)action;

@end

@interface CZYImageBrowserSheetView : UIView<CZYImageBrowserSheetViewProtocol>

/** 数组count不许大于等于 1 */
@property (nonatomic, copy) NSArray<CZYImageBrowserSheetAction *> *actions;

@property (nonatomic, assign) CGFloat heightOfCell;

@property (nonatomic, copy) NSString *cancelText;

@property (nonatomic, assign) CGFloat maxHeightScale;

@property (nonatomic, assign) NSTimeInterval animateDuration;


@end

NS_ASSUME_NONNULL_END
