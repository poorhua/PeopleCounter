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


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonConstraint;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (strong, nonatomic) IBOutlet UIControl *viewControl;
@property (weak, nonatomic) IBOutlet UITextView *inputTextField;
@property (weak, nonatomic) IBOutlet UITextView *transTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *transBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property(nonatomic,strong) InformViewModel *informVM;

@end

@implementation InformViewController

-(InformViewModel *)informVM
{
    if (_informVM == nil) {
        _informVM = [[InformViewModel alloc] init];
    }
    return _informVM;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
    self.informVM.buttonConstraint = self.buttonConstraint;
    self.informVM.stackView = self.stackView;
    self.informVM.inputTextField = self.inputTextField;
    self.informVM.transTextField = self.transTextField;
    self.informVM.nameTextField = self.nameTextField;
    self.informVM.transBtn = self.transBtn;
    self.informVM.sendBtn = self.sendBtn;
    self.informVM.viewControl = self.viewControl;
    
    [self.informVM.informCommand execute:nil];
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
