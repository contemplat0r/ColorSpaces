//
//  CSOpenCVWrapper.h
//  ColorSpaces
//
//  Created by User on 11/8/13.
//  Copyright (c) 2013 User. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SkinToneMatcher.h"
//using namespace cv;

@interface CSOpenCVWrapper : NSObject {

}

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (UIImage*)UIImageFromCVMat:(cv::Mat)cvMat;
+ (cv::Mat)hsvTransform:(cv::Mat)cvMat;

@end
