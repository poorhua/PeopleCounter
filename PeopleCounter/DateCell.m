//
//  DateCell.m
//  PeopleCounter
//
//  Created by Air_chen on 16/6/20.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "DateCell.h"
#import "CellDatas.h"

@interface DateCell()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *dateLab;
@property (nonatomic,strong) NSArray *imgArray;

@end

@implementation DateCell

-(NSArray *)imgArray
{
    if (_imgArray == nil) {
        _imgArray = @[
                      @"zero.png",
                      @"one.png",
                      @"two.png",
                      @"three.png",
                      @"four.png",
                      @"five.png",
                      @"six.png",
                      @"seven.png",
                      @"eight.png",
                      @"night.png",
                      @"ten.png"
                      ];
    }
    return _imgArray;
}

-(void)setImage:(UIImage *)image andLabel:(NSString *)date
{
    self.imageView.image = image;
    self.dateLab.text = date;
}

-(void)setData:(CellDatas *)cellData
{
    NSInteger imgIndex = [[cellData recogNumsStr] integerValue];
    
    NSRange range;
    range.location = 11;
    range.length = 8;
    NSString *str = [[cellData dateTimeStr] substringWithRange:range];
    
    [self setImage:[UIImage imageNamed:self.imgArray[imgIndex]] andLabel:str];
}

@end
