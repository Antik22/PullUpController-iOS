//
//  PullUpView.m
//  TouchTests-ios
//
//  Created by Tony Hrabovskyi on 12/13/17.
//  Copyright © 2017 Tony Hrabovskyi. All rights reserved.
//

#import "PullUpController.h"

@interface PullUpController() <UIGestureRecognizerDelegate>

@property (nonatomic) CGFloat minHeight;
@property (nonatomic) CGFloat maxHeight;
@property (nonatomic) CGFloat maxSwipeOffset;

@property (nonatomic) CGFloat minY;
@property (nonatomic) CGFloat maxY;
@property (nonatomic) CGFloat centerY;

@property (nonatomic) CGFloat prevYPos;
@property (nonatomic) CGFloat prevYTranslation;

@property (nonatomic) BOOL isOpening;
@property (nonatomic) BOOL isClosing;

@end

@implementation PullUpController

- (instancetype)initWithSuperview:(UIView *)superview
                     headerHeight:(CGFloat)headerHeight
                  conteinerHeight:(CGFloat)conteinerHeight
                   maxSwipeOffset:(CGFloat)maxSwipeOffset {
    
    self = [super init];
    if (self) {
        _transitionDuration = 0.5F;
        _maxSwipeOffset = maxSwipeOffset;
        _isOpen = false;
        
        _minHeight = headerHeight;
        _maxHeight = headerHeight + conteinerHeight;
        
        _minY = superview.frame.size.height - _minHeight;
        _maxY = superview.frame.size.height - _maxHeight;
        _centerY = (_minY + _maxY) / 2;
        
        [self setFrame:CGRectMake(0, superview.frame.size.height - _minHeight,
                                  superview.frame.size.width, _maxHeight + _maxSwipeOffset)];
        
        [superview addSubview:self];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self addGestureRecognizer:panGesture];
        
        [self initHeaderView];
        [self initContentView];
        [self roundTopCorners];
        
        
    }
    return self;
}

- (void)initHeaderView {
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, _minHeight)];
    _headerView.backgroundColor = UIColor.clearColor;;
    [self addSubview:_headerView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleHeaderTap:)];
    tapGesture.delegate = self;
    [_headerView addGestureRecognizer:tapGesture];
}

- (void)initContentView {
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, _minHeight, self.bounds.size.width, _maxHeight - _minHeight)];
    _contentView.backgroundColor = UIColor.clearColor;
    [self addSubview:_contentView];
}

- (void)roundTopCorners {
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.bounds
                                           byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight
                                                 cornerRadii: (CGSize){10.0, 10.0}].CGPath;
    
    self.layer.mask = maskLayer;
}

#pragma mark - UIGestureRecognizerDelegate

- (void)handleHeaderTap:(UITapGestureRecognizer *)gesture {
    
    if ([self.delegate respondsToSelector:@selector(headerDidTap)]) {
        [self.delegate headerDidTap];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    
    CGFloat YPos = self.frame.origin.y;
    CGFloat YTranlation = [gesture translationInView:self].y;
    
    CGFloat deltaTranslation = YTranlation - _prevYTranslation;
    CGFloat targetHeight = [self YPos] + deltaTranslation;
    
    switch (gesture.state) {
            
        case UIGestureRecognizerStateChanged:
            
            if (targetHeight <= _minY && targetHeight >= _maxY)
                [self setYPos:targetHeight];
            else if (targetHeight < _maxY && targetHeight >= 0) {
                float multiplier = 1.0f - (MIN(_maxY - targetHeight, _maxSwipeOffset) / _maxSwipeOffset);
                targetHeight = [self YPos] + deltaTranslation * multiplier / 3;
                [self setYPos:targetHeight];
            }
            
            break;
            
        case UIGestureRecognizerStateEnded:

            if (YPos - _prevYPos < -1)
                [self openConteiner];
            else if (YPos - _prevYPos > 1)
                [self closeConteiner];
            else {
                if (self.frame.origin.y > _centerY) {
                    [self closeConteiner];
                } else {
                    [self openConteiner];
                }
            }
            
            break;
            
        default:
            break;
    }
    
    _prevYPos = YPos;
    _prevYTranslation = YTranlation;
}

- (void)openConteiner {
    
    if (_isOpening)
        return;
    
    _isOpening = true;
    CGRect targetFrame = self.frame;
    targetFrame.origin.y = _maxY;
    
    [UIView animateWithDuration:_transitionDuration
                          delay:0.0F
         usingSpringWithDamping:0.7F
          initialSpringVelocity:0.5F
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.frame = targetFrame;
                     }
                     completion:^(BOOL finished){
                         _isOpening = false;
                         if (finished && _delegate != nil)
                         {
                             _isOpen = true;
                             [_delegate conteinerDidOpen];
                         }
                     }];
}

- (void)closeConteiner {
    
    if (_isClosing)
        return;
    
    _isClosing = true;
    CGRect targetFrame = self.frame;
    targetFrame.origin.y = _minY;
    
    [UIView animateWithDuration:_transitionDuration
                          delay:0.0F
         usingSpringWithDamping:0.7F
          initialSpringVelocity:0.5F
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.frame = targetFrame;
                     }
                     completion:^(BOOL finished){
                         _isClosing = false;
                         if (finished && _delegate != nil)
                         {
                             _isOpen = false;
                             [_delegate conteinerDidClose];
                         }
                     }];
}

- (void)translatePanel:(CGFloat) deltaHeight {
    [self setYPos:self.frame.origin.y + deltaHeight];
}

- (CGFloat)YPos {
    return self.frame.origin.y;
}

- (void)setYPos:(CGFloat) newY {
    CGRect frame = self.frame;
    frame.origin.y = newY;
    self.frame = frame;
}


@end
