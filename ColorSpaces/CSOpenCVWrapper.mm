
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

int numPixels, pixelArraySize;
float vsu, vsw, colorValue;
sem_t semaphore;
float *data;

@implementation CSOpenCVWrapper {
    
}


+ (cv::Mat)cvMatFromUIImage:(UIImage *)image
 {
     int bitsPerComponent = 8;
     CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
     CGFloat cols = image.size.width;
     CGFloat rows = image.size.height;
     //NSLog(@"Image cols: %f, rows: %f\n", cols, rows);
 
     //cv::Mat cvMat(rows, cols, CV_32FC4); // 8 bits per component, 4 channels (color channels + alpha)
     cv::Mat cvMat(rows, cols, CV_8UC4);
 
     //NSLog(@"Image bytes per row %U\n", cvMat.step[0]);
     //NSLog(@"Elem size %U\n", cvMat.elemSize());
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

/*
 
 T : matrix([v, 0, 0], [0, vsu, -vsw], [0, vsw, vsu]);
 
 [ v   0     0   ]
 [               ]
 [ 0  vsu  - vsw ]
 [               ]
 [ 0  vsw   vsu  ]
 
 
 RGBtoYIQ : matrix([0.299, 0.587, 0.114], [0.596, -0.274, -0.321], [0.211, -0.523, 0.311]);
 
 [ 0.299   0.587    0.114  ]
 [                         ]
 [ 0.596  - 0.274  - 0.321 ]
 [                         ]
 [ 0.211  - 0.523   0.311  ]
 
 
 YIQtoRGB : matrix([1, 0.956, 0.621], [1, -0.272, -0.647], [1, -1.107, 1.705]);
 
 [ 1   0.956    0.621  ]
 [                     ]
 [ 1  - 0.272  - 0.647 ]
 [                     ]
 [ 1  - 1.107   1.705  ]
 
 
 YIQtoRGB * T * RGBtoYIQ;
 
 [ 0.299 v            0                   0        ]
 [                                                 ]
 [    0     .07452800000000001 vsu  - 0.207687 vsw ]
 [                                                 ]
 [    0     .5789610000000001 vsw    0.530255 vsu  ]
 
 
 RGBtoYIQ * T * YIQtoRGB;
 
 [ 0.299 v            0                   0        ]
 [                                                 ]
 [    0     .07452800000000001 vsu  - 0.207687 vsw ]
 [                                                 ]
 [    0     .5789610000000001 vsw    0.530255 vsu  ]
 
 */

+ (cv::Mat) hsvTransformBlas:(cv::Mat)cvMat hue:(float)hue saturation:(float)saturation value:(float)value
{
    numPixels = cvMat.rows * cvMat.cols;
    vsu = value * saturation * cos(hue * M_PI/180);
    vsw = value * saturation * sin(hue * M_PI/180);
    colorValue = value;
 
    float transformMatrix[9] =
    {
        0.1684 * vsw + 0.700807 * vsu + 0.299 * value, 0.329834 * vsw - 0.586727 * vsu + 0.587 * value, - 0.496657 * vsw - 0.113745 * vsu + 0.114 * value,
        - 0.32822 * vsw - 0.298629 * vsu + 0.299 * value, 0.035022 * vsw + .412909 * vsu + 0.587 * value, 0.292279 * vsw - 0.113905 * vsu + 0.114 * value,
        1.249757 * vsw - 0.3 * vsu + 0.299 * value, - 1.046131 * vsw - 0.588397 * vsu + 0.587 * value, - 0.203028 * vsw + 0.885602 * vsu + 0.114 * value
    };

    /*float transformMatrix[9] =
    {
        0.299 * value,  0,      0,
        0, 0.074528 * vsu, 0.578961 * vsw ,
        0, -0.207687 * vsw, 0.530255 * vsu
    };*/
    
    float* data = (float*)cvMat.data;
    
    pixelArraySize = 4 * numPixels;
    
    float inputPixelsMatrix[3 * numPixels];
    float outputPixelsMatrix[3 * numPixels];
    

    
    for (int i = 0; i < numPixels; i++)
    {
        inputPixelsMatrix[i] = data[4 * i];
        inputPixelsMatrix[numPixels + i] = data[4 * i + 1];
        inputPixelsMatrix[2 * numPixels + i] = data[4 * i + 2];
        outputPixelsMatrix[i] = 0;
        outputPixelsMatrix[numPixels + i] = 0;
        outputPixelsMatrix[2 * numPixels + i] = 0;
        
        
        /*inputPixelsMatrix[3 * i] = data[4 * i];
        inputPixelsMatrix[3 * i + 1] = data[4 * i + 1];
        inputPixelsMatrix[3 * i + 2] = data[4 * i + 2];
        outputPixelsMatrix[3 * i] = 0;
        outputPixelsMatrix[3 * i + 1] = 0;
        outputPixelsMatrix[3 * i + 2] = 0;*/
    }
    
    /*float A[6] = {1, 2, 3, 4, 5, 6};
    float B[15] = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21};
    float C[10] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};*/
    
    //cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, 3, numPixels, 3, 1.0, (double*)transformMatrix, 3, (double*)inputPixelsMatrix, numPixels, 1.0, (double*)outputPixelsMatrix, numPixels);
    
    //cblas_sgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, 2, 5, 3, 1.0, (float*)A, 3, (float*)B, 5, 1.0, (float*)C, 5);
    cblas_sgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, 3, numPixels, 3, 1.0, (float*)transformMatrix, 3, (float*)inputPixelsMatrix, numPixels, 0.0, (float*)outputPixelsMatrix, numPixels);
    /*for (int i = 0; i < 5; i++)
    {
        NSLog(@"%f ", C[i]);
    }
    NSLog(@"\n");
    for (int i = 5; i < 10; i++)
    {
        NSLog(@"%f ", C[i]);
    }
    NSLog(@"\n");*/
    
    for (int i = 0; i < numPixels; i++)
    {
        data[4 * i] = outputPixelsMatrix[i];
        data[4 * i + 1] = outputPixelsMatrix[numPixels + i];
        data[4 * i + 2] = outputPixelsMatrix[2 * numPixels + i];
    }
    
    return cvMat;
}


float* transformHSV(float *pixel_color, float vsu, float vsw, float val_mult)
{
    //float vsu = val_mult * sat_mult * cos(hue_shift * M_PI/180);
    //float vsw = val_mult * sat_mult * sin(hue_shift * M_PI/180);
    
    float r_in = pixel_color[0];
    float g_in = pixel_color[1];
    float b_in = pixel_color[2];
    
    float r_result = (.299 * val_mult + .701 * vsu + .168 * vsw) * r_in
    + (.587 * val_mult - .587 * vsu + .330 * vsw) * g_in
    + (.114 * val_mult - .114 * vsu - .497 * vsw) * b_in;
    float g_result = (.299 * val_mult - .299 * vsu - .328 * vsw) * r_in
    + (.587 * val_mult + .413 * vsu + .035 *vsw) * g_in
    + (.114 * val_mult - .114 * vsu + .292 * vsw) * b_in;
    float b_result = (.299 * val_mult - .3 * vsu + 1.25 * vsw) * r_in
    + (.587 * val_mult - .588 * vsu - 1.05 * vsw) * g_in
    + (.114 * val_mult + .886 * vsu - .203 * vsw) * b_in;
    
    pixel_color[0] = r_result;
    pixel_color[1] = g_result;
    pixel_color[2] = b_result;
    
    return pixel_color;
}

void* hsvTransformThreadWrapper(void* inputpixels)
{
    float *data = (float*)inputpixels;

    for (int i = 0; i < pixelArraySize; i+=8)
    {
        transformHSV(data + i, vsu, vsw, colorValue);
    }
    
    return (void*)data;
}

+ (cv::Mat) hsvTransform:(cv::Mat)cvMat hue:(float)hue saturation:(float)saturation value:(float)value
{
    /*int numPixels = cvMat.rows * cvMat.cols;
    float vsu = value * saturation * cos(hue * M_PI/180);
    float vsw = value * saturation * sin(hue * M_PI/180);*/
    int result;

    numPixels = cvMat.rows * cvMat.cols;
    vsu = value * saturation * cos(hue * M_PI/180);
    vsw = value * saturation * sin(hue * M_PI/180);
    colorValue = value;
    
    pthread_t firstThread, secondThread;
    
    float* data = (float*)cvMat.data;
    
    pixelArraySize = 4 * numPixels;
    
    result = pthread_create(&firstThread, NULL, hsvTransformThreadWrapper, data);
    if (result != 0)
    {
        NSLog(@"First thread: error at start\n");
    }
    
    result = pthread_create(&secondThread, NULL, hsvTransformThreadWrapper, data + 4);
    if (result != 0)
    {
        NSLog(@"Second thread: error at start\n");
    }
    
    result = pthread_join(firstThread, NULL);
    if (result != 0)
    {
        NSLog(@"First thread: error at join\n");
    }
    
    result = pthread_join(secondThread, NULL);
    if (result != 0)
    {
        NSLog(@"Second thread: error at join\n");
    }
    /*for (int i = 0; i < numPixels * 4; i+=4)
    {
        transformHSV(data + i, vsu, vsw, value);
    }*/
    
    return cvMat;
}


+ (cv::Mat) hueTransform:(cv::Mat)cvMat hueSin:(float)hueSin hueCos:(float)hueCos
{
    int numPixels = cvMat.rows * cvMat.cols;
    float* data = (float*)cvMat.data;
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

/*+ (cv::Mat) matchSkinToneF:(cv::Mat)cvMat hue:(float)hue saturation:(float)saturation value:(float)value
{
    int width = cvMat.size().width;
    int height = cvMat.size().height;
    cv::Mat resultCVMat(width, height, CV_32FC4);
    cv::Mat meanCVMat(width, height, CV_32FC4);
    
    MatchSkinToon_f(cvMat, resultCVMat, meanCVMat, hue, saturation, value, true, 0.0, 0.0);
    
    return  resultCVMat;
}*/



void min_max(float *src, float *min, float *max)
{
    float first, second, third;
    float temp_min, temp_max;
    first = *src;
    second = *(src + 1);
    third = *(src + 2);
    temp_min = fmin(first, second);
    temp_max = fmax(first, second);
    *min = fmin(third, temp_min);
    *max = fmax(third, temp_max);
}


void RGBtoHSV(float *src, float *dst, int size)
{
    float min = 0, max = 0, delta;
    
    for(int i = 0; i < size; i += 4)
    {
        // i   = r h
        // i+1 = g s
        // i+2 = b v
        
        
        
        
        //asm_minmax(src+i, 3, &min, &max);
        min_max(src + i, &min, &max);
        
        
        if(max != 0.0f)
        {
            
            delta = (max - min);
            
            if(src[i] == max)
            {
                dst[i] = (src[i+1] - src[i+2]) / delta;		// between yellow & magenta
            }
            else if(src[i+1] == max)
            {
                dst[i] = 2.0f + (src[i+2] - src[i]) / delta;	// between cyan & yellow
            }
            else
            {
                dst[i] = 4.0f + (src[i] - src[i+1]) / delta;	// between magenta & cyan
            }
            
            dst[i] *= 60.0f;				// degrees
            
            if(dst[i] < 0.0f)
            {
                dst[i] += 360.0f;
            }
            
            dst[i+1] = delta / max;
            dst[i+2] = max;
        }
        else
        {
            // r = g = b = 0		// s = 0, v is undefined
            dst[i] = -1.0f;
            dst[i+1] = 0.0f;
            dst[i+2] = max;
            continue;
        }
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
/// <summary>
/// Convert HSV to RGB
/// </summary>
/// <param name="src"></param>
/// <param name="dst"></param>
void HSVtoRGB(float *src, float *dst, int size)
{
    int j;
    float h, f, p, q, t, s;
    
    for(int i = 0; i < size; i += 4)
    {
        // i   = r h
        // i+1 = g s
        // i+2 = b v
        
        if(src[i+1] == 0.0f)
        {
            // achromatic (grey)
            dst[i] = dst[i+1] = dst[i+2] = src[i+4];
            continue;
        }
        
        s = src[i+2];
        
        h = src[i] / 60.0f;		// sector 0 to 5
        j = (int)(h);
        f = h - j;			// factorial part of h
        p = s * (1.0f - src[i+1]);
        q = s * (1.0f - src[i+1] * f);
        t = s * (1.0f - src[i+1] * (1 - f));
        
        
        
        float m[24] = { s, t, p, 0,
            q, s, p, 0,
            p, s, t, 0,
            p, q, s, 0,
            t, p, s, 0,
            s, p, q, 0 };
        
        int row = j << 2;
        
        dst[i] = m[row];
        dst[i+1] = m[row + 1];
        dst[i+2] = m[row + 2];
    }
}



////////////////////////////////////////////////////////////////////////////////////////////////////

cv::Mat MatchSkinToon_f(const cv::Mat& image_RGB, cv::Mat& output, cv::Mat& meanMap,
                                         float hue, float saturation, float value, bool generateMeanMap,
                                         float valStdThresold /*= 0.0f*/, float valStdMax /*= 2.0f*/)
{
    // Mean map
    //cv::Mat meanMap;
    //cv::GaussianBlur(image_RGB, meanMap, cv::Size(201, 201), 0);
    
    // Mean map
    
    if (generateMeanMap) {
        cv::Mat shrinked;
        cv::resize(image_RGB, shrinked, cv::Size(7, 7), 0, 0, cv::INTER_AREA); // 12%?
        cv::resize(shrinked, meanMap, image_RGB.size(), 0, 0, cv::INTER_LINEAR);//38.3%
        RGBtoHSV((float*)meanMap.data, (float*)meanMap.data, image_RGB.size().width * image_RGB.size().height * 4);
    }
    
    //cv::Mat meanMap;
    //cv::boxFilter(image_RGB, meanMap, image_RGB.depth(), cv::Size(201,201));
    
    // To HSV
    cv::Mat image_HSV(image_RGB.rows, image_RGB.cols, image_RGB.type());
    
    float *image_RGB_data = (float*)image_RGB.data;
    float *image_HSV_data =(float*)image_HSV.data;
    
    RGBtoHSV(image_RGB_data, image_HSV_data, image_RGB.size().width * image_RGB.size().height * 4);
    
    int numPixels = image_HSV.rows * image_HSV.cols;
    
    float *image_data = (float*)image_HSV.data;
    float *mean_data = (float*)meanMap.data;
    
    // Adjust hue & saturation
    
    for (int i = 0; i < numPixels * 4; i+=4) {
        float hueColorOffset = hue - mean_data[i];
        float satColorOffset = saturation - mean_data[i+1];
        
        if(saturation < -1)  // Black&White special case
        {
            image_data[i+1] = 0.0f;
        }
        else
        {
            image_data[i+1] += satColorOffset;
        }
        
        image_data[i] += hueColorOffset;
        
        if(image_data[i] < 0.0f)
        {
            image_data[i] += 360.0f;
        }
        else if(image_data[i] > 360.0f)
        {
            image_data[i] -= 360.0f;
        }
    }
    
    // Adjust value
    
    
    cv::Scalar mean = cv::mean(image_HSV);
    //adjustValue(value-mean[2], image_HSV);
    float value_shift = value - mean[2];
    for (int i = 0; i < numPixels * 4; i+=4)
    {
        image_data[i + 2] = image_data[i + 2] + value_shift;
    }
    
    HSVtoRGB((float*)image_HSV.data, (float*)output.data, image_HSV.size().width * image_HSV.size().height * 4);
    return output;
}



@end
