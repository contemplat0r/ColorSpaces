//
//  CSOpenCVWrapper.h
//  ColorSpaces
//
//  Created by User on 11/8/13.
//  Copyright (c) 2013 User. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
//#import "SkinToneMatcher.h"
#include <OpenCV2/opencv.hpp>
//#import <boost/tuple/tuple.hpp>
//#import <boost/unordered/unordered_map.hpp>
//#include <boost/tuple/tuple_comparison.hpp>
#import <pthread.h>
#include <errno.h>
#include <semaphore.h>

//using namespace cv;

@interface CSOpenCVWrapper : NSObject {

}


+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (UIImage*)UIImageFromCVMat:(cv::Mat)cvMat;
//+ (cv::Mat)hsvTransform:(cv::Mat)cvMat;
+ (cv::Mat) hsvTransform:(cv::Mat)cvMat hue:(float)hue saturation:(float)saturation value:(float)value;
+ (cv::Mat) hsvTransformBlas:(cv::Mat)cvMat hue:(float)hue saturation:(float)saturation value:(float)value;
+ (cv::Mat) hueTransform:(cv::Mat)cvMat hueSin:(float)hueSin hueCos:(float)hueCos;
+ (cv::Mat) saturationTransform:(cv::Mat)cvMat saturation:(float)saturation;
+ (cv::Mat) valueTransform:(cv::Mat)cvMat value:(float)value;
//+ (cv::Mat) matchSkinToneF:(cv::Mat)cvMat hue:(float)hue saturation:(float)saturation value:(float)value;

@end
