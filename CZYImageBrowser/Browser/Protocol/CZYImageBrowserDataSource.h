//
//  CZYImageBrowserDataSource.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/21.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CZYImageBrowserCellDataProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class CZYImageBrowserView;

@protocol CZYImageBrowserDataSource <NSObject>

- (NSUInteger)czy_numberOfCellForImageBrowserView:(CZYImageBrowserView *)imageBrowserView;

- (id<CZYImageBrowserCellDataProtocol>)czy_imageBrowserView:(CZYImageBrowserView *)imageBrowserView dataForCellAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
