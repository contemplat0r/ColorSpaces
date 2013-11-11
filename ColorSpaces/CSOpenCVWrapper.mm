//
//  CSOpenCVWrapper.m
//  ColorSpaces
//
//  Created by User on 11/8/13.
//  Copyright (c) 2013 User. All rights reserved.
//

#import "CSOpenCVWrapper.h"

static float RGBtoYIQMat[3][3] =
{
    {0.299, 0.587, 0.114},
    
    {0.596, -0.274, -0.321},
    
    {0.211, -0.523, 0.311}
    
};

static float YIQtoRGBMat[3][3] =
{
    {1, 0.956, 0.621},
    
    {1, -0.272, -0.647},
    
    {1, -1.107, 1.705}
};

static float hueTransformMat[3][3] =
{
    {1, 0, 0},
    
    {0, 0, 0},
    
    {0, 0, 0}
};

static float saturationTransformMat[3][3] =
{
    {1, 0, 0},
    
    {0, 1, 0},
    
    {0, 0, 1}
};

static float valueTransformMat[3][3] =
{
    {1, 0, 0},
    
    {0, 1, 0},
    
    {0, 0, 1}
};
/*static float RGBtoYIQMat[3][3];
static float YIQtoRGBMat[3][3];
static float hueTransformMat[3][3];
static float saturationTransformMat[3][3];
static float valueTransformMat[3][3];

RGBtoYIQMat[0][0] = 0.299;
RGBtoYIQMat[0][1] = 0.587;
RGBtoYIQMat[0][2] = 0.114;

RGBtoYIQMat[1][0] = 0.596;
RGBtoYIQMat[1][1] = -0.274;
RGBtoYIQMat[1][2] = -0.321;

RGBtoYIQMat[2][0] = 0.211;
RGBtoYIQMat[2][1] = -0.523;
RGBtoYIQMat[2][1] = 0.311;


YIQtoRGBMat[0][0] = 1;
YIQtoRGBMat[0][1] = 0.956;
YIQtoRGBMat[0][2] = 0.621;

YIQtoRGBMat[1][0] = 1;
YIQtoRGBMat[1][1] = -0.272;
YIQtoRGBMat[1][2] = -0.647;

YIQtoRGBMat[2][0] = 1;
YIQtoRGBMat[2][1] = -1.107;
YIQtoRGBMat[2][2] = 1.705;

hueTransformMat[0][0] = 1;
hueTransformMat[0][1] = 0;
hueTransformMat[0][2] = 0;
hueTransformMat[1][0] = 0;
hueTransformMat[1][1] = 0;
hueTransformMat[1][2] = 0;
hueTransformMat[2][0] = 0;
hueTransformMat[2][1] = 0;
hueTransformMat[2][2] = 0;

saturationTransformMat[0][0] = 1;
saturationTransformMat[0][1] = 0;
saturationTransformMat[0][2] = 0;

saturationTransformMat[1][0] = 0;
saturationTransformMat[1][1] = 1;
saturationTransformMat[1][2] = 0;

saturationTransformMat[2][0] = 0;
saturationTransformMat[2][1] = 0;
saturationTransformMat[2][2] = 1;

valueTransformMat[0][0] = 1;
valueTransformMat[0][1] = 0;
valueTransformMat[0][2] = 0;

valueTransformMat[1][0] = 0;
valueTransformMat[1][1] = 1;
valueTransformMat[1][2] = 0;

valueTransformMat[2][0] = 0;
valueTransformMat[2][1] = 0;
valueTransformMat[2][2] = 1;*/



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

Float32* TransformHSV(Float32 *pixel_color, Float32 vsu, Float32 vsw, Float32 val_mult)
{
    //Float32 vsu = val_mult * sat_mult * cos(hue_shift * M_PI/180);
    //Float32 vsw = val_mult * sat_mult * sin(hue_shift * M_PI/180);
    
    Float32 r_in = pixel_color[0];
    Float32 g_in = pixel_color[1];
    Float32 b_in = pixel_color[2];
    
    Float32 r_result = (.299 * val_mult + .701 * vsu + .168 * vsw) * r_in
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

+ (cv::Mat) hsvTransform:(cv::Mat)cvMat hue:(Float32)hue saturation:(Float32)saturation value:(Float32)value
{
    int numPixels = cvMat.rows * cvMat.cols;
    Float32* data = (Float32*)cvMat.data;
    Float32 vsu = value * saturation * cos(hue * M_PI/180);
    Float32 vsw = value * saturation * sin(hue * M_PI/180);
    for (int i = 0; i < numPixels * 4; i+=4)
    {
        TransformHSV(data + i, vsu, vsw, value);
    }
    
    return cvMat;
}

+ (cv::Mat) hueTransform:(cv::Mat)cvMat hueSin:(Float32)hueSin hueCos:(Float32)hueCos
{
    int numPixels = cvMat.rows * cvMat.cols;
    Float32* data = (Float32*)cvMat.data;
    hueTransformMat[1][1] = hueCos;
    hueTransformMat[1][2] = -hueSin;
    hueTransformMat[2][1] = hueSin;
    hueTransformMat[2][2] = hueCos;

    
    for (int i = 0; i < numPixels * 4; i+=4)
    {
        float colorVect[3] = {data[i], data[i + 1], data[i + 2]};
        float result[3] = {0.0, 0.0, 0.0};
        cblas_sgemv(CblasRowMajor, CblasNoTrans, 3, 3, 1.0f, (float*)RGBtoYIQMat, 3, colorVect, 1, 1.0f, result, 1);
       
        colorVect[0] = result[0];
        colorVect[1] = result[1];
        colorVect[2] = result[2];
        cblas_sgemv(CblasRowMajor, CblasNoTrans, 3, 3, 1.0f, (float*)hueTransformMat, 3, colorVect, 1, 1.0f, result, 1);
        
        colorVect[0] = result[0];
        colorVect[1] = result[1];
        colorVect[2] = result[2];
        cblas_sgemv(CblasRowMajor, CblasNoTrans, 3, 3, 1.0f, (float*)YIQtoRGBMat, 3, colorVect, 1, 1.0f, result, 1);
        
        data[i] = result[0];
        data[i + 1] = result[1];
        data[i + 2] = result[2];
        
    }
    return cvMat;
}

@end
