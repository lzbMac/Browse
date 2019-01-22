//
//  CZYImageBrowser.m
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/17.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import "CZYImageBrowser.h"
#import "CZYImageBrowserViewLayout.h"
#import "CZYImageBrowserView.h"
#import "CZYImageBrowser+Internal.h"
#import "CZYIBUtilities.h"
#import "CZYIBWebImageManager.h"
#import "CZYIBTransitionManager.h"
#import "CZYIBLayoutDirectionManager.h"
#import "CZYIBCopywriter.h"

@interface CZYImageBrowser () <UIViewControllerTransitioningDelegate, CZYImageBrowserViewDelegate, CZYImageBrowserDataSource> {
    BOOL _isFirstViewDidAppear;
    CZYImageBrowserLayoutDirection _layoutDirection;
    CGSize _containerSize;
    BOOL _isRestoringDeviceOrientation;
    UIInterfaceOrientation _statusBarOrientationBefore;
    UIWindowLevel _windowLevelByDefault;
}
@property (nonatomic, strong) CZYIBLayoutDirectionManager *layoutDirectionManager;
@property (nonatomic, strong) CZYIBTransitionManager *transitionManager;

@end

@implementation CZYImageBrowser
#pragma mark - life cycle

- (void)dealloc {
    // If the current instance is released (possibly uncontrollable release), we need to restore the changes to external business.
    [CZYIBWebImageManager restoreOutsideConfiguration];
    self.hiddenSourceObject = nil;
    [self setStatusBarHide:NO];
    [self removeObserverForSystem];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        [self initVars];
        [CZYIBWebImageManager storeOutsideConfiguration];
        [self.layoutDirectionManager startObserve];
    }
    return self;
}

- (void)initVars {
    self->_isFirstViewDidAppear = NO;
    self->_isRestoringDeviceOrientation = NO;
    
    self->_currentIndex = 0;
    self->_supportedOrientations = UIInterfaceOrientationMaskAllButUpsideDown;
    self->_backgroundColor = [UIColor blackColor];
    self->_enterTransitionType = CZYImageBrowserTransitionTypeCoherent;
    self->_outTransitionType = CZYImageBrowserTransitionTypeCoherent;
    self->_transitionDuration = 0.25;
    self->_autoHideSourceObject = YES;
    
    self.shouldPreload = YES;
    
    CZYImageBrowserToolBar *toolBar = [CZYImageBrowserToolBar new];
    self->_defaultToolBar = toolBar;
    self->_toolBars = @[toolBar];
    
    CZYImageBrowserSheetView *sheetView = [CZYImageBrowserSheetView new];
    CZYImageBrowserSheetAction *saveAction = [CZYImageBrowserSheetAction actionWithName:[CZYIBCopywriter shareCopywriter].saveToPhotoAlbum identity:kCZYImageBrowserSheetActionIdentitySaveToPhotoAlbum action:nil];
    sheetView.actions = @[saveAction];
    self->_defaultSheetView = sheetView;
    self->_sheetView = sheetView;
    
    self->_shouldHideStatusBar = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = self->_backgroundColor;
    [self addGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self->_windowLevelByDefault = self.view.window.windowLevel;
    [self setStatusBarHide:YES];
    
    if (!self->_isFirstViewDidAppear) {
        
        [self updateLayoutOfSubViewsWithLayoutDirection:[CZYIBLayoutDirectionManager getLayoutDirectionByStatusBar]];
        
        [self.browserView scrollToPageWithIndex:self->_currentIndex];
        
        [self addSubViews];
        
        self->_isFirstViewDidAppear = YES;
        
        [self addObserverForSystem];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setStatusBarHide:NO];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.supportedOrientations;
}

- (void)setStatusBarHide:(BOOL)hide {
    if (self.shouldHideStatusBar) {
        self.view.window.windowLevel = hide ? UIWindowLevelStatusBar + 1 : _windowLevelByDefault;
    }
}
#pragma mark - gesture

- (void)addGesture {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToLongPress:)];
    [self.view addGestureRecognizer:longPress];
}

- (void)respondsToLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(czy_imageBrowser:respondsToLongPress:)]) {
            [self.delegate czy_imageBrowser:self respondsToLongPress:sender];
            return;
        }
        
        if (self.sheetView && (![[self currentData] respondsToSelector:@selector(czy_browserAllowShowSheetView)] || [[self currentData] czy_browserAllowShowSheetView])) {
            [self.view addSubview:self.sheetView];
            [self.sheetView czy_browserShowSheetViewWithData:[self currentData] layoutDirection:self->_layoutDirection containerSize:self->_containerSize];
        }
    }
}

#pragma mark - observe

- (void)removeObserverForSystem {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)addObserverForSystem {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarFrame) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)didChangeStatusBarFrame {
    if ([UIApplication sharedApplication].statusBarFrame.size.height > CZYIB_HEIGHT_STATUSBAR) {
        self.view.frame = CGRectMake(0, 0, self->_containerSize.width, self->_containerSize.height);
    }
}

#pragma mark - private

- (void)addSubViews {
    [self.view addSubview:self.browserView];
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<CZYImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.view addSubview:obj];
        if ([obj respondsToSelector:@selector(setCzy_browserShowSheetViewBlock:)]) {
            __weak typeof(self) wSelf = self;
            [obj setCzy_browserShowSheetViewBlock:^(id<CZYImageBrowserCellDataProtocol> _Nonnull data) {
                __strong typeof(wSelf) sSelf = wSelf;
                if (sSelf.sheetView) {
                    [sSelf.view addSubview:sSelf.sheetView];
                    [sSelf.sheetView czy_browserShowSheetViewWithData:data layoutDirection:sSelf->_layoutDirection containerSize:sSelf->_containerSize];
                }
            }];
        }
    }];
}

- (void)updateLayoutOfSubViewsWithLayoutDirection:(CZYImageBrowserLayoutDirection)layoutDirection {
    self->_layoutDirection = layoutDirection;
    CGSize containerSize = layoutDirection == CZYImageBrowserLayoutDirectionHorizontal ? CGSizeMake(CZYIMAGEBROWSER_HEIGHT, CZYIMAGEBROWSER_WIDTH) : CGSizeMake(CZYIMAGEBROWSER_WIDTH, CZYIMAGEBROWSER_HEIGHT);
    self->_containerSize = containerSize;
    
    if (self.sheetView && self.sheetView.superview) {
        [self.sheetView czy_browserHideSheetViewWithAnimation:NO];
    }
    
    [self.browserView updateLayoutWithDirection:layoutDirection containerSize:containerSize];
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<CZYImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj czy_browserUpdateLayoutWithDirection:layoutDirection containerSize:containerSize];
    }];
}

- (void)pageIndexChanged:(NSUInteger)index {
    self->_currentIndex = index;
    
    id<CZYImageBrowserCellDataProtocol> data = [self currentData];
    
    id sourceObj = nil;
    if ([data respondsToSelector:@selector(czy_browserCellSourceObject)]) {
        sourceObj = data.czy_browserCellSourceObject;
    }
    self.hiddenSourceObject = sourceObj;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(czy_imageBrowser:pageIndexChanged:data:)]) {
        [self.delegate czy_imageBrowser:self pageIndexChanged:index data:data];
    }
    
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<CZYImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (self.defaultToolBar && self.sheetView && [self.sheetView czy_browserActionsCount] >= 2) {
            self.defaultToolBar.operationType = CZYImageBrowserToolBarOperationTypeMore;
        }
        
        if ([obj respondsToSelector:@selector(czy_browserPageIndexChanged:totalPage:data:)]) {
            [obj czy_browserPageIndexChanged:index totalPage:[self.dataSource czy_numberOfCellForImageBrowserView:self.browserView] data:data];
        }
    }];
}

#pragma mark - public

- (void)setDataSource:(id<CZYImageBrowserDataSource>)dataSource {
    self.browserView.czy_dataSource = dataSource;
}

- (id<CZYImageBrowserDataSource>)dataSource {
    return self.browserView.czy_dataSource;
}

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    if (currentIndex + 1 > [self.browserView.czy_dataSource czy_numberOfCellForImageBrowserView:self.browserView]) {
        CZYIBLOG_ERROR(@"The index out of range.");
    } else {
        _currentIndex = currentIndex;
        if (self.browserView.superview) {
            [self.browserView scrollToPageWithIndex:currentIndex];
        }
    }
}

- (void)reloadData {
    [self.browserView czy_reloadData];
    [self.browserView scrollToPageWithIndex:self->_currentIndex];
    [self pageIndexChanged:self.browserView.currentIndex];
}

- (id<CZYImageBrowserCellDataProtocol>)currentData {
    return [self.browserView currentData];
}

- (void)show {
    if ([self.browserView.czy_dataSource czy_numberOfCellForImageBrowserView:self.browserView] <= 0) {
        CZYIBLOG_ERROR(@"The data sources is invalid.");
        return;
    }
    [self showFromController:CZYIBGetTopController()];
}

- (void)showFromController:(UIViewController *)fromController {
    //Preload current data.
    if (self.shouldPreload) {
        id<CZYImageBrowserCellDataProtocol> needPreloadData = [self.browserView dataAtIndex:self.currentIndex];
        if ([needPreloadData respondsToSelector:@selector(czy_preload)]) {
            [needPreloadData czy_preload];
        }
        
        if (self.currentIndex == 0) {
            [self.browserView preloadWithCurrentIndex:self.currentIndex];
        }
    }
    
    self->_statusBarOrientationBefore = [UIApplication sharedApplication].statusBarOrientation;
    self.browserView.statusBarOrientationBefore = self->_statusBarOrientationBefore;
    [fromController presentViewController:self animated:YES completion:nil];
}

- (void)hide {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setDistanceBetweenPages:(CGFloat)distanceBetweenPages {
    _distanceBetweenPages = distanceBetweenPages;
    ((CZYImageBrowserViewLayout *)self.browserView.collectionViewLayout).distanceBetweenPages = distanceBetweenPages;
}

- (void)setGiProfile:(CZYIBGestureInteractionProfile *)giProfile {
    _giProfile = giProfile;
    self.browserView.giProfile = giProfile;
}

- (void)setDataCacheCountLimit:(NSUInteger)dataCacheCountLimit {
    _dataCacheCountLimit = dataCacheCountLimit;
    self.browserView.cacheCountLimit = dataCacheCountLimit;
}

- (void)setShouldPreload:(BOOL)shouldPreload {
    _shouldPreload = shouldPreload;
    self.browserView.shouldPreload = shouldPreload;
}


#pragma mark - internal

- (void)setHiddenSourceObject:(id)hiddenSourceObject {
    if (!self->_autoHideSourceObject) return;
    if (_hiddenSourceObject && [_hiddenSourceObject respondsToSelector:@selector(setHidden:)]) {
        [_hiddenSourceObject setValue:@(NO) forKey:@"hidden"];
    }
    if (hiddenSourceObject && [hiddenSourceObject respondsToSelector:@selector(setHidden:)]) {
        [hiddenSourceObject setValue:@(YES) forKey:@"hidden"];
    }
    _hiddenSourceObject = hiddenSourceObject;
}

#pragma mark <UIViewControllerTransitioningDelegate>

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.transitionManager;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.transitionManager;
}

#pragma mark - <CZYImageBrowserViewDelegate>

- (void)czy_imageBrowserViewDismiss:(CZYImageBrowserView *)browserView {
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<CZYImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    
    if ([UIApplication sharedApplication].statusBarOrientation != self->_statusBarOrientationBefore && [[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        NSInteger val = self->_statusBarOrientationBefore;
        [invocation setArgument:&val atIndex:2];
        self->_isRestoringDeviceOrientation = YES;
        [invocation invoke];
    }
    
    [self hide];
}

- (void)czy_imageBrowserView:(CZYImageBrowserView *)browserView changeAlpha:(CGFloat)alpha duration:(NSTimeInterval)duration {
    void (^animationsBlock)(void) = ^{
        self.view.backgroundColor = [self->_backgroundColor colorWithAlphaComponent:alpha];
    };
    void (^completionBlock)(BOOL) = ^(BOOL x){
        if (alpha == 1) [self setStatusBarHide:YES];
        if (alpha < 1) [self setStatusBarHide:NO];
    };
    if (duration <= 0) {
        animationsBlock();
        completionBlock(YES);
    } else {
        [UIView animateWithDuration:duration animations:animationsBlock completion:completionBlock];
    }
}

- (void)czy_imageBrowserView:(CZYImageBrowserView *)browserView pageIndexChanged:(NSUInteger)index {
    [self pageIndexChanged:index];
}

- (void)czy_imageBrowserView:(CZYImageBrowserView *)browserView hideTooBar:(BOOL)hidden {
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<CZYImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = hidden;
    }];
    if (self.sheetView && self.sheetView.superview && hidden) {
        [self.sheetView czy_browserHideSheetViewWithAnimation:YES];
    }
}

#pragma mark - <CZYImageBrowserDataSource>

- (NSUInteger)czy_numberOfCellForImageBrowserView:(CZYImageBrowserView *)imageBrowserView {
    return self.dataSourceArray.count;
}

- (id<CZYImageBrowserCellDataProtocol>)czy_imageBrowserView:(CZYImageBrowserView *)imageBrowserView dataForCellAtIndex:(NSUInteger)index {
    return self.dataSourceArray[index];
}

#pragma mark - getter

- (CZYImageBrowserView *)browserView {
    if (!_browserView) {
        _browserView = [CZYImageBrowserView new];
        _browserView.czy_delegate = self;
        _browserView.czy_dataSource = self;
        _browserView.giProfile = [CZYIBGestureInteractionProfile new];
    }
    return _browserView;
}

- (CZYIBLayoutDirectionManager *)layoutDirectionManager {
    if (!_layoutDirectionManager) {
        _layoutDirectionManager = [CZYIBLayoutDirectionManager new];
        __weak typeof(self) wSelf = self;
        [_layoutDirectionManager setLayoutDirectionChangedBlock:^(CZYImageBrowserLayoutDirection layoutDirection) {
            __strong typeof(self) sSelf = wSelf;
            if (layoutDirection == CZYImageBrowserLayoutDirectionUnknown || sSelf.transitionManager.isTransitioning || sSelf->_isRestoringDeviceOrientation) return;
            
            [sSelf updateLayoutOfSubViewsWithLayoutDirection:layoutDirection];
        }];
    }
    return _layoutDirectionManager;
}

- (CZYIBTransitionManager *)transitionManager {
    if (!_transitionManager) {
        _transitionManager = [CZYIBTransitionManager new];
        _transitionManager.imageBrowser = self;
    }
    return _transitionManager;
}

@end
