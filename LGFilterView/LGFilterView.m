//
//  LGFilterView.m
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

#import "LGFilterView.h"
#import "LGFilterViewCell.h"

static CGFloat const kLGFilterViewInnerMarginW = 10.f;
static CGFloat const kLGFilterViewInnerMarginH = 5.f;

@interface LGFilterView () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (assign, nonatomic, getter=isObserversAdded) BOOL observersAdded;

@property (assign, nonatomic) UIView *parentView;
@property (strong, nonatomic) UIView *backgroundView;

@property (strong, nonatomic) UITableView  *tableView;
@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) UIView  *innerView;

@property (strong, nonatomic) UIColor *backgroundColorNormal;

@end

@implementation LGFilterView

- (instancetype)initWithView:(UIView *)view
{
    self = [super init];
    if (self)
    {
        if ([view isKindOfClass:[UIScrollView class]])
            NSLog(@"LGFilterView: WARNING !!! view can not be subclass of UIScrollView !!!");
        
        // -----
        
        _innerView = view;
        
        [self setupDefaults];
    }
    return self;
}

- (instancetype)initWithTitles:(NSArray *)titles
{
    self = [super init];
    if (self)
    {
        _titles = titles;
        
        [self setupDefaults];
    }
    return self;
}

+ (instancetype)filterViewWithView:(UIView *)view
{
    return [[self alloc] initWithView:view];
}

+ (instancetype)filterViewWithTitles:(NSArray *)titles
{
    return [[self alloc] initWithTitles:titles];
}

#pragma mark -

- (instancetype)initWithView:(UIView *)view
               cancelHandler:(void(^)(LGFilterView *filterView))cancelHandler
{
    self = [self initWithView:view];
    if (self)
    {
        _cancelHandler = cancelHandler;
    }
    return self;
}

- (instancetype)initWithTitles:(NSArray *)titles
                 actionHandler:(void(^)(LGFilterView *filterView, NSString *title, NSUInteger index))actionHandler
                 cancelHandler:(void(^)(LGFilterView *filterView))cancelHandler
{
    self = [self initWithTitles:titles];
    if (self)
    {
        _actionHandler = actionHandler;
        _cancelHandler = cancelHandler;
    }
    return self;
}

+ (instancetype)filterViewWithView:(UIView *)view
                     cancelHandler:(void(^)(LGFilterView *filterView))cancelHandler
{
    return [[self alloc] initWithView:view
                        cancelHandler:cancelHandler];
}

+ (instancetype)filterViewWithTitles:(NSArray *)titles
                       actionHandler:(void(^)(LGFilterView *filterView, NSString *title, NSUInteger index))actionHandler
                       cancelHandler:(void(^)(LGFilterView *filterView))cancelHandler
{
    return [[self alloc] initWithTitles:titles
                          actionHandler:actionHandler
                          cancelHandler:cancelHandler];
}

#pragma mark -

- (instancetype)initWithView:(UIView *)view
                    delegate:(id<LGFilterViewDelegate>)delegate
{
    self = [self initWithView:view];
    if (self)
    {
        _delegate = delegate;
    }
    return self;
}

- (instancetype)initWithTitles:(NSArray *)titles
                      delegate:(id<LGFilterViewDelegate>)delegate
{
    self = [self initWithTitles:titles];
    if (self)
    {
        _delegate = delegate;
    }
    return self;
}

+ (instancetype)filterViewWithView:(UIView *)view
                          delegate:(id<LGFilterViewDelegate>)delegate
{
    return [[self alloc] initWithView:view
                             delegate:delegate];
}

+ (instancetype)filterViewWithTitles:(NSArray *)titles
                            delegate:(id<LGFilterViewDelegate>)delegate
{
    return [[self alloc] initWithTitles:titles
                               delegate:delegate];
}

- (void)setupDefaults
{
    _transitionStyle = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGFilterViewTransitionStyleTop : LGFilterViewTransitionStyleCenter);
    
    _selectedIndex = -1;
    
    _separatorsVisible = YES;
    _separatorsColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.f];
    _separatorsEdgeInsets = UIEdgeInsetsMake(0.f, 10.f, 0.f, 10.f);
    
    _titleColor = [UIColor colorWithRed:0.f green:0.5 blue:1.f alpha:1.f];
    _titleColorHighlighted = [UIColor colorWithRed:0.f green:0.5 blue:1.f alpha:1.f];
    _titleColorSelected = [UIColor whiteColor];
    
    self.backgroundColor = [UIColor whiteColor];
    _backgroundColorHighlighted = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.f];
    _backgroundColorSelected = [UIColor colorWithRed:0.f green:0.5 blue:1.f alpha:1.f];
    
    _font = [UIFont systemFontOfSize:20.f];
    _numberOfLines = 1;
    _lineBreakMode = NSLineBreakByTruncatingMiddle;
    _textAlignment = NSTextAlignmentCenter;
    _adjustsFontSizeToFitWidth = YES;
    _minimumScaleFactor = 14.f/20.f;
    
    _cornerRadius = 5.f;
    _borderColor = nil;
    _borderWidth = 0.f;
    
    _indicatorStyle = UIScrollViewIndicatorStyleBlack;
    
    // -----
    
    _backgroundView = [UIView new];
    _backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _backgroundView.alpha = 0.f;
    [self addSubview:_backgroundView];
    
    // -----
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAction)];
    tapGesture.delegate = self;
    [_backgroundView addGestureRecognizer:tapGesture];
}

#pragma mark - Dealloc

- (void)dealloc
{
#if DEBUG
    NSLog(@"%s [Line %d]", __PRETTY_FUNCTION__, __LINE__);
#endif
}

#pragma mark -

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (!newSuperview)
        [self removeObservers];
    else
        [self addObservers];
}

#pragma mark - Setters and Getters

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:[UIColor clearColor]];
    
    _backgroundColorNormal = backgroundColor;
    
    if (_tableView)
        _tableView.backgroundColor = backgroundColor;
    else if (_scrollView)
        _scrollView.backgroundColor = backgroundColor;
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_contentInset, contentInset))
    {
        _contentInset = contentInset;
        
        [self layoutInvalidate];
    }
}

- (void)setOffset:(CGPoint)offset
{
    if (!CGPointEqualToPoint(_offset, offset))
    {
        _offset = offset;
        
        [self layoutInvalidate];
    }
}

#pragma mark -

- (void)showInView:(UIView *)view
          animated:(BOOL)animated
 completionHandler:(void(^)())completionHandler;
{
    if (self.isShowing) return;
    
    _parentView = view;
    
    [self subviewsInvalidate];
    [self layoutInvalidate];
    
    _showing = YES;
    
    // -----
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLGFilterViewWillShowNotification object:self userInfo:nil];
    
    if (_willShowHandler) _willShowHandler(self);
    
    if (_delegate && [_delegate respondsToSelector:@selector(filterViewWillShow:)])
        [_delegate filterViewWillShow:self];
    
    // -----
    
    if (animated)
    {
        [self getParametersFromPresentation];
        
        [LGFilterView animateStandardWithAnimations:^(void)
         {
             [self showAnimations];
         }
                                         completion:^(BOOL finished)
         {
             if (finished)
             {
                 [self showComplete];
                 
                 if (completionHandler) completionHandler();
             }
         }];
        
    }
    else
    {
        [self showAnimations];
        
        [self showComplete];
        
        if (completionHandler) completionHandler();
    }
}

- (void)showAnimations
{
    UIScrollView *scrollView = nil;
    
    if (_tableView)
        scrollView = _tableView;
    else if (_scrollView)
        scrollView = _scrollView;
    
    // -----
    
    _backgroundView.alpha = 1.f;
    
    if (_transitionStyle == LGFilterViewTransitionStyleCenter)
    {
        scrollView.transform = CGAffineTransformIdentity;
        scrollView.alpha = 1.f;
    }
    else scrollView.center = CGPointMake(scrollView.center.x, scrollView.frame.size.height/2);
}

- (void)showComplete
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kLGFilterViewDidShowNotification object:self userInfo:nil];
    
    if (_didShowHandler) _didShowHandler(self);
    
    if (_delegate && [_delegate respondsToSelector:@selector(filterViewDidShow:)])
        [_delegate filterViewDidShow:self];
}

#pragma mark -

- (void)dismissAnimated:(BOOL)animated
      completionHandler:(void(^)())completionHandler
{
    if (!self.isShowing) return;
    
    _showing = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLGFilterViewWillDismissNotification object:self userInfo:nil];
    
    if (_willDismissHandler) _willDismissHandler(self);
    
    if (_delegate && [_delegate respondsToSelector:@selector(filterViewWillDismiss:)])
        [_delegate filterViewWillDismiss:self];
    
    // -----
    
    if (animated)
    {
        [self getParametersFromPresentation];
        
        [LGFilterView animateStandardWithAnimations:^(void)
         {
             [self dismissAnimations];
         }
                                         completion:^(BOOL finished)
         {
             if (finished)
             {
                 [self dismissComplete];
                 
                 if (completionHandler) completionHandler();
             }
         }];
    }
    else
    {
        [self dismissAnimations];
        
        [self dismissComplete];
        
        if (completionHandler) completionHandler();
    }
}

- (void)dismissAnimations
{
    UIScrollView *scrollView = nil;
    
    if (_tableView)
        scrollView = _tableView;
    else if (_scrollView)
        scrollView = _scrollView;
    
    // -----
    
    _backgroundView.alpha = 0.f;
    
    if (_transitionStyle == LGFilterViewTransitionStyleCenter)
    {
        scrollView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        scrollView.alpha = 0.f;
    }
    else scrollView.center = CGPointMake(scrollView.center.x, -scrollView.frame.size.height/2);
}

- (void)dismissComplete
{
    [self removeFromSuperview];
    
    // -----
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLGFilterViewDidDismissNotification object:self userInfo:nil];
    
    if (_didDismissHandler) _didDismissHandler(self);
    
    if (_delegate && [_delegate respondsToSelector:@selector(filterViewDidDismiss:)])
        [_delegate filterViewDidDismiss:self];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LGFilterViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.title                      = _titles[indexPath.row];
    cell.titleColor                 = _titleColor;
    cell.titleColorHighlighted      = _titleColorHighlighted;
    cell.titleColorSelected         = _titleColorSelected;
    cell.backgroundColorHighlighted = _backgroundColorHighlighted;
    cell.backgroundColorSelected    = _backgroundColorSelected;
    cell.separatorVisible           = (self.isSeparatorsVisible && indexPath.row != _titles.count-1);
    cell.separatorColor             = _separatorsColor;
    cell.separatorEdgeInsets        = _separatorsEdgeInsets;
    cell.textAlignment              = _textAlignment;
    cell.font                       = _font;
    cell.numberOfLines              = _numberOfLines;
    cell.lineBreakMode              = _lineBreakMode;
    cell.adjustsFontSizeToFitWidth  = _adjustsFontSizeToFitWidth;
    cell.minimumScaleFactor         = _minimumScaleFactor;
    
    return cell;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_numberOfLines == 0)
    {
        NSString *title = _titles[indexPath.row];
        
        UILabel *label = [UILabel new];
        label.text                      = title;
        label.textAlignment             = _textAlignment;
        label.font                      = _font;
        label.numberOfLines             = _numberOfLines;
        label.lineBreakMode             = _lineBreakMode;
        label.adjustsFontSizeToFitWidth = _adjustsFontSizeToFitWidth;
        label.minimumScaleFactor        = _minimumScaleFactor;
        
        CGSize size = [label sizeThatFits:CGSizeMake(tableView.frame.size.width-kLGFilterViewInnerMarginW*2, CGFLOAT_MAX)];
        
        size.height += kLGFilterViewInnerMarginH*2;
        
        if (size.height < 44.f)
            size.height = 44.f;
        
        return size.height;
    }
    else return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _selectedIndex)
    {
        [self cancelAction];
    }
    else
    {
        [self dismissAnimated:YES completionHandler:nil];
        
        _selectedIndex = indexPath.row;
        
        NSString *title = _titles[indexPath.row];
        NSUInteger index = indexPath.row;
        
        if (_actionHandler) _actionHandler(self, title, index);
        
        if (_delegate && [_delegate respondsToSelector:@selector(filterView:buttonPressedWithTitle:index:)])
            [_delegate filterView:self buttonPressedWithTitle:title index:index];
    }
}

#pragma mark -

- (void)subviewsInvalidate
{
    if (_titles.count)
    {
        if (!_tableView)
        {
            _tableView = [UITableView new];
            _tableView.dataSource = self;
            _tableView.delegate = self;
            _tableView.alwaysBounceVertical = NO;
            _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [_tableView registerClass:[LGFilterViewCell class] forCellReuseIdentifier:@"cell"];
            [self addSubview:_tableView];
        }
        
        _tableView.backgroundColor = _backgroundColorNormal;
        _tableView.indicatorStyle = _indicatorStyle;
        
        if (_transitionStyle == LGFilterViewTransitionStyleCenter)
        {
            _tableView.layer.masksToBounds = YES;
            _tableView.layer.cornerRadius = _cornerRadius;
            _tableView.layer.borderColor = _borderColor.CGColor;
            _tableView.layer.borderWidth = _borderWidth;
        }
        
        [_tableView reloadData];
    }
    else if (_innerView)
    {
        if (!_scrollView)
        {
            _scrollView = [UIScrollView new];
            _scrollView.alwaysBounceVertical = NO;
            [_scrollView addSubview:_innerView];
            [self addSubview:_scrollView];
        }
        
        _scrollView.backgroundColor = _backgroundColorNormal;
        _scrollView.indicatorStyle = _indicatorStyle;
        
        if (_transitionStyle == LGFilterViewTransitionStyleCenter)
        {
            _scrollView.layer.masksToBounds = YES;
            _scrollView.layer.cornerRadius = _cornerRadius;
            _scrollView.layer.borderColor = _borderColor.CGColor;
            _scrollView.layer.borderWidth = _borderWidth;
        }
    }
    
    if (!self.superview)
        [_parentView addSubview:self];
}

- (void)layoutInvalidate
{
    self.frame = CGRectMake(0.f, 0.f, _parentView.frame.size.width, _parentView.frame.size.height);
    _backgroundView.frame = CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height);
    
    // -----
    
    UIScrollView *scrollView = nil;
    
    if (_tableView)
        scrollView = _tableView;
    else if (_scrollView)
        scrollView = _scrollView;
    
    scrollView.contentInset = _contentInset;
    scrollView.scrollIndicatorInsets = _contentInset;
    
    if (_transitionStyle == LGFilterViewTransitionStyleCenter)
    {
        scrollView.transform = CGAffineTransformIdentity;
        scrollView.alpha = 1.f;
    }
    
    // -----
    
    CGFloat scrollViewHeight = _contentInset.top+_contentInset.bottom;
    
    if (_tableView)
        scrollViewHeight += _tableView.contentSize.height;
    else if (_scrollView)
        scrollViewHeight += _innerView.frame.size.height;
    
    if (_parentView.frame.size.height < scrollViewHeight)
        scrollViewHeight = _parentView.frame.size.height;
    
    if (_heightMax)
    {
        if (_heightMax < scrollViewHeight)
            scrollViewHeight = _heightMax;
    }
    else
    {
        if (_parentView.frame.size.height*0.5 < scrollViewHeight)
            scrollViewHeight = _parentView.frame.size.height*0.5;
    }
    
    // -----
    
    CGRect scrollViewFrame = CGRectZero;
    
    if (_transitionStyle == LGFilterViewTransitionStyleCenter)
        scrollViewFrame = CGRectMake(_parentView.frame.size.width/2-kLGFilterViewWidth/2,
                                     _parentView.frame.size.height/2-scrollViewHeight/2+_offset.y,
                                     kLGFilterViewWidth,
                                     scrollViewHeight);
    else
        scrollViewFrame = CGRectMake(0.f, 0.f, self.frame.size.width, scrollViewHeight);
    
    if ([UIScreen mainScreen].scale == 1.f)
        scrollViewFrame = CGRectIntegral(scrollViewFrame);
    
    // -----
    
    if (!self.isShowing && _transitionStyle == LGFilterViewTransitionStyleTop)
        scrollViewFrame.origin.y -= scrollViewFrame.size.height;
    
    scrollView.frame = scrollViewFrame;
    
    // -----
    
    if (_tableView)
    {
        if (_selectedIndex >= 0)
        {
            if (_transitionStyle == LGFilterViewTransitionStyleCenter)
                [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
            else
            {
                [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                
                CGRect rect = [_tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
                
                CGFloat offsetY = rect.origin.y+rect.size.height/2-_tableView.frame.size.height/2-_tableView.contentInset.top/2;
                if (offsetY < -_tableView.contentInset.top)
                    offsetY = -_tableView.contentInset.top;
                else if (offsetY > _tableView.contentSize.height-_tableView.frame.size.height)
                    offsetY = _tableView.contentSize.height-_tableView.frame.size.height;
                
                _tableView.contentOffset = CGPointMake(_tableView.contentOffset.x, offsetY);
            }
        }
        else _tableView.contentOffset = CGPointMake(_tableView.contentOffset.x, -_tableView.contentInset.top);
    }
    else if (_scrollView)
    {
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _innerView.frame.size.height);
        
        // -----
        
        CGRect viewFrame = CGRectMake(_scrollView.frame.size.width/2-_innerView.frame.size.width/2, 0.f, _innerView.frame.size.width, _innerView.frame.size.height);
        
        if ([UIScreen mainScreen].scale == 1.f)
            viewFrame = CGRectIntegral(viewFrame);
        
        _innerView.frame = viewFrame;
    }
    
    if (!self.isShowing && _transitionStyle == LGFilterViewTransitionStyleCenter)
    {
        scrollView.transform = CGAffineTransformMakeScale(1.2, 1.2);
        scrollView.alpha = 0.f;
    }
}

- (void)getParametersFromPresentation
{
    UIScrollView *scrollView = nil;
    
    if (_tableView)
        scrollView = _tableView;
    else if (_scrollView)
        scrollView = _scrollView;
    
    // -----
    
    if (_backgroundView.layer.animationKeys.count && scrollView.layer.animationKeys.count)
    {
        _backgroundView.alpha = [(CALayer *)_backgroundView.layer.presentationLayer opacity];
        
        if (_transitionStyle == LGFilterViewTransitionStyleCenter)
        {
            CGFloat scaleX = [[(CALayer *)scrollView.layer.presentationLayer valueForKeyPath:@"transform.scale.x"] floatValue];
            CGFloat scaleY = [[(CALayer *)scrollView.layer.presentationLayer valueForKeyPath:@"transform.scale.y"] floatValue];
            
            if (scaleX && scaleY)
                scrollView.transform = CGAffineTransformMakeScale(scaleX, scaleY);
            
            scrollView.alpha = [(CALayer *)scrollView.layer.presentationLayer opacity];
        }
        else scrollView.center = [(CALayer *)scrollView.layer.presentationLayer position];
        
        [_backgroundView.layer removeAllAnimations];
        [scrollView.layer removeAllAnimations];
    }
}

#pragma mark -

- (void)cancelAction
{
    [self dismissAnimated:YES completionHandler:nil];
    
    // -----
    
    if (_cancelHandler) _cancelHandler(self);
    
    if (_delegate && [_delegate respondsToSelector:@selector(filterViewCancelled:)])
        [_delegate filterViewCancelled:self];
}

#pragma mark - Observers

- (void)addObservers
{
    if (!self.isObserversAdded && _parentView)
    {
        _observersAdded = YES;
        
        [_parentView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)removeObservers
{
    if (self.isObserversAdded && _parentView)
    {
        _observersAdded = NO;
        
        [_parentView removeObserver:self forKeyPath:@"frame"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"])
        [self layoutInvalidate];
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - Support

+ (void)animateStandardWithAnimations:(void(^)())animations completion:(void(^)(BOOL finished))completion
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0)
    {
        [UIView animateWithDuration:0.5
                              delay:0.0
             usingSpringWithDamping:1.f
              initialSpringVelocity:0.5
                            options:0
                         animations:animations
                         completion:completion];
    }
    else
    {
        [UIView animateWithDuration:0.5*0.66
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:animations
                         completion:completion];
    }
}

@end
