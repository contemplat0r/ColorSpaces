//
//  CSViewController.h
//  ColorSpaces
//
//  Created by User on 11/7/13.
//  Copyright (c) 2013 User. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "SkinToneMatcher.h"

@interface CSViewController : UIViewController {
    UIImage* _image;
    float _nextElementY;
    float _sliderX;
    float _labelX;
}

@property (nonatomic) UIImageView* imageView;
@property (nonatomic) UISlider* valueSlider;
@property (nonatomic) UISlider* saturationSlider;
@property (nonatomic) UISlider* hueSlider;
@property (nonatomic) UILabel* valueLabel;
@property (nonatomic) UILabel* saturationLabel;
@property (nonatomic) UILabel* hueLabel;

@property float sliderWidth;
@property float sliderHeight;
@property float labelWidth;
@property float labelHeidht;
@property float distanceBetweenElements;

@end
