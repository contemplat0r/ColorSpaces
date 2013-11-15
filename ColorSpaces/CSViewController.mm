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
    _hue = 180.0;
    _saturation = 0.5;
    _value = 0.5;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default.png"]];
    _image = [UIImage imageNamed:@"testimage2.jpg"];
    //cv::Mat imgMatrix = [CSOpenCVWrapper cvMatFromUIImage:_image];
    //[CSOpenCVWrapper hsvTransform:imgMatrix hue:_hue saturation:_saturation value:_value];
    //_newImage = [CSOpenCVWrapper UIImageFromCVMat:imgMatrix];
    _imageView = [[UIImageView alloc] initWithImage:_image];
    //_imageView = [[UIImageView alloc] initWithImage:_newImage];
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
    
    
    [_valueSlider setMinimumValue:0];
    [_valueSlider setMaximumValue:1];
    [_valueSlider setValue:_value];
    [self.view addSubview:_valueSlider];
    [self.view addSubview:_valueLabel];
    

    [_saturationSlider setMinimumValue:0];
    [_saturationSlider setMaximumValue:1];
    [_saturationSlider setValue:_saturation];
    [self.view addSubview:_saturationSlider];
    [self.view addSubview:_saturationLabel];

    [_hueSlider setMinimumValue:0];
    [_hueSlider setMaximumValue:360];
    [_hueSlider setValue:_hue];
    [self.view addSubview:_hueLabel];
    [self.view addSubview:_hueSlider];
    
    
    //NSLog(@"self.view width %f\n", self.view.bounds.size.width);
    //NSLog(@"self.view height %f\n", self.view.bounds.size.height);
    //NSLog(@"self.view origin x %f\n", self.view.bounds.origin.x);
    //NSLog(@"self.view origin y %f\n", self.view.bounds.origin.y);
    
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
        _value = [slider value];
        _valueLabel.text = [NSString stringWithFormat:@"%f", _value];
        //_image = _imageView.image;
        /*cv::Mat imgMatrix = [CSOpenCVWrapper cvMatFromUIImage:_image];
        [CSOpenCVWrapper hsvTransform:imgMatrix hue:_hue saturation:_saturation value:_value];
        _newImage = [CSOpenCVWrapper UIImageFromCVMat:imgMatrix];
        //_imageView = [[UIImageView alloc] initWithImage:_image];
        [_imageView setImage:_newImage];*/
    }
    else if (slider == _saturationSlider)
    {
        _saturation = [slider value];
        _saturationLabel.text = [NSString stringWithFormat:@"%f", [slider value]];
        /*//_image = _imageView.image;
        cv::Mat imgMatrix = [CSOpenCVWrapper cvMatFromUIImage:_image];
        [CSOpenCVWrapper hsvTransform:imgMatrix hue:_hue saturation:_saturation value:_value];
        _newImage = [CSOpenCVWrapper UIImageFromCVMat:imgMatrix];
        //_imageView = [[UIImageView alloc] initWithImage:_image];
        [_imageView setImage:_newImage];*/
    }
    else if (slider == _hueSlider)
    {
        _hue = [slider value];
        _hueLabel.text = [NSString stringWithFormat:@"%f", [slider value]];
        /*Float32 hueCos = cos(_hue * M_PI/180);
        Float32 hueSin = sin(_hue * M_PI/180);
        cv::Mat imgMatrix = [CSOpenCVWrapper cvMatFromUIImage:_image];
        [CSOpenCVWrapper hueTransform:imgMatrix hueSin:hueSin hueCos:hueCos];
        _newImage = [CSOpenCVWrapper UIImageFromCVMat:imgMatrix];
        //_imageView = [[UIImageView alloc] initWithImage:_image];
        [_imageView setImage:_newImage];*/
    }
    //_image = _imageView.image;
    cv::Mat imgMatrix = [CSOpenCVWrapper cvMatFromUIImage:_image];
    //[CSOpenCVWrapper hsvTransform:imgMatrix hue:_hue saturation:_saturation value:_value];
    [CSOpenCVWrapper hsvTransformBlas:imgMatrix hue:_hue saturation:_saturation value:_value];
    //cv::Mat transformedImgMatrix = [CSOpenCVWrapper matchSkinToneF:imgMatrix hue:_hue saturation:_saturation value:_value];
    _newImage = [CSOpenCVWrapper UIImageFromCVMat:imgMatrix];
    //_newImage = [CSOpenCVWrapper UIImageFromCVMat:transformedImgMatrix];
    [_imageView setImage:_newImage];
    
}




@end
