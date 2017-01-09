//
//  InformViewController.m
//  PeopleCounter
//
//  Created by Air_chen on 16/6/29.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "InformViewController.h"
#import "InformViewModel.h"

#define SCROLLHEIGHT self.scrollView.bounds.size.height
#define SCROLLWIDTH self.scrollView.bounds.size.width

@interface InformViewController ()
@property (nonatomic, readwrite, strong) InformViewModel *informVM;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightContraint;

@end

@implementation InformViewController

- (InformViewModel *)informVM
{
    if (_informVM == nil) {
        _informVM = [[InformViewModel alloc] init];
    }
    return _informVM;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"发送消息";
    //    自动设置了尺寸
    [label sizeToFit];
    label.textColor = [UIColor orangeColor];
    self.navigationItem.titleView = label;
    
    self.informVM.nameTextField = self.nameTextField;
    self.informVM.detailTextView = self.detailTextView;
    self.informVM.heightContraint = self.heightContraint;
    self.informVM.sendBtn = self.sendBtn;
    
    self.informVM.viewController = self;

    
    [[self.informVM.informCommand execute:nil] subscribeNext:^(RACTuple* x) {
                
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
