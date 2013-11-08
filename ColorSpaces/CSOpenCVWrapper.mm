//
//  CSOpenCVWrapper.m
//  ColorSpaces
//
//  Created by User on 11/8/13.
//  Copyright (c) 2013 User. All rights reserved.
//

#import "CSOpenCVWrapper.h"

@implementation CSOpenCVWrapper

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image
 {
     int bitsPerComponent = 8;
     CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
     CGFloat cols = image.size.width;
     CGFloat rows = image.size.height;
     NSLog(@"Image cols: %f, rows: %f\n", cols, rows);
 
     //cv::Mat cvMat(rows, cols, CV_32FC4); // 8 bits per component, 4 channels (color channels + alpha)
     cv::Mat cvMat(rows, cols, CV_8UC4);
 
     NSLog(@"Image bytes per row %U\n", cvMat.step[0]);
     NSLog(@"Elem size %U\n", cvMat.elemSize());
     CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                     cols,                       // Width of bitmap
                                                     rows,                       // Height of bitmap
                                                     bitsPerComponent,                          // Bits per component
                                                     cvMat.step[0],              // Bytes per row
                                                     colorSpace,                 // Colorspace
                                                     kCGImageAlphaNoneSkipLast |
                                                     kCGBitmapByteOrderDefault); // Bitmap info flags
 
     CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
     CGContextRelease(contextRef);
     cv::Mat cvMatFloat(rows, cols, CV_32FC4);
     cvMat.convertTo(cvMatFloat, CV_32FC4);
 
     return cvMatFloat;
 }

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    int bitsPerComponent = 8;
    cv::Mat cvMatInt(cvMat.cols, cvMat.rows, CV_8UC4);
    cvMat.convertTo(cvMatInt, CV_8UC4);
    //NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    NSData *data = [NSData dataWithBytes:cvMatInt.data length:cvMatInt.elemSize()*cvMatInt.total()];
    CGColorSpaceRef colorSpace;
    

    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    /*CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        bitsPerComponent,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );*/
    CGImageRef imageRef = CGImageCreate(cvMatInt.cols,                                 //width
                                        cvMatInt.rows,                                 //height
                                        bitsPerComponent,                                          //bits per component
                                        8 * cvMatInt.elemSize(),                       //bits per pixel
                                        cvMatInt.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

Float32* TransformHSV(Float32 *pixel_color /* color to transform*/, Float32 hue_shift /* hue shift (in degrees)*/, Float32 sat_mult /*saturation multiplier (scalar)*/, Float32 val_mult /* value multiplier (scalar)*/)
{
    Float32 vsu = val_mult * sat_mult * cos(hue_shift * M_PI/180);
    Float32 vsw = val_mult * sat_mult * sin(hue_shift * M_PI/180);
    
    Float32 r_in = pixel_color[0];
    Float32 g_in = pixel_color[1];
    Float32 b_in = pixel_color[2];
    
    Float32 r_result = (.299 * val_mult + .701 * vsu+ .168 * vsw) * r_in
    + (.587 * val_mult - .587 * vsu + .330 * vsw) * g_in
    + (.114 * val_mult - .114 * vsu - .497 * vsw) * b_in;
    Float32 g_result = (.299 * val_mult - .299 * vsu - .328 * vsw) * r_in
    + (.587 * val_mult + .413 * vsu + .035 *vsw) * g_in
    + (.114 * val_mult - .114 * vsu + .292 * vsw) * b_in;
    Float32 b_result = (.299 * val_mult - .3 * vsu + 1.25 * vsw) * r_in
    + (.587 * val_mult - .588 * vsu - 1.05 * vsw) * g_in
    + (.114 * val_mult + .886 * vsu - .203 * vsw) * b_in;
    
    pixel_color[0] = r_result;
    pixel_color[1] = g_result;
    pixel_color[2] = b_result;
    
    return pixel_color;
}

+ (cv::Mat) hsvTransform:(cv::Mat)cvMat
{
    int numPixels = cvMat.rows * cvMat.cols;
    Float32* data = (Float32*)cvMat.data;
    
    for (int i = 0; i < numPixels * 4; i+=4)
    {
        TransformHSV(data + i, 120.0, 0.4, 0.2);
    }
    
    return cvMat;
}

@end
