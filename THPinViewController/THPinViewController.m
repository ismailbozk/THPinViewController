//
//  THPinViewController.m
//  THPinViewController
//
//  Created by Thomas Heß on 11.4.14.
//  Copyright (c) 2014 Thomas Heß. All rights reserved.
//

#import "THPinViewController.h"
#import "THPinView.h"
#import "UIImage+ImageEffects.h"

@interface THPinViewController () <THPinViewDelegate>

@property (nonatomic, strong) THPinView *pinView;
@property (nonatomic, strong) UIView *blurView;
@property (nonatomic, strong) NSArray *blurViewContraints;

@end

@implementation THPinViewController

@synthesize cancelColor = _cancelColor;
@synthesize cancelTitle = _cancelTitle;
@synthesize deleteColor = _deleteColor;
@synthesize deleteTitle = _deleteTitle;

- (instancetype)initWithDelegate:(id<THPinViewControllerDelegate>)delegate
{
    self = [self init];
    if (self) {
        _delegate = delegate;
        _backgroundColor = [UIColor whiteColor];
        _translucentBackground = NO;
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"THPinViewController"
                                                                                    ofType:@"bundle"]];
        _promptTitle = NSLocalizedStringFromTableInBundle(@"prompt_title", @"THPinViewController", bundle, nil);
        _backgroundBlurStyle = UIBlurEffectStyleExtraLight;
        
        _pinView.backgroundColor = [UIColor clearColor];
        self.view.backgroundColor = [UIColor clearColor];
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.translucentBackground) {
        self.view.backgroundColor = [UIColor clearColor];
        [self addBlurView];
    } else {
        self.view.backgroundColor = self.backgroundColor;
    }
    
    self.pinView = [[THPinView alloc] initWithDelegate:self];
    self.pinView.backgroundColor = self.view.backgroundColor;
    self.pinView.promptTitle = self.promptTitle;
    self.pinView.promptColor = self.promptColor;
    self.pinView.hideLetters = self.hideLetters;
    self.pinView.disableCancel = self.disableCancel;
    self.pinView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.pinView];
    // center pin view
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pinView attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f constant:0.0f]];
    CGFloat pinViewYOffset = 0.0f;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        pinViewYOffset = -9.0f;
    } else {
        BOOL isFourInchScreen = (fabs(CGRectGetHeight([[UIScreen mainScreen] bounds]) - 568.0f) < DBL_EPSILON);
        if (isFourInchScreen) {
            pinViewYOffset = 25.5f;
        } else {
            pinViewYOffset = 18.5f;
        }
    }
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pinView attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f constant:pinViewYOffset]];
}

#pragma mark - Properties

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if ([self.backgroundColor isEqual:backgroundColor]) {
        return;
    }
    _backgroundColor = backgroundColor;
    if (! self.translucentBackground) {
        self.view.backgroundColor = self.backgroundColor;
        self.pinView.backgroundColor = self.backgroundColor;
    }
}

- (void)setTranslucentBackground:(BOOL)translucentBackground
{
    if (self.translucentBackground == translucentBackground) {
        return;
    }
    _translucentBackground = translucentBackground;
    if (self.translucentBackground) {
        self.view.backgroundColor = [UIColor clearColor];
        self.pinView.backgroundColor = [UIColor clearColor];
        [self addBlurView];
    } else {
        self.view.backgroundColor = self.backgroundColor;
        self.pinView.backgroundColor = self.backgroundColor;
        [self removeBlurView];
    }
}

- (void)setBackgroundBlurStyle:(UIBlurEffectStyle)backgroundBlurStyle
{
    if (_backgroundBlurStyle != backgroundBlurStyle)
    {
        _backgroundBlurStyle = backgroundBlurStyle;
        
        [self removeBlurView];
        [self addBlurView];
    }
}

- (void)setPromptTitle:(NSString *)promptTitle
{
    if ([self.promptTitle isEqualToString:promptTitle]) {
        return;
    }
    _promptTitle = [promptTitle copy];
    self.pinView.promptTitle = self.promptTitle;
}

- (void)setPromptColor:(UIColor *)promptColor
{
    if ([self.promptColor isEqual:promptColor]) {
        return;
    }
    _promptColor = promptColor;
    self.pinView.promptColor = self.promptColor;
}

- (void)setHideLetters:(BOOL)hideLetters
{
    if (self.hideLetters == hideLetters) {
        return;
    }
    _hideLetters = hideLetters;
    self.pinView.hideLetters = self.hideLetters;
}

- (void)setDisableCancel:(BOOL)disableCancel
{
    if (self.disableCancel == disableCancel) {
        return;
    }
    _disableCancel = disableCancel;
    self.pinView.disableCancel = self.disableCancel;
}

- (void)setCancelTitle:(NSString *)cancelTitle
{
    [self.pinView setCancelTitle:cancelTitle];
}

- (NSString *)cancelTitle
{
    return self.pinView.cancelTitle;
}

- (void)setCancelColor:(UIColor *)cancelColor
{
    [self.pinView setCancelColor:cancelColor];
}

- (UIColor *)cancelColor
{
    return self.pinView.cancelColor;
}

- (void)setDeleteTitle:(NSString *)deleteTitle
{
    [self.pinView setDeleteTitle:deleteTitle];
}

- (NSString *)deleteTitle
{
    return self.pinView.deleteTitle;
}

- (void)setDeleteColor:(UIColor *)deleteColor
{
    [self.pinView setDeleteColor:deleteColor];
}

- (UIColor *)deleteColor
{
    return self.pinView.deleteColor;
}

#pragma mark - Blur

- (void)addBlurView
{
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:self.backgroundBlurStyle];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:self.blurView belowSubview:self.pinView];
    NSDictionary *views = @{ @"blurView" : self.blurView };
    NSMutableArray *constraints =
    [NSMutableArray arrayWithArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[blurView]|"
                                                                           options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[blurView]|"
                                                                             options:0 metrics:nil views:views]];
    self.blurViewContraints = constraints;
    [self.view addConstraints:self.blurViewContraints];
}

- (void)removeBlurView
{
    [self.blurView removeFromSuperview];
    self.blurView = nil;
    [self.view removeConstraints:self.blurViewContraints];
    self.blurViewContraints = nil;
}

#pragma mark - THPinViewDelegate

- (NSUInteger)pinLengthForPinView:(THPinView *)pinView
{
    NSUInteger pinLength = [self.delegate pinLengthForPinViewController:self];
    NSAssert(pinLength > 0, @"PIN length must be greater than 0");
    return MAX(pinLength, (NSUInteger)1);
}

- (BOOL)pinView:(THPinView *)pinView isPinValid:(NSString *)pin
{
    return [self.delegate pinViewController:self isPinValid:pin];
}

- (void)cancelButtonTappedInPinView:(THPinView *)pinView
{
    if ([self.delegate respondsToSelector:@selector(pinViewControllerWillDismissAfterPinEntryWasCancelled:)]) {
        [self.delegate pinViewControllerWillDismissAfterPinEntryWasCancelled:self];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(pinViewControllerDidDismissAfterPinEntryWasCancelled:)]) {
            [self.delegate pinViewControllerDidDismissAfterPinEntryWasCancelled:self];
        }
    }];
}

- (void)correctPinWasEnteredInPinView:(THPinView *)pinView
{
    if ([self.delegate respondsToSelector:@selector(pinViewControllerWillDismissAfterPinEntryWasSuccessful:)]) {
        [self.delegate pinViewControllerWillDismissAfterPinEntryWasSuccessful:self];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(pinViewControllerDidDismissAfterPinEntryWasSuccessful:)]) {
            [self.delegate pinViewControllerDidDismissAfterPinEntryWasSuccessful:self];
        }
    }];
}

- (void)incorrectPinWasEnteredInPinView:(THPinView *)pinView
{
    if ([self.delegate userCanRetryInPinViewController:self]) {
        if ([self.delegate respondsToSelector:@selector(incorrectPinEnteredInPinViewController:)]) {
            [self.delegate incorrectPinEnteredInPinViewController:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(pinViewControllerWillDismissAfterPinEntryWasUnsuccessful:)]) {
            [self.delegate pinViewControllerWillDismissAfterPinEntryWasUnsuccessful:self];
        }
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(pinViewControllerDidDismissAfterPinEntryWasUnsuccessful:)]) {
                [self.delegate pinViewControllerDidDismissAfterPinEntryWasUnsuccessful:self];
            }
        }];
    }
}

@end
