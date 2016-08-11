//
//  ViewController.m
//  PeopleCounter
//
//  Created by Air_chen on 16/6/20.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "ViewController.h"
#import "DateCell.h"
#import "CellDatas.h"
#import "ImageViewController.h"
#import "TableViewModel.h"
#import "GlobalHeader.h"
#import "PlotViewModel.h"
#import "InformViewController.h"

@interface ViewController ()

@property(nonatomic,strong) NSMutableArray<CellDatas *> *datasArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) TableViewModel *tableVM;
//@property (weak, nonatomic) IBOutlet CPTGraphHostingView *hostView;
//@property(nonatomic,strong) PlotViewModel *plotVM;
@end

@implementation ViewController

-(TableViewModel *)tableVM
{
    if (_tableVM == nil) {
        _tableVM = [[TableViewModel alloc] init];
    }
    
    return _tableVM;
}

-(NSMutableArray *)datasArray
{
    if (_datasArray == nil) {
        _datasArray = [NSMutableArray array];
    }
    
    return _datasArray;
}

//-(PlotViewModel *)plotVM
//{
//    if (_plotVM == nil) {
//        _plotVM = [[PlotViewModel alloc] init];
//    }
//    return _plotVM;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableView.dataSource = self.tableVM;
    self.tableVM.tableView = self.tableView;
    self.tableVM.view = self.view;
    
    RACSignal *sig = [self.tableVM.httpCommand execute:nil];
    
    [sig subscribeNext:^(NSMutableArray *x) {
        _datasArray = x;
        
//        [[RACScheduler mainThreadScheduler] afterDelay:0.1 schedule:^{
//            
//            self.hostView.hostedGraph = [self.plotVM createGraphWith:_datasArray inStyle:];
//            
//        }];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender class] == [UIBarButtonItem class]) {
        InformViewController *informVc = segue.destinationViewController;
    } else {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        ImageViewController *imgVc = segue.destinationViewController;
        [imgVc setUuid:_datasArray[indexPath.row].imgUuid];
    } 
    
}

@end
