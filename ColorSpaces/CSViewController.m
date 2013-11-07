//
//  CSViewController.m
//  ColorSpaces
//
//  Created by User on 11/7/13.
//  Copyright (c) 2013 User. All rights reserved.
//

#import "CSViewController.h"

@interface CSViewController ()

@end

@implementation CSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _sliderWidth = 264;
    _sliderHeight = 23;
    _labelWidth = _sliderWidth / 2;
    _labelHeidht = 30;
    _distanceBetweenElements = 14;
    _sliderX = (self.view.bounds.size.width - _sliderWidth) / 2;
    _labelX = (self.view.bounds.size.width - _labelWidth) / 2;
    _nextElementY = _distanceBetweenElements * 2;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default.png"]];
    _image = [UIImage imageNamed:@"testimage2.jpg"];
    _imageView = [[UIImageView alloc] initWithImage:_image];
    [_imageView setCenter:CGPointMake(self.view.center.x, self.view.center.y + self.view.bounds.size.height / 9)];
    [self.view addSubview:_imageView];
    /*UIAlertView *allert = [[UIAlertView alloc] initWithTitle:@"Hello!" message:@"Welcome to OpenCV" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    [allert show];*/
	// Do any additional setup after loading the view, typically from a nib.
    
    _valueSlider = [[UISlider alloc] initWithFrame:CGRectMake(_sliderX, _nextElementY, _sliderWidth, _sliderHeight)];
    [_valueSlider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [_valueSlider setContinuous:YES];
    _nextElementY = _nextElementY + _sliderHeight + _distanceBetweenElements;
    _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(_labelX, _nextElementY, _labelWidth, _labelHeidht)];
    _valueLabel.textColor = [UIColor whiteColor];
    _nextElementY = _nextElementY + _labelHeidht + _distanceBetweenElements;
    
    _saturationSlider = [[UISlider alloc] initWithFrame:CGRectMake(_sliderX, _nextElementY, _sliderWidth, _sliderHeight)];
    [_saturationSlider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [_saturationSlider setContinuous:YES];
    _nextElementY = _nextElementY + _sliderHeight + _distanceBetweenElements;
    _saturationLabel = [[UILabel alloc] initWithFrame:CGRectMake(_labelX, _nextElementY, _labelWidth, _labelHeidht)];
    _saturationLabel.textColor = [UIColor whiteColor];
    _nextElementY = _nextElementY + _labelHeidht + _distanceBetweenElements;
    
    _hueSlider = [[UISlider alloc] initWithFrame:CGRectMake(_sliderX, _nextElementY, _sliderWidth, _sliderHeight)];
    [_hueSlider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [_hueSlider setContinuous:YES];
    _nextElementY = _nextElementY + _sliderHeight + _distanceBetweenElements;
    _hueLabel = [[UILabel alloc] initWithFrame:CGRectMake(_labelX, _nextElementY, _labelWidth, _labelHeidht)];
    _hueLabel.textColor = [UIColor whiteColor];
    _nextElementY = _nextElementY + _labelHeidht + _distanceBetweenElements;
    
    [self.view addSubview:_valueSlider];
    [_valueSlider setMinimumValue:0];
    [_valueSlider setMaximumValue:1];
    [self.view addSubview:_valueLabel];
    
    [self.view addSubview:_saturationSlider];
    [_saturationSlider setMinimumValue:0];
    [_saturationSlider setMaximumValue:1];
    [self.view addSubview:_saturationLabel];

    [self.view addSubview:_hueSlider];
    [_hueSlider setMinimumValue:0];
    [_hueSlider setMaximumValue:360];
    [self.view addSubview:_hueLabel];
    
    
    NSLog(@"self.view width %f\n", self.view.bounds.size.width);
    NSLog(@"self.view height %f\n", self.view.bounds.size.height);
    NSLog(@"self.view origin x %f\n", self.view.bounds.origin.x);
    NSLog(@"self.view origin y %f\n", self.view.bounds.origin.y);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) sliderValueDidChange:(id)sender
{
    UISlider* slider = (UISlider*)sender;
    
    if (slider == _valueSlider)
    {
        _valueLabel.text = [NSString stringWithFormat:@"%f", [slider value]];
    }
    else if (slider == _saturationSlider)
    {
        _saturationLabel.text = [NSString stringWithFormat:@"%f", [slider value]];
    }
    else if (slider == _hueSlider)
    {
        _hueLabel.text = [NSString stringWithFormat:@"%f", [slider value]];
    }
}


/*- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}*/

@end