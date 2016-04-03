//
//  THPinView.h
//  THPinViewControllerExample
//
//  Created by Thomas Heß on 21.4.14.
//  Copyright (c) 2014 Thomas Heß. All rights reserved.
//

@import UIKit;
#import "THPinViewControllerMacros.h"

@class THPinView;

@protocol THPinViewDelegate <NSObject>

@required
- (NSUInteger)pinLengthForPinView:(THPinView *)pinView;
- (BOOL)pinView:(THPinView *)pinView isPinValid:(NSString *)pin;
- (void)cancelButtonTappedInPinView:(THPinView *)pinView;
- (void)correctPinWasEnteredInPinView:(THPinView *)pinView;
- (void)incorrectPinWasEnteredInPinView:(THPinView *)pinView;

@end

@interface THPinView : UIView

@property (nonatomic, weak) id<THPinViewDelegate> delegate;
@property (nonatomic, copy) NSString *promptTitle;
@property (nonatomic, strong) UIColor *promptColor;
@property (nonatomic, assign) BOOL hideLetters;
@property (nonatomic, assign) BOOL disableCancel;
@property (nonatomic, strong) UIColor *cancelColor;
@property (nonatomic, copy) NSString *cancelTitle;
@property (nonatomic, strong) UIColor *deleteColor;
@property (nonatomic, copy) NSString *deleteTitle;

- (instancetype)initWithDelegate:(id<THPinViewDelegate>)delegate;

@end
