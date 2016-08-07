//
//  ACMainViewController.m
//  PeopleCounter
//
//  Created by Air_chen on 16/8/6.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "ACMainViewController.h"
#import "ACButtonView.h"
#import "TableViewModel.h"
#import "ImageViewController.h"
#import "CellDatas.h"
#import "InformViewController.h"

@interface ACMainViewController()
@property (weak, nonatomic) IBOutlet UIView *btnView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *comboView;

@property (weak, nonatomic) IBOutlet UIButton *humanBtn;
@property (weak, nonatomic) IBOutlet UIButton *tempBtn;
@property (weak, nonatomic) IBOutlet UIButton *airBtn;


@property(nonatomic,strong) UILabel *label;
@property(nonatomic,assign) BOOL isCombo;
@property(nonatomic,strong) ACButtonView *btnSubView;

@property(nonatomic,strong) TableViewModel *tableVM;
@property(nonatomic,strong) NSMutableArray<CellDatas *> *datasArray;
@end

@implementation ACMainViewController

-(TableViewModel *)tableVM
{
    if (_tableVM == nil) {
        _tableVM = [[TableViewModel alloc] init];
    }
    return _tableVM;
}

-(UILabel *)label
{
    if (_label == nil) {
        _label = [[UILabel alloc] init];
    }
    
    return _label;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpUI];
}

-(void)setUpUI
{
    self.label.text = @"人数统计客户端";
//    自动设置了尺寸
    [self.label sizeToFit];
    self.label.textColor = [UIColor orangeColor];
    self.navigationItem.titleView = self.label;
    [self.navigationController.navigationBar setTintColor:[UIColor orangeColor]];

    ACButtonView *btnView = [ACButtonView getButtonView];
    btnView.frame = _btnView.bounds;
    [_btnView addSubview:btnView];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [btnView addGestureRecognizer:gesture];
    _isCombo = true;
    _btnSubView = btnView;
    
    [self hideBtns];
    
//    self.tableView.delegate = self.tableVM;
    self.tableView.delegate = self;
//    self.tableView.dataSource = self.tableVM;
    self.tableView.dataSource = self;
    self.tableVM.tableView = self.tableView;
    self.tableVM.view = self.view;
    
    RACSignal *sig = [self.tableVM.httpCommand execute:nil];
    
    [sig subscribeNext:^(NSMutableArray *x) {
        _datasArray = x;
    }];
}

-(void)hideBtns
{
    _humanBtn.transform = CGAffineTransformTranslate(_humanBtn.transform, 0, 246);
    _tempBtn.transform = CGAffineTransformTranslate(_tempBtn.transform, -102, 163);
    _airBtn.transform = CGAffineTransformTranslate(_airBtn.transform, 102, 163);
}

-(void)recoverView
{
    [UIView animateWithDuration:0.2 animations:^{
            _comboView.alpha = 0.0;
            
            [_label setAlpha:1];
            
            [self hideBtns];
        }];
        [_btnSubView turnOrign];
        _isCombo = YES;
}

-(void)tapAction
{
    if (_isCombo) {
        [UIView animateWithDuration:0.2 animations:^{
            _comboView.alpha = 0.9;
            
            [_label setAlpha:0];
            
            _humanBtn.transform = CGAffineTransformIdentity;
            _tempBtn.transform = CGAffineTransformIdentity;
            _airBtn.transform = CGAffineTransformIdentity;
        }];
        
        [_btnSubView turnSlop];
        _isCombo = NO;
    }else
    {
        [self recoverView];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ImageViewController *imgVc = [storyBoard instantiateViewControllerWithIdentifier:@"ImgVC"];
    [imgVc setUuid:_datasArray[indexPath.row].imgUuid];
    
    [self.navigationController pushViewController:imgVc animated:YES];
}

#pragma mark - tableView DateSourse
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_datasArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    CellDatas *cellDatas = _datasArray[indexPath.row];
    
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (IBAction)docAction:(id)sender {
    
}

- (IBAction)msgAction:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InformViewController *informVC = [storyBoard instantiateViewControllerWithIdentifier:@"InformVC"];
    
    [self.navigationController pushViewController:informVC animated:YES];
}

@end
