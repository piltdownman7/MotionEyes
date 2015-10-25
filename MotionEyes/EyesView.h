//
//  EyesView.h
//  MotionEyes
//
//  Created by Brett Graham on 2015-10-11.
//  Copyright (c) 2015 Brett Graham. All rights reserved.
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
