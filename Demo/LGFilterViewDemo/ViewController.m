//
//  ViewController.m
//  LGFilterViewDemo
//
//  Created by Grigory Lutkov on 27.03.15.
//  Copyright (c) 2015 Grigory Lutkov. All rights reserved.
//

#import "ViewController.h"
#import "LGFilterView.h"

@interface ViewController ()

@property (strong, nonatomic) LGFilterView  *filterView1;
@property (strong, nonatomic) LGFilterView  *filterView2;

@property (strong, nonatomic) NSArray   *titlesArray;
@property (strong, nonatomic) UIButton  *titleButton;

@property (strong, nonatomic) UIView *innerView;

@property (strong, nonatomic) UISegmentedControl *segmentControl;

@end

@implementation ViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.title = @"LGFilterView";

        self.view.backgroundColor = [UIColor whiteColor];

        // -----

        _innerView = [UIView new];
        _innerView.backgroundColor = [UIColor clearColor];
        _innerView.frame = CGRectMake(0.f, 0.f, 200.f, 200.f);

        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"UIView";
        label.textColor = [UIColor colorWithRed:0.f green:0.5 blue:1.f alpha:1.f];
        [label sizeToFit];
        label.center = CGPointMake(_innerView.frame.size.width/2, _innerView.frame.size.height/2);
        [_innerView addSubview:label];

        // -----

        _titlesArray = @[@"Title 1",
                         @"Title 2",
                         @"Title 3",
                         @"Title 4",
                         @"Title 5",
                         @"Title 6",
                         @"Title 7",
                         @"Title 8",
                         @"Title 9",
                         @"Title 10"];

        UIImage *arrowImage = [UIImage imageNamed:@"Arrow"];

        _titleButton = [UIButton new];
        _titleButton.backgroundColor = [UIColor clearColor];
        _titleButton.tag = 0;
        [_titleButton setTitle:_titlesArray.firstObject forState:UIControlStateNormal];
        [_titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_titleButton setImage:arrowImage forState:UIControlStateNormal];
        _titleButton.titleLabel.font = [UIFont systemFontOfSize:20.f];
        _titleButton.imageEdgeInsets = UIEdgeInsetsMake(0.f, -4.f, 0.f, 4.f);
        _titleButton.titleEdgeInsets = UIEdgeInsetsMake(0.f, 4.f, 0.f, -4.f);
        [_titleButton addTarget:self action:@selector(filterAction1:) forControlEvents:UIControlEventTouchUpInside];
        [_titleButton sizeToFit];

        self.navigationItem.titleView = _titleButton;

        // -----

        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Filter"] style:UIBarButtonItemStylePlain target:self action:@selector(filterAction2:)];
        self.navigationItem.rightBarButtonItem = rightButton;

        // -----

        _segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"Top", @"Center"]];
        _segmentControl.selectedSegmentIndex = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 0 : 1);
        [_segmentControl addTarget:self action:@selector(updateFilterProperties:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_segmentControl];

        // -----

        [self setupFilterViewsWithTransitionStyle:(LGFilterViewTransitionStyle)_segmentControl.selectedSegmentIndex];
    }
    return self;
}

#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"%s [Line %d]", __PRETTY_FUNCTION__, __LINE__);
}

#pragma mark - Appearing

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    CGFloat topInset = self.navigationController.navigationBar.frame.size.height+([UIApplication sharedApplication].isStatusBarHidden ? 0.f : [UIApplication sharedApplication].statusBarFrame.size.height);
    if ([UIDevice currentDevice].systemVersion.floatValue < 7.0) topInset = 0.f;

    _segmentControl.center = CGPointMake(self.view.frame.size.width/2, topInset+20.f+_segmentControl.frame.size.height/2);
    _segmentControl.frame = CGRectIntegral(_segmentControl.frame);

    [self updateFilterProperties:nil];
}

#pragma mark -

- (void)filterAction1:(UIButton *)button
{
    if (_filterView2.isShowing)
        [_filterView2 dismissAnimated:YES completionHandler:nil];

    if (!_filterView1.isShowing)
    {
        _filterView1.selectedIndex = button.tag;

        [_filterView1 showInView:self.view animated:YES completionHandler:nil];
    }
    else [_filterView1 dismissAnimated:YES completionHandler:nil];
}

- (void)filterAction2:(UIButton *)button
{
    if (_filterView1.isShowing)
        [_filterView1 dismissAnimated:YES completionHandler:nil];

    if (!_filterView2.isShowing)
        [_filterView2 showInView:self.view animated:YES completionHandler:nil];
    else
        [_filterView2 dismissAnimated:YES completionHandler:nil];
}

- (void)updateFilterProperties:(UISegmentedControl *)segmentControl
{
    if (segmentControl)
        [self setupFilterViewsWithTransitionStyle:(LGFilterViewTransitionStyle)segmentControl.selectedSegmentIndex];

    CGFloat topInset = self.navigationController.navigationBar.frame.size.height+([UIApplication sharedApplication].isStatusBarHidden ? 0.f : [UIApplication sharedApplication].statusBarFrame.size.height);
    if ([UIDevice currentDevice].systemVersion.floatValue < 7.0) topInset = 0.f;

    if (_filterView1.transitionStyle == LGFilterViewTransitionStyleCenter)
    {
        _filterView1.offset = CGPointMake(0.f, topInset/2);
        _filterView1.contentInset = UIEdgeInsetsZero;
    }
    else if (_filterView1.transitionStyle == LGFilterViewTransitionStyleTop)
    {
        _filterView1.contentInset = UIEdgeInsetsMake(topInset, 0.f, 0.f, 0.f);
        _filterView1.offset = CGPointZero;
    }

    _filterView2.contentInset = _filterView1.contentInset;
    _filterView2.offset = _filterView1.offset;
}

- (void)setupFilterViewsWithTransitionStyle:(LGFilterViewTransitionStyle)style
{
    __weak typeof(self) wself = self;

    _filterView1 = [[LGFilterView alloc] initWithTitles:_titlesArray
                                          actionHandler:^(LGFilterView *filterView, NSString *title, NSUInteger index)
                    {
                        if (wself)
                        {
                            __strong typeof(wself) self = wself;

                            [self.titleButton setTitle:title forState:UIControlStateNormal];
                            self.titleButton.tag = index;
                            [self.titleButton sizeToFit];
                        }
                    }
                                          cancelHandler:nil];
    _filterView1.transitionStyle = style;
    _filterView1.numberOfLines = 0;

    // -----

    _filterView2 = [[LGFilterView alloc] initWithView:_innerView];
    _filterView2.transitionStyle = style;
    _filterView2.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    _filterView2.cornerRadius = 15.f;
    _filterView2.borderColor = [UIColor colorWithRed:0.f green:0.5 blue:1.f alpha:1.f];
    _filterView2.borderWidth = 2.f;
    _filterView2.indicatorStyle = UIScrollViewIndicatorStyleWhite;
}

@end
