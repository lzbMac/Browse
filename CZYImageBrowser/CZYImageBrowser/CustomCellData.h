//
//  CustomCellData.h
//  CZYImageBrowserDemo
//
//  Created by 李正兵 on 2018/8/26.
//  Copyright © 2018年 李正兵. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CZYImageBrowserCellDataProtocol.h"

@interface CustomCellData : NSObject <CZYImageBrowserCellDataProtocol>

@property (nonatomic, copy) NSString *text;

@end
