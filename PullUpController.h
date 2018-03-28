//
//  PullUpView.h
//  TouchTests-ios
//
//  Created by Tony Hrabovskyi on 12/13/17.
//  Copyright © 2017 Tony Hrabovskyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PullUpDelegate <NSObject>

- (void)conteinerDidOpen;
- (void)conteinerDidClose;

@optional
- (void)headerDidTap;

@end

@interface PullUpController : UIView

@property (weak, nonatomic) id<PullUpDelegate> delegate;

@property (nonatomic, readonly) BOOL isOpen;
@property (nonatomic) CGFloat transitionDuration;
@property (nonatomic, strong, readonly) UIView *headerView;
@property (nonatomic, strong, readonly) UIView *contentView;

- (instancetype)initWithSuperview:(UIView *)superview
                     headerHeight:(CGFloat)headerHeight
                  conteinerHeight:(CGFloat)conteinerHeight
                   maxSwipeOffset:(CGFloat)maxSwipeOffset;

- (void)openConteiner;
- (void)closeConteiner;

@end
