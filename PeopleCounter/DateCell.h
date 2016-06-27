//
//  DateCell.h
//  PeopleCounter
//
//  Created by Air_chen on 16/6/20.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CellDatas;

@interface DateCell : UITableViewCell

-(void)setImage:(UIImage *)image andLabel:(NSString *) date;
-(void)setData:(CellDatas *) cellData;

@end
