//
//  CustomCell.m
//  CZYImageBrowserDemo
//
//  Created by 李正兵 on 2018/8/26.
//  Copyright © 2018年 李正兵. All rights reserved.
//

#import "CustomCell.h"
#import "CustomCellData.h"

@interface CustomCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@end

@implementation CustomCell

@synthesize czy_browserDismissBlock = _czy_browserDismissBlock;

#pragma mark - life cycle

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTapGesture)];
    [self.contentView addGestureRecognizer:tapGesture];
}

- (void)respondsToTapGesture {
    self.czy_browserDismissBlock();
}

#pragma mark - private

- (void)updateUIWithlayoutDirection:(CZYImageBrowserLayoutDirection)layoutDirection {
    NSString *orientation = nil;
    switch (layoutDirection) {
        case CZYImageBrowserLayoutDirectionUnknown:
            orientation = @"Unknown";
            break;
        case CZYImageBrowserLayoutDirectionVertical:
            orientation = @"Vertical";
            break;
        case CZYImageBrowserLayoutDirectionHorizontal:
            orientation = @"Horizontal";
            break;
    }
    self.subTitleLabel.text = [NSString stringWithFormat:@"Layout Direction：%@", orientation];
}

#pragma mark - <CZYImageBrowserCellProtocol>

// required method

- (void)czy_initializeBrowserCellWithData:(id<CZYImageBrowserCellDataProtocol>)data layoutDirection:(CZYImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize {
    if (![data isKindOfClass:CustomCellData.class]) return;
    CustomCellData *cellData = (CustomCellData *)data;
    self.titleLabel.text = cellData.text;
    
    [self updateUIWithlayoutDirection:layoutDirection];
}

// optional method

- (void)czy_browserLayoutDirectionChanged:(CZYImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize {
    [self updateUIWithlayoutDirection:layoutDirection];
}

@end
