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
#import "ACFreshBtn.h"

@interface TableViewModel : NSObject<NSURLConnectionDataDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, readwrite, strong, nonnull) RACCommand *httpCommand;
@property (nonatomic, readwrite, weak) UITableView *tableView;
@property (nonatomic, readwrite, weak) ACFreshBtn *freshBtn;
@property (nonatomic, readwrite, weak) UIView *view;

@property (nonatomic, readwrite, weak) UINavigationController *navigationController;
@property (nonatomic, readwrite, weak) NSLayoutConstraint *headerViewContraint;
@property (nonatomic, readwrite, weak) UILabel *headerLab;

@end
