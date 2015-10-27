//
//  EyesView.h
//  MotionEyes
//
//  Created by Brett Graham on 2015-10-11.
//  Copyright (c) 2015 Brett Graham. All rights reserved.
//  ----------------------------------------------------------------------------
//  THE BEER-WARE LICENSE" (Revision 42):
//  <brett.s.graham@gmail.com> wrote this file.  As long as you retain this notice you
//  can do whatever you want with this stuff. If we meet some day, and you think
//  this stuff is worth it, you can buy me a beer in return.   Brett Graham
//  ----------------------------------------------------------------------------
//

#import <UIKit/UIKit.h>


IB_DESIGNABLE

@interface EyesView : UIView

@property (nonatomic, retain) IBInspectable UIColor *eyeColor;
@property (nonatomic, retain) IBInspectable UIColor *pupilColor;

@property (nonatomic) IBInspectable CGFloat eyeSize;
@property (nonatomic) IBInspectable CGFloat pupilSize;

@property (nonatomic) IBInspectable CGPoint target;

@property (nonatomic) BOOL debugMode;

@end
