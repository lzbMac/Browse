//
//  CustomCellData.m
//  YBImageBrowserDemo
//
//  Created by 杨波 on 2018/8/26.
//  Copyright © 2018年 杨波. All rights reserved.
//

#import "CustomCellData.h"
#import "CustomCell.h"

@interface CustomCellData () 
@end

@implementation CustomCellData

#pragma mark - <YBImageBrowserCellDataProtocol>


// optional method

- (BOOL)yb_browserAllowShowSheetView {
    return NO;
}

- (nonnull Class)czy_classOfBrowserCell {
    return CustomCell.class;
}

@end
