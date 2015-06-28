//
//  LGFilterView.h
//  LGFilterView
//
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Grigory Lutkov <Friend.LGA@gmail.com>
//  (https://github.com/Friend-LGA/LGFilterView)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <UIKit/UIKit.h>

@class LGFilterView;

static NSString *const kLGFilterViewWillShowNotification    = @"LGFilterViewWillShowNotification";
static NSString *const kLGFilterViewWillDismissNotification = @"LGFilterViewWillDismissNotification";
static NSString *const kLGFilterViewDidShowNotification     = @"LGFilterViewDidShowNotification";
static NSString *const kLGFilterViewDidDismissNotification  = @"LGFilterViewDidDismissNotification";

static CGFloat const kLGFilterViewWidthMargin = 8.f;
static CGFloat const kLGFilterViewWidth       = (320.f-kLGFilterViewWidthMargin*2);

@protocol LGFilterViewDelegate <NSObject>

@optional

- (void)filterViewWillShow:(LGFilterView *)filterView;
- (void)filterViewWillDismiss:(LGFilterView *)filterView;
- (void)filterViewDidShow:(LGFilterView *)filterView;
- (void)filterViewDidDismiss:(LGFilterView *)filterView;
- (void)filterView:(LGFilterView *)filterView buttonPressedWithTitle:(NSString *)title index:(NSUInteger)index;
- (void)filterViewCancelled:(LGFilterView *)filterView;

@end

@interface LGFilterView : UIView

typedef enum
{
    LGFilterViewTransitionStyleTop    = 0,
    LGFilterViewTransitionStyleCenter = 1
}
LGFilterViewTransitionStyle;

@property (assign, nonatomic) LGFilterViewTransitionStyle transitionStyle;

@property (assign, nonatomic, getter=isShowing) BOOL showing;

@property (assign, nonatomic) NSInteger selectedIndex;

@property (assign, nonatomic) CGPoint      offset;
@property (assign, nonatomic) UIEdgeInsets contentInset;
@property (assign, nonatomic) CGFloat      heightMax;

@property (assign, nonatomic, getter=isSeparatorsVisible) BOOL separatorsVisible;
@property (strong, nonatomic) UIColor      *separatorsColor;
@property (assign, nonatomic) UIEdgeInsets separatorsEdgeInsets;

@property (strong, nonatomic) UIColor *titleColor;
@property (strong, nonatomic) UIColor *titleColorHighlighted;
@property (strong, nonatomic) UIColor *titleColorSelected;

@property (strong, nonatomic) UIColor *backgroundColorHighlighted;
@property (strong, nonatomic) UIColor *backgroundColorSelected;

@property (strong, nonatomic) UIFont          *font;
@property (assign, nonatomic) NSUInteger      numberOfLines;
@property (assign, nonatomic) NSLineBreakMode lineBreakMode;
@property (assign, nonatomic) NSTextAlignment textAlignment;
@property (assign, nonatomic) BOOL            adjustsFontSizeToFitWidth;
@property (assign, nonatomic) CGFloat         minimumScaleFactor;

@property (assign, nonatomic) CGFloat cornerRadius;
@property (assign, nonatomic) CGFloat borderWidth;
@property (strong, nonatomic) UIColor *borderColor;

@property (assign, nonatomic) UIScrollViewIndicatorStyle indicatorStyle;

/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^willShowHandler)(LGFilterView *filterView);
/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^willDismissHandler)(LGFilterView *filterView);
/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^didShowHandler)(LGFilterView *filterView);
/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^didDismissHandler)(LGFilterView *filterView);

/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^actionHandler)(LGFilterView *filterView, NSString *title, NSUInteger index);
/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^cancelHandler)(LGFilterView *filterView);

@property (assign, nonatomic) id<LGFilterViewDelegate> delegate;

/** View can not be subclass of UIScrollView */
- (instancetype)initWithView:(UIView *)view;
- (instancetype)initWithTitles:(NSArray *)titles;

/** View can not be subclass of UIScrollView */
+ (instancetype)filterViewWithView:(UIView *)view;
+ (instancetype)filterViewWithTitles:(NSArray *)titles;

#pragma amrk -

/**
 View can not be subclass of UIScrollView
 Do not forget about weak referens to self for cancelHandler blocks
 */
- (instancetype)initWithView:(UIView *)view
               cancelHandler:(void(^)(LGFilterView *filterView))cancelHandler;

/** Do not forget about weak referens to self for actionHandler and cancelHandler blocks */
- (instancetype)initWithTitles:(NSArray *)titles
                 actionHandler:(void(^)(LGFilterView *filterView, NSString *title, NSUInteger index))actionHandler
                 cancelHandler:(void(^)(LGFilterView *filterView))cancelHandler;

/**
 View can not be subclass of UIScrollView
 Do not forget about weak referens to self for cancelHandler blocks
 */
+ (instancetype)filterViewWithView:(UIView *)view
                     cancelHandler:(void(^)(LGFilterView *filterView))cancelHandler;

/** Do not forget about weak referens to self for actionHandler and cancelHandler blocks */
+ (instancetype)filterViewWithTitles:(NSArray *)titles
                       actionHandler:(void(^)(LGFilterView *filterView, NSString *title, NSUInteger index))actionHandler
                       cancelHandler:(void(^)(LGFilterView *filterView))cancelHandler;

#pragma mark -

/** View can not be subclass of UIScrollView */
- (instancetype)initWithView:(UIView *)view
                    delegate:(id<LGFilterViewDelegate>)delegate;

- (instancetype)initWithTitles:(NSArray *)titles
                      delegate:(id<LGFilterViewDelegate>)delegate;

/** View can not be subclass of UIScrollView */
+ (instancetype)filterViewWithView:(UIView *)view
                          delegate:(id<LGFilterViewDelegate>)delegate;

+ (instancetype)filterViewWithTitles:(NSArray *)titles
                            delegate:(id<LGFilterViewDelegate>)delegate;

#pragma mark -

/** View can not be subclass of UIScrollView */
- (void)showInView:(UIView *)view animated:(BOOL)animated completionHandler:(void(^)())completionHandler;
- (void)dismissAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler;

#pragma mark -

/** Unavailable, use +filterViewWith... instead */
+ (instancetype)new __attribute__((unavailable("use +filterViewWith... instead")));
/** Unavailable, use -initWith... instead */
- (instancetype)init __attribute__((unavailable("use -initWith... instead")));
/** Unavailable, use -initWith... instead */
- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("use -initWith... instead")));

@end
