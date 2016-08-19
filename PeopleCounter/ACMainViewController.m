//
//  ACMainViewController.m
//  PeopleCounter
//
//  Created by Air_chen on 16/8/6.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "ACMainViewController.h"
#import "InformViewController.h"
#import "TableViewModel.h"
#import "ACMainViewModel.h"

@interface ACMainViewController()
@property (weak, nonatomic) IBOutlet UIView *btnView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *comboView;

@property (weak, nonatomic) IBOutlet UIButton *humanBtn;
@property (weak, nonatomic) IBOutlet UIButton *tempBtn;
@property (weak, nonatomic) IBOutlet UIButton *airBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewContraint;
@property (weak, nonatomic) IBOutlet UILabel *headerLab;

@property(nonatomic,strong) TableViewModel *tableVM;
@property(nonatomic,strong) ACMainViewModel *mainVM;
@end

@implementation ACMainViewController

-(TableViewModel *)tableVM
{
    if (_tableVM == nil) {
        _tableVM = [[TableViewModel alloc] init];
    }
    return _tableVM;
}

-(ACMainViewModel *)mainVM
{
    if (_mainVM == nil) {
        _mainVM = [[ACMainViewModel alloc] init];
    }
    return _mainVM;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

-(void)setUpUI
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trachCashe)];
    
    [self.navigationController.navigationBar setTintColor:[UIColor orangeColor]];
    //    2.隐藏分割线
    [self.navigationController.navigationBar setShadowImage:[UIImage alloc]];
    
    self.tableView.delegate = self.tableVM;
//    self.tableView.delegate = self;
    self.tableView.dataSource = self.tableVM;
//    self.tableView.dataSource = self;
    
    self.tableVM.tableView = self.tableView;
    self.tableVM.view = self.view;
    self.tableVM.navigationController = self.navigationController;
    self.tableVM.headerLab = self.headerLab;
    self.tableVM.headerViewContraint = self.headerViewContraint;
    
    [self.tableVM.httpCommand execute:nil];
    
    self.mainVM.humanBtn = self.humanBtn;
    self.mainVM.airBtn = self.airBtn;
    self.mainVM.tempBtn = self.tempBtn;
    
//    self.mainVM.btnSubView = self.btnSubView;
    self.mainVM.navigationItem = self.navigationItem;
    self.mainVM.btnView = self.btnView;
    self.mainVM.navigationController = self.navigationController;
    self.mainVM.comboView = self.comboView;
    
    [self.mainVM.acMainCommand execute:nil];

}

- (IBAction)docAction:(id)sender {
    
}

- (IBAction)msgAction:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InformViewController *informVC = [storyBoard instantiateViewControllerWithIdentifier:@"InformVC"];
    
    [self.navigationController pushViewController:informVC animated:YES];
}

//清理沙盒目录下的文件
-(void)trachCashe
{
    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSLocalDomainMask, YES)[0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:filePath error:nil];
    
    for (NSString *file in files) {
        if ([file hasSuffix:@"data"]) {
            NSLog(@"%@",file);
            [fileManager removeItemAtPath:[filePath stringByAppendingPathComponent:file] error:nil];
        }
    }
}

@end
