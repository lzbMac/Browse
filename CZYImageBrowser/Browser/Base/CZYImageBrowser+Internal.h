//
//  CZYImageBrowser+Internal.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/21.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import "CZYImageBrowser.h"
#import "CZYImageBrowserView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CZYImageBrowser ()

@property (nonatomic, strong) CZYImageBrowserView *browserView;

@property (nonatomic, weak, nullable) id hiddenSourceObject;

@end

NS_ASSUME_NONNULL_END
