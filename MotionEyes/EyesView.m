//
//  EyesView.m
//  MotionEyes
//
//  Created by Brett Graham on 2015-10-11.
//  Copyright (c) 2015 Brett Graham. All rights reserved.
//

#import "EyesView.h"

@implementation EyesView

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];

  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
  CGContextFillRect(context, rect);

  // target
  CGFloat xPercent = self.target.x / rect.size.width;
  CGFloat yPercent = self.target.y / rect.size.height;

  // Eyes
  CGContextSetFillColorWithColor(context, self.eyeColor.CGColor);
  CGFloat yEye = (rect.size.height - self.eyeSize) / 2.0f;

  // Left Eyes
  // left for far edge, right to own width + right eye
  CGFloat leftEye = 0 + xPercent * (rect.size.width - 2.0f * self.eyeSize);
  CGRect leftFrame = CGRectMake(leftEye, yEye, self.eyeSize, self.eyeSize);
  CGContextFillEllipseInRect(context, leftFrame);

  // Right Eye
  // Left the width or the other eye, and far edge minus own width on the right
  CGFloat rightEye = (1.0F * self.eyeSize) +
                     xPercent * (rect.size.width - 2.0f * self.eyeSize);
  CGRect rightFrame = CGRectMake(rightEye, yEye, self.eyeSize, self.eyeSize);
  CGContextFillEllipseInRect(context, rightFrame);

  // Pupils
  if (xPercent + yPercent <= 0) {
    xPercent = 0.5f;
    yPercent = 0.5f;
  }

  CGContextSetFillColorWithColor(context, self.pupilColor.CGColor);

  // Left eye pupil
  CGPoint leftCenter =
      CGPointMake(CGRectGetMidX(leftFrame), CGRectGetMidY(leftFrame));
  CGFloat angleLeft = M_PI_2 - atan2f(self.target.y - leftCenter.y,
                                      self.target.x - leftCenter.x);
  CGFloat leftRadius = sqrt((leftCenter.x - self.target.x)*(leftCenter.x - self.target.x) + (leftCenter.y - self.target.y)*(leftCenter.y - self.target.y));
  leftRadius = MIN(leftRadius, self.eyeSize / 2.0f - self.pupilSize / 2.0f);
  CGPoint leftPupilCenter =
      CGPointMake(leftCenter.x + leftRadius * sin(angleLeft),
                  leftCenter.y + leftRadius * cos(angleLeft));
  CGRect leftPupilFrame = CGRectMake(leftPupilCenter.x - self.pupilSize / 2.0,
                                     leftPupilCenter.y - self.pupilSize / 2.0,
                                     self.pupilSize, self.pupilSize);
  CGContextFillEllipseInRect(context, leftPupilFrame);

  // Right eye pupil
  CGPoint rightCenter =
      CGPointMake(CGRectGetMidX(rightFrame), CGRectGetMidY(rightFrame));
  CGFloat angleRight = M_PI_2 - atan2f(self.target.y - rightCenter.y,
                                       self.target.x - rightCenter.x);
  CGFloat rightRadius = sqrt((rightCenter.x - self.target.x)*(rightCenter.x - self.target.x) + (rightCenter.y - self.target.y)*(rightCenter.y - self.target.y));
  rightRadius = MIN(rightRadius, self.eyeSize / 2.0f - self.pupilSize / 2.0f);
  CGPoint rightPupilCenter =
      CGPointMake(rightCenter.x + rightRadius * sin(angleRight),
                  rightCenter.y + rightRadius * cos(angleRight));
  CGRect rightPupilFrame = CGRectMake(rightPupilCenter.x - self.pupilSize / 2.0,
                                      rightPupilCenter.y - self.pupilSize / 2.0,
                                      self.pupilSize, self.pupilSize);
  CGContextFillEllipseInRect(context, rightPupilFrame);

  if (self.debugMode) {
    CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
    CGRect targetFrame =
        CGRectMake(self.target.x - 25, self.target.y - 25, 50, 50);
    CGContextFillEllipseInRect(context, targetFrame);
  }
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [self setNeedsDisplay];
}

- (void)setTarget:(CGPoint)target {
  _target = target;
  [self setNeedsDisplay];
}

@end
