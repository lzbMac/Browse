//
//  CZYImageBrowserToolBarProtocol.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/21.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CZYIBLayoutDirectionManager.h"
#import "CZYImageBrowserCellDataProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CZYImageBrowserToolBarProtocol <NSObject>
@required

- (void)czy_browserUpdateLayoutWithDirection:(CZYImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize;

@optional

- (void)czy_browserPageIndexChanged:(NSUInteger)pageIndex totalPage:(NSUInteger)totalPage data:(id<CZYImageBrowserCellDataProtocol>)data;

@property (nonatomic, copy) void(^czy_browserShowSheetViewBlock)(id<CZYImageBrowserCellDataProtocol> data);


@end

NS_ASSUME_NONNULL_END
