//
//  TableViewModel.h
//  PeopleCounter
//
//  Created by Air_chen on 16/6/20.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalHeader.h"
#import <UIKit/UIKit.h>

@interface TableViewModel : NSObject<UITableViewDataSource,UITableViewDelegate,NSURLConnectionDataDelegate>

@property(nonatomic,strong,nonnull) RACCommand *httpCommand;
@property(nonatomic,strong,nonnull) UITableView *tableView;
@property(nonnull,nonatomic,strong) UIView *view;

@end
