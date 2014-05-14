//
//  MessageCell_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 12.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "MessageCell_iPhone.h"

@implementation MessageCell_iPhone

@synthesize textLabel = _textLabel;
@synthesize detailTextLabel = _detailTextLabel;
@synthesize imageView = _imageView;
@synthesize messageTextLabel = _messageTextLabel;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
