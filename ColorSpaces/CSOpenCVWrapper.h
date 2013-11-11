//
//  CSOpenCVWrapper.h
//  ColorSpaces
//
//  Created by User on 11/8/13.
//  Copyright (c) 2013 User. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import "SkinToneMatcher.h"

//using namespace cv;

@interface CSOpenCVWrapper : NSObject {

}


+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (UIImage*)UIImageFromCVMat:(cv::Mat)cvMat;
//+ (cv::Mat)hsvTransform:(cv::Mat)cvMat;
+ (cv::Mat) hsvTransform:(cv::Mat)cvMat hue:(Float32)hue saturation:(Float32)saturation value:(Float32)value;
+ (cv::Mat) hueTransform:(cv::Mat)cvMat hueSin:(Float32)hueSin hueCos:(Float32)hueCos;
+ (cv::Mat) saturationTransform:(cv::Mat)cvMat saturation:(Float32)saturation;
+ (cv::Mat) valueTransform:(cv::Mat)cvMat value:(Float32)value;

@end
