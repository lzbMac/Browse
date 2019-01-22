//
//  ViewController.m
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/17.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import "ViewController.h"
#import "CZYImageBrowserTipView.h"
#import "CZYImageBrowserProgressView.h"
#import <Photos/Photos.h>
#import "CollectionViewController.h"

@interface ViewController ()

@property (nonatomic, strong)NSArray *dataArray;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)loacalIamges:(id)sender {
    CollectionViewController *collect = [[CollectionViewController alloc] init];
    collect.type = PhotoTypeLocal;
    [self.navigationController pushViewController:collect animated:YES];
}

- (IBAction)netWorkImages:(id)sender {
    CollectionViewController *collect = [[CollectionViewController alloc] init];
    collect.type = PhotoTypeNet;
    [self.navigationController pushViewController:collect animated:YES];
}

- (IBAction)photoAsset:(id)sender {
    CollectionViewController *collect = [[CollectionViewController alloc] init];
    collect.type = PhotoTypeAsset;
    [self.navigationController pushViewController:collect animated:YES];
    
}


@end
