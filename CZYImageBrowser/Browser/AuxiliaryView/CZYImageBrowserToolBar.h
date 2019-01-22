//
//  CZYImageBrowserToolBar.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/21.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZYImageBrowserToolBarProtocol.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, CZYImageBrowserToolBarOperationType) {
    CZYImageBrowserToolBarOperationTypeSave,
    CZYImageBrowserToolBarOperationTypeMore,
    CZYImageBrowserToolBarOperationTypeCustom
};

typedef void(^CZYImageBrowserToolBarOperationBlock)(id<CZYImageBrowserCellDataProtocol> data);

@interface CZYImageBrowserToolBar : UIView<CZYImageBrowserToolBarProtocol>
@property (nonatomic, strong, readonly) CAGradientLayer *gradient;
@property (nonatomic, strong, readonly) UILabel *indexLabel;
@property (nonatomic, strong, readonly) UIButton *operationButton;

@property (nonatomic, assign) CZYImageBrowserToolBarOperationType operationType;

// 当option为nil时，按钮会被一直隐藏
- (void)setOperationButtonImage:(UIImage * _Nullable)image title:(NSString * _Nullable)title operation:(_Nullable CZYImageBrowserToolBarOperationBlock)operation;

- (void)hideOperationButton;

@end

NS_ASSUME_NONNULL_END
