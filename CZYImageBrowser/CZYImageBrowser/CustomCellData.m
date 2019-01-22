//
//  CustomCellData.m
//  CZYImageBrowserDemo
//
//  Created by 李正兵 on 2018/8/26.
//  Copyright © 2018年 李正兵. All rights reserved.
//

#import "CustomCellData.h"
#import "CustomCell.h"

@interface CustomCellData () 
@end

@implementation CustomCellData

#pragma mark - <CZYImageBrowserCellDataProtocol>


// optional method

- (BOOL)czy_browserAllowShowSheetView {
    return NO;
}

- (nonnull Class)czy_classOfBrowserCell {
    return CustomCell.class;
}

@end
