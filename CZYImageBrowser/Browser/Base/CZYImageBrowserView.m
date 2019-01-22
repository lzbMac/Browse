//
//  CZYImageBrowserView.m
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/21.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import "CZYImageBrowserView.h"
#import "CZYImageBrowseCell.h"
#import "CZYImageBrowserViewLayout.h"
#import "CZYIBUtilities.h"
#import "CZYImageBrowserCellDataProtocol.h"
#import "CZYImageBrowserCellProtocol.h"

static NSInteger const preloadCount = 2;

@interface CZYImageBrowserView () <UICollectionViewDataSource, UICollectionViewDelegate> {
    NSMutableSet *_reuseIdentifierSet;
    CZYImageBrowserLayoutDirection _layoutDirection;
    CGSize _containerSize;
    BOOL _isDealingScreenRotation;
    BOOL _bodyIsInCenter;
    BOOL _isDealedSELInitializeFirst;
    NSCache *_dataCache;
}
@property (nonatomic, assign) NSUInteger currentIndex;
@end

@implementation CZYImageBrowserView
#pragma mark - life cycle

- (void)dealloc {
    self->_dataCache = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame collectionViewLayout:[CZYImageBrowserViewLayout new]];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self initVars];
        
        self.backgroundColor = [UIColor clearColor];
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.alwaysBounceVertical = NO;
        self.alwaysBounceHorizontal = NO;
        self.delegate = self;
        self.dataSource = self;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return self;
}

- (void)initVars {
    self->_layoutDirection = CZYImageBrowserLayoutDirectionUnknown;
    self->_reuseIdentifierSet = [NSMutableSet set];
    self->_isDealingScreenRotation = NO;
    self->_bodyIsInCenter = YES;
    self->_currentIndex = NSUIntegerMax;
    self->_isDealedSELInitializeFirst = NO;
    self->_cacheCountLimit = 8;
}

#pragma mark - public

- (void)updateLayoutWithDirection:(CZYImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize {
    if (self->_layoutDirection == layoutDirection) return;
    self->_isDealingScreenRotation = YES;
    
    self->_containerSize = containerSize;
    self.frame = CGRectMake(0, 0, self->_containerSize.width, self->_containerSize.height);
    self->_layoutDirection = layoutDirection;
    
    if (self.superview) {
        // Notice 'visibleCells' layout direction changed, can't use '-reloadData' because it will triggering '-prepareForReuse' of cell.
        NSArray<UICollectionViewCell<CZYImageBrowserCellProtocol> *> *cells = [self visibleCells];
        [cells enumerateObjectsUsingBlock:^(UICollectionViewCell<CZYImageBrowserCellProtocol> * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([cell respondsToSelector:@selector(czy_browserLayoutDirectionChanged:containerSize:)]) {
                [cell czy_browserLayoutDirectionChanged:self->_layoutDirection containerSize:self->_containerSize];
            }}];
        [self scrollToPageWithIndex:self.currentIndex];
    }
    
    [self layoutIfNeeded];
    self->_isDealingScreenRotation = NO;
}

- (void)scrollToPageWithIndex:(NSInteger)index {
    if (index >= [self.czy_dataSource czy_numberOfCellForImageBrowserView:self]) {
        // If index overstep the boundary, maximum processing.
        self.currentIndex = [self.czy_dataSource czy_numberOfCellForImageBrowserView:self] - 1;
        self.contentOffset = CGPointMake(self.bounds.size.width * self.currentIndex, 0);
    } else {
        CGPoint targetPoint = CGPointMake(self.bounds.size.width * index, 0);
        if (CGPointEqualToPoint(self.contentOffset, targetPoint)) {
            [self scrollViewDidScroll:self];
        } else {
            self.contentOffset = targetPoint;
        }
    }
}

- (void)czy_reloadData {
    self->_dataCache = nil;
    [self reloadData];
}

- (id<CZYImageBrowserCellDataProtocol>)currentData {
    return [self dataAtIndex:self.currentIndex];
}

- (id<CZYImageBrowserCellDataProtocol>)dataAtIndex:(NSUInteger)index {
    if (index < 0 || index >= [self.czy_dataSource czy_numberOfCellForImageBrowserView:self]) return nil;
    
    if (!self->_dataCache) {
        self->_dataCache = [NSCache new];
        self->_dataCache.countLimit = self.cacheCountLimit;
    }
    
    id<CZYImageBrowserCellDataProtocol> data;
    if (self->_dataCache && [self->_dataCache objectForKey:@(index)]) {
        data = [self->_dataCache objectForKey:@(index)];
    } else {
        data = [self.czy_dataSource czy_imageBrowserView:self dataForCellAtIndex:index];
        [self->_dataCache setObject:data forKey:@(index)];
    }
    return data;
}

- (void)preloadWithCurrentIndex:(NSInteger)index {
    for (NSInteger i = -preloadCount; i <= preloadCount; ++i) {
        if (i == 0) continue;
        id<CZYImageBrowserCellDataProtocol> needPreloadData = [self dataAtIndex:index + i];
        if ([needPreloadData respondsToSelector:@selector(czy_preload)]) {
            [needPreloadData czy_preload];
        }
    }
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (!self.czy_dataSource || ![self.czy_dataSource respondsToSelector:@selector(czy_numberOfCellForImageBrowserView:)]) return 0;
    return [self.czy_dataSource czy_numberOfCellForImageBrowserView:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.czy_dataSource || ![self.czy_dataSource respondsToSelector:@selector(czy_imageBrowserView:dataForCellAtIndex:)]) {
        return [UICollectionViewCell new];
    }
    
    id<CZYImageBrowserCellDataProtocol> data = [self dataAtIndex:indexPath.row];
    
    NSAssert(data && [data respondsToSelector:@selector(czy_classOfBrowserCell)], @"your custom data must conforms '<CZYImageBrowserCellDataProtocol>' and implement '-czy_classOfBrowserCell'");
    Class cellClass = data.czy_classOfBrowserCell;
    NSAssert(cellClass, @"the class get from '-czy_classOfBrowserCell' is invalid");
    
    NSString *identifier = NSStringFromClass(cellClass);
    if (![self->_reuseIdentifierSet containsObject:cellClass]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:identifier ofType:@"nib"];
        if (path) {
            [collectionView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellWithReuseIdentifier:identifier];
        } else {
            [collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
        }
        [self->_reuseIdentifierSet addObject:cellClass];
    }
    UICollectionViewCell<CZYImageBrowserCellProtocol> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSAssert(cell, @"your custom cell must be subclass of 'UICollectionViewCell'");
    
    NSAssert([cell respondsToSelector:@selector(czy_initializeBrowserCellWithData:layoutDirection:containerSize:)], @"your custom cell must conforms '<CZYImageBrowserCellProtocol>' and implement '-czy_initializeBrowserCellWithData:layoutDirection:containerSize:'");
    [cell czy_initializeBrowserCellWithData:data layoutDirection:self->_layoutDirection containerSize:self->_containerSize];
    
    if ([cell respondsToSelector:@selector(czy_browserStatusBarOrientationBefore:)]) {
        [cell czy_browserStatusBarOrientationBefore:self.statusBarOrientationBefore];
    }
    
    if ([cell respondsToSelector:@selector(setCzy_browserDismissBlock:)]) {
        __weak typeof(self) wSelf = self;
        [cell setCzy_browserDismissBlock:^{
            __strong typeof(wSelf) sSelf = wSelf;
            [sSelf.czy_delegate czy_imageBrowserViewDismiss:sSelf];
        }];
    }
    
    if ([cell respondsToSelector:@selector(setCzy_browserScrollEnabledBlock:)]) {
        __weak typeof(self) wSelf = self;
        [cell setCzy_browserScrollEnabledBlock:^(BOOL enabled) {
            __strong typeof(wSelf) sSelf = wSelf;
            sSelf.scrollEnabled = enabled;
        }];
    }
    
    if ([cell respondsToSelector:@selector(setCzy_browserChangeAlphaBlock:)]) {
        __weak typeof(self) wSelf = self;
        [cell setCzy_browserChangeAlphaBlock:^(CGFloat alpha, CGFloat duration) {
            __strong typeof(wSelf) sSelf = wSelf;
            [sSelf.czy_delegate czy_imageBrowserView:sSelf changeAlpha:alpha duration:duration];
        }];
    }
    
    if ([cell respondsToSelector:@selector(czy_browserSetGestureInteractionProfile:)]) {
        [cell czy_browserSetGestureInteractionProfile:self.giProfile];
    }
    
    if ([cell respondsToSelector:@selector(setCzy_browserToolBarHiddenBlock:)]) {
        __weak typeof(self) wSelf = self;
        [cell setCzy_browserToolBarHiddenBlock:^(BOOL hidden) {
            __strong typeof(wSelf) sSelf = wSelf;
            [sSelf.czy_delegate czy_imageBrowserView:sSelf hideTooBar:hidden];
        }];
    }
    
    if ([cell respondsToSelector:@selector(czy_browserInitializeFirst:)] && !self->_isDealedSELInitializeFirst) {
        self->_isDealedSELInitializeFirst = YES;
        [cell czy_browserInitializeFirst:self->_currentIndex == indexPath.row];
    }
    
    if (collectionView.window && self.shouldPreload) {
        [self preloadWithCurrentIndex:indexPath.row];
    }
    
    return cell;
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat indexF = scrollView.contentOffset.x / scrollView.bounds.size.width;
    NSUInteger index = (NSUInteger)(indexF + 0.5);
    
    BOOL isInCenter = indexF <= (NSInteger)indexF + 0.001 && indexF >= (NSInteger)indexF - 0.001;
    if (self->_bodyIsInCenter != isInCenter) {
        self->_bodyIsInCenter = isInCenter;
        
        NSArray<UICollectionViewCell<CZYImageBrowserCellProtocol> *> *cells = [self visibleCells];
        [cells enumerateObjectsUsingBlock:^(UICollectionViewCell<CZYImageBrowserCellProtocol> * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([cell respondsToSelector:@selector(czy_browserBodyIsInTheCenter:)]) {
                [cell czy_browserBodyIsInTheCenter:self->_bodyIsInCenter];
            }
        }];
    }
    
    if (index >= [self.czy_dataSource czy_numberOfCellForImageBrowserView:self]) return;
    if (self.currentIndex != index && !self->_isDealingScreenRotation) {
        self.currentIndex = index;
        
        [self.czy_delegate czy_imageBrowserView:self pageIndexChanged:self.currentIndex];
        
        // Notice 'visibleCells' page index changed.
        NSArray<UICollectionViewCell<CZYImageBrowserCellProtocol> *> *cells = [self visibleCells];
        [cells enumerateObjectsUsingBlock:^(UICollectionViewCell<CZYImageBrowserCellProtocol> * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([cell respondsToSelector:@selector(czy_browserPageIndexChanged:ownIndex:)]) {
                [cell czy_browserPageIndexChanged:self.currentIndex ownIndex:[self indexPathForCell:cell].row];
            }
        }];
    }
}

#pragma mark - hit-test

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    // When the hit-test view is 'UISlider', set '_scrollEnabled' to 'NO', avoid gesture conflicts.
    self.scrollEnabled = ![view isKindOfClass:UISlider.class];
    return view;
}

@end
