//
//  LGFilterViewCell.m
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

#import "LGFilterViewCell.h"

@interface LGFilterViewCell ()

@property (strong, nonatomic) UILabel   *titleLabel;
@property (strong, nonatomic) UIView    *separatorView;

@end

@implementation LGFilterViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _titleLabel = [UILabel new];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleLabel];
        
        _separatorView = [UIView new];
        [self addSubview:_separatorView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _titleLabel.text = _title;
    _titleLabel.textAlignment = _textAlignment;
    _titleLabel.font = _font;
    _titleLabel.numberOfLines = _numberOfLines;
    _titleLabel.lineBreakMode = _lineBreakMode;
    _titleLabel.adjustsFontSizeToFitWidth = _adjustsFontSizeToFitWidth;
    _titleLabel.minimumScaleFactor = _minimumScaleFactor;
    
    CGRect titleLabelFrame = CGRectMake(10.f, 0.f, self.frame.size.width-20.f, self.frame.size.height);
    if ([UIScreen mainScreen].scale == 1.f)
        titleLabelFrame = CGRectIntegral(titleLabelFrame);
    _titleLabel.frame = titleLabelFrame;
    
    if (self.isSeparatorVisible)
    {
        _separatorView.hidden = NO;
        
        _separatorView.backgroundColor = _separatorColor;
        
        CGFloat separatorHeight = ([UIScreen mainScreen].scale == 1.f ? 1.f : 0.5);
        
        _separatorView.frame = CGRectMake(_separatorEdgeInsets.left, self.frame.size.height-separatorHeight, self.frame.size.width-_separatorEdgeInsets.left-_separatorEdgeInsets.right, separatorHeight);
    }
    else _separatorView.hidden = YES;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (!self.isSelected)
    {
        if (highlighted)
        {
            _titleLabel.textColor = _titleColorHighlighted;
            self.backgroundColor = _backgroundColorHighlighted;
        }
        else
        {
            _titleLabel.textColor = _titleColor;
            self.backgroundColor = [UIColor clearColor];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected)
    {
        _titleLabel.textColor = _titleColorSelected;
        self.backgroundColor = _backgroundColorSelected;
    }
    else
    {
        if (self.isHighlighted)
        {
            _titleLabel.textColor = _titleColorHighlighted;
            self.backgroundColor = _backgroundColorHighlighted;
        }
        else
        {
            _titleLabel.textColor = _titleColor;
            self.backgroundColor = [UIColor clearColor];
        }
    }
}

@end
