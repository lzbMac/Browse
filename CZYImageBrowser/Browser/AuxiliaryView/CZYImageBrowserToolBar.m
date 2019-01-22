//
//  CZYImageBrowserToolBar.m
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/21.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import "CZYImageBrowserToolBar.h"
#import "CZYIBFileManager.h"
#import "CZYImageBrowserTipView.h"
#import "CZYIBCopywriter.h"
#import "CZYIBUtilities.h"

static CGFloat kToolBarDefaultsHeight = 50.0;

@interface CZYImageBrowserToolBar() {
    CZYImageBrowserToolBarOperationBlock _operation;
    id<CZYImageBrowserCellDataProtocol> _data;
}
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UIButton *operationButton;
@property (nonatomic, strong) CAGradientLayer *gradient;
@end

@implementation CZYImageBrowserToolBar
@synthesize czy_browserShowSheetViewBlock = _czy_browserShowSheetViewBlock;

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer addSublayer:self.gradient];
        [self addSubview:self.indexLabel];
        [self addSubview:self.operationButton];
    }
    return self;
}
#pragma mark - public

- (void)setOperationButtonImage:(UIImage *)image title:(NSString *)title operation:(CZYImageBrowserToolBarOperationBlock)operation {
    [self.operationButton setImage:image forState:UIControlStateNormal];
    [self.operationButton setTitle:title forState:UIControlStateNormal];
    self->_operation = operation;
    self->_operationType = CZYImageBrowserToolBarOperationTypeCustom;
}

- (void)hideOperationButton {
    [self setOperationButtonImage:nil title:nil operation:nil];
}
#pragma mark - <CZYImageBrowserToolBarProtocol>

- (void)czy_browserUpdateLayoutWithDirection:(CZYImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize {
    CGFloat height = kToolBarDefaultsHeight, width = containerSize.width, buttonWidth = 53, labelWidth = width / 3.0, hExtra = 0;
    if (containerSize.height > containerSize.width && CZYIB_IS_IPHONEX) height += CZYIB_HEIGHT_STATUSBAR;
    if (containerSize.height < containerSize.width && CZYIB_IS_IPHONEX) hExtra += CZYIB_HEIGHT_EXTRABOTTOM;
    
    self.frame = CGRectMake(0, 0, width, height);
    self.gradient.frame = self.bounds;
    self.indexLabel.frame = CGRectMake(15 + hExtra, height - kToolBarDefaultsHeight, labelWidth, kToolBarDefaultsHeight);
    self.operationButton.frame = CGRectMake(width - buttonWidth - hExtra, height - kToolBarDefaultsHeight, buttonWidth, kToolBarDefaultsHeight);
}

- (void)czy_browserPageIndexChanged:(NSUInteger)pageIndex totalPage:(NSUInteger)totalPage data:(id<CZYImageBrowserCellDataProtocol>)data {
    switch (self->_operationType) {
        case CZYImageBrowserToolBarOperationTypeSave: {
            if ([data respondsToSelector:@selector(czy_browserSaveToPhotoAlbum)] && [data respondsToSelector:@selector(czy_browserAllowSaveToPhotoAlbum)] && [data czy_browserAllowSaveToPhotoAlbum]) {
                self.operationButton.hidden = NO;
                [self.operationButton setImage:[CZYIBFileManager getImageWithName:@"czyib_save"] forState:UIControlStateNormal];
            } else {
                self.operationButton.hidden = YES;
            }
        }
            break;
        case CZYImageBrowserToolBarOperationTypeMore: {
            self.operationButton.hidden = NO;
            [self.operationButton setImage:[CZYIBFileManager getImageWithName:@"czyib_more"] forState:UIControlStateNormal];
        }
            break;
        case CZYImageBrowserToolBarOperationTypeCustom: {
            self.operationButton.hidden = !self->_operation;
        }
            break;
    }
    
    self->_data = data;
    if (totalPage <= 1) {
        self.indexLabel.hidden = YES;
    } else {
        self.indexLabel.hidden  = NO;
        self.indexLabel.text = [NSString stringWithFormat:@"%ld/%ld", pageIndex + 1, totalPage];
    }
}
#pragma mark - event

- (void)clickOperationButton:(UIButton *)button {
    switch (self->_operationType) {
        case CZYImageBrowserToolBarOperationTypeSave: {
            if ([self->_data respondsToSelector:@selector(czy_browserSaveToPhotoAlbum)]) {
                [self->_data czy_browserSaveToPhotoAlbum];
            } else {
                [[UIApplication sharedApplication].keyWindow czy_showForkTipView:[CZYIBCopywriter shareCopywriter].unableToSave];
            }
        }
            break;
        case CZYImageBrowserToolBarOperationTypeMore: {
            self.czy_browserShowSheetViewBlock(self->_data);
        }
            break;
        case CZYImageBrowserToolBarOperationTypeCustom: {
            if (self->_operation) {
                self->_operation(self->_data);
            }
        }
            break;
    }
}

#pragma mark - getter

- (UILabel *)indexLabel {
    if (!_indexLabel) {
        _indexLabel = [UILabel new];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.font = [UIFont boldSystemFontOfSize:16];
        _indexLabel.textAlignment = NSTextAlignmentLeft;
        _indexLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _indexLabel;
}

- (UIButton *)operationButton {
    if (!_operationButton) {
        _operationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _operationButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _operationButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_operationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_operationButton addTarget:self action:@selector(clickOperationButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _operationButton;
}

- (CAGradientLayer *)gradient {
    if (!_gradient) {
        _gradient = [CAGradientLayer layer];
        _gradient.startPoint = CGPointMake(0.5, 0);
        _gradient.endPoint = CGPointMake(0.5, 1);
        _gradient.colors = @[(id)[UIColor colorWithRed:0  green:0  blue:0 alpha:0.3].CGColor, (id)[UIColor colorWithRed:0  green:0  blue:0 alpha:0].CGColor];
    }
    return _gradient;
}
@end
