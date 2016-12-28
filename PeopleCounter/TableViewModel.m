//
//  TableViewModel.m
//  PeopleCounter
//
//  Created by Air_chen on 16/6/20.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "TableViewModel.h"
#import "CellDatas.h"
#import "DateCell.h"
#import "ImageViewController.h"
#import "ACNetWorkManager.h"

@interface TableViewModel()

@property (nonatomic, readwrite, strong) NSMutableArray<CellDatas *> *dataArray;

@end

@implementation TableViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self bindEvents];
    }
    return self;
}

- (void)bindEvents
{
    self.httpCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        RACSignal *requestSig = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            [[ACNetWorkManager shareManager] getUrlStr:uuidUrl thatResult:^(RACTuple *resData) {
                RACTupleUnpack(NSHTTPURLResponse *response,NSData *data) = resData;
                
                NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                //   状态码
                NSLog(@"%ld",(long)response.statusCode);
                
                NSLog(@"%@",content);
                
                NSDictionary *initDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSArray *initArray = initDic[@"data"][@"datastreams"];
                NSInteger count = [initDic[@"data"][@"count"] integerValue] / 3;
                
                NSArray *firstArray = initArray[0][@"datapoints"];
                NSArray *secArray = initArray[1][@"datapoints"];
                //    NSArray *thrArray = initArray[2][@"datapoints"];//图片
                //    2.加载到数组里面
                //    2.1初始化CellDatas
                NSMutableArray<CellDatas *>* datasArray = [NSMutableArray arrayWithCapacity:count];
                for (int i = 0; i < count; i++) {
                    CellDatas *cellData = [[CellDatas alloc] init];
                    [cellData setDateTimeStr:firstArray[i][@"at"]];
                    [cellData setImgUuid:firstArray[i][@"value"]];
                    [cellData setRecogNumsStr:secArray[i][@"value"]];
                    [datasArray addObject:cellData];
                }
                self.dataArray = datasArray;
                
                [subscriber sendNext:datasArray];
                [subscriber sendCompleted];
            }];
            
            return nil;
        }];
        return requestSig;
    }];
    
    [[self.httpCommand.executing skip:1] subscribeNext:^(id x) {
        
        if ([x boolValue] == YES) {
            NSLog(@"httping!");
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }else
        {
            NSLog(@"done!");
            [self.tableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ImageViewController *imgVc = [storyBoard instantiateViewControllerWithIdentifier:@"ImgVC"];
    [imgVc setUuid:self.dataArray[indexPath.row].imgUuid];
    
    [self.navigationController pushViewController:imgVc animated:YES];
}

#pragma mark - tableView DateSourse
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    CellDatas *cellDatas = self.dataArray[indexPath.row];
    
    NSRange range;
    range.location = 11;
    range.length = 8;
    NSString *str = [cellDatas.dateTimeStr substringWithRange:range];
    cell.textLabel.text = str;
    
    cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.freshBtn moveDistance:0.0 inType:ACMoveBegin];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint scrollPoint = scrollView.contentOffset;
    
    CGFloat moveDistance = 0.0 - scrollPoint.y;
    
    self.headerViewContraint.constant = moveDistance;
    
    [self.view layoutIfNeeded];
    
    if (moveDistance < 40) {
        self.headerLab.text = @"下拉更新。。。。";
    }
    
    if (moveDistance >= 40.0&&moveDistance <= 80) {
        self.headerLab.text = @"继续下拉，刷新数据。。。";
    }
    
    if (moveDistance > 80) {
        self.headerLab.text = @"松手，获得更新的数据。";
    }
    
    [self.freshBtn moveDistance:moveDistance inType:ACMoveMoving];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    //告诉刷新动画结束触控
    [self.freshBtn moveDistance:0.0 inType:ACMoveEnd];
    
    
    CGPoint scrollPoint = scrollView.contentOffset;
    CGFloat moveDistance = 0.0 - scrollPoint.y;
    
    if (moveDistance >= 80) {
        
        //更新数据
        [self.httpCommand execute:nil];
        
        [self.tableView reloadData];
    }
}

@end
