//
//  CZYImageBrowserSheetViewProtocol.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/21.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CZYImageBrowserCellDataProtocol.h"
#import "CZYIBLayoutDirectionManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CZYImageBrowserSheetViewProtocol <NSObject>
@required

- (void)czy_browserShowSheetViewWithData:(id<CZYImageBrowserCellDataProtocol>)data layoutDirection:(CZYImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize;

- (void)czy_browserHideSheetViewWithAnimation:(BOOL)animation;

- (NSInteger)czy_browserActionsCount;


@end

NS_ASSUME_NONNULL_END
