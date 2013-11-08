#include "SkinToneMatcher.h"

#define _USE_MATH_DEFINES
#include <math.h>
//#include <OpenCV2/opencv.hpp>
//#include "OpenCV/highgui.h"
#ifdef __ARM_NEON__
#include <arm_neon.h>
#endif



#define __max(x,y) ((x) > (y) ? (x) : (y))
#define __min(x,y) ((x) < (y) ? (x) : (y))

static const int NUM_THREADS = 1;


////////////////////////////////////////////////////////////////////////////////////////////////////



#ifdef __ARM_NEON__
////////////////////////////////////////////////////////////////////////////////////////////////////
/// <summary>
/// Convert RGB to HSV
///   [GLaforte - 15-04-2007]
///   Algorithm from http://www.cs.rit.edu/~ncs/color/t_convert.html
///   Written by Nan C. Schaller, Rochester Institute of Technology, Computer Science Department
/// </summary>
/// <param name="src"></param>
/// <param name="dst"></param>
void RGBtoHSV(float32_t *src, float32_t *dst, int size)
{
    float min = 0, max = 0, delta;
    
    for(int i = 0; i < size; i += 3)
    {
        // i   = r h
        // i+1 = g s
        // i+2 = b v
        



        asm_minmax(src+i, 3, &min, &max);
        

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
#endif

#ifdef __ARM_NEON__
////////////////////////////////////////////////////////////////////////////////////////////////////
/// <summary>
/// Convert HSV to RGB
/// </summary>
/// <param name="src"></param>
/// <param name="dst"></param>
void HSVtoRGB(float32_t *src, float32_t *dst, int size)
{
    int j;
    float h, f, p, q, t, s;
    
    for(int i = 0; i < size; i += 3)
    {
        // i   = r h
        // i+1 = g s
        // i+2 = b v
        
        if(src[i+1] == 0.0f)
        {
            // achromatic (grey)
            dst[i] = dst[i+1] = dst[i+2] = src[i+3];
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
#endif


////////////////////////////////////////////////////////////////////////////////////////////////////
#ifdef __ARM_NEON__
void SkinToneMatcher::MatchSkinToon_f(const cv::Mat& image_RGB, cv::Mat& output, cv::Mat& meanMap,
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
        //----
        // RGBtoHSV((float32_t*)meanMap.data, (float32_t*)meanMap.data, image_RGB.size().width * image_RGB.size().height * 3);
        //----
    }
        
    //cv::Mat meanMap;
    //cv::boxFilter(image_RGB, meanMap, image_RGB.depth(), cv::Size(201,201));
    
    // To HSV
    //cv::Mat image_HSV(image_RGB.rows, image_RGB.cols, image_RGB.type());
    
    float32_t *image_RGB_data = (float32_t*)image_RGB.data;
    //----
    // float32_t *image_HSV_data =(float32_t*)image_HSV.data;
    //----
    
    //----
    // RGBtoHSV(image_RGB_data, image_HSV_data, image_RGB.size().width * image_RGB.size().height * 3);
    //----
    
    int numPixels = image_HSV.rows * image_HSV.cols;
    
    //----
    // float32_t *image_data = (float32_t*)image_HSV.data;
    //----
    float32_t *mean_data = (float32_t*)meanMap.data;
    
    // Adjust hue & saturation
    
    /*for (int i = 0; i < numPixels * 3; i+=3) {
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
    }*/
    
    // Adjust value
    
    
    //----
    // cv::Scalar mean = cv::mean(image_HSV);
    // adjustValue(value-mean[2], image_HSV);
    //----
    
    //----
    // HSVtoRGB((float32_t*)image_HSV.data, (float32_t*)output.data, image_HSV.size().width * image_HSV.size().height * 3);
    //----
}
#endif

////////////////////////////////////////////////////////////////////////////////////////////////////
#ifdef __ARM_NEON__
float32_t* TransformHSV(float32_t *pixel_color /* color to transform*/, float32_t hue_shift /* hue shift (in degrees)*/, float32_t sat_mult /*saturation multiplier (scalar)*/, float32_t val_mult /* value multiplier (scalar)*/)
{
    float32_t vsu = val_mult * sat_mult * cos(hue_shift * M_PI/180);
    float32_t vsw = val_mult * sat_mult * sin(hue_shift * M_PI/180);
    
    float32_t r_in = pixel_color[0];
    float32_t g_in = pixel_color[1];
    float32_t b_in = pixel_color[2];
    
    float32_t r_result = (.299 * val_mult + .701 * vsu+ .168 * vsw) * r_in
        + (.587 * val_mult - .587 * vsu + .330 * vsw) * g_in
        + (.114 * val_mult - .114 * vsu - .497 * vsw) * b_in;
    float32_t g_result = (.299 * val_mult - .299 * vsu - .328 * vsw) * r_in
        + (.587 * val_mult + .413 * vsu + .035 *vsw) * g_in
        + (.114 * val_mult - .114 * vsu + .292 * vsw) * b_in;
    float32_t b_result = (.299 * val_mult - .3 * vsu + 1.25 * vsw) * r_in
        + (.587 * val_mult - .588 * vsu - 1.05 * vsw) * g_in
        + (.114 * val_mult + .886 * vsu - .203 * vsw) * b_in;

    pixel_color[0] = r_result;    
    pixel_color[1] = g_result;    
    pixel_color[2] = b_result;    

    return pixel_color;
}
#endif

////////////////////////////////////////////////////////////////////////////////////////////////////
void SkinToneMatcher::OffsetValue(cv::Mat& input, cv::Scalar& offset)
{
    cv::Mat input_RGB;
    input.convertTo(input_RGB, CV_32FC3, 1.0 / 255.0);
    OffsetValue_f(input_RGB, offset);
    input_RGB.convertTo(input, CV_8UC3, 255.0);
}


////////////////////////////////////////////////////////////////////////////////////////////////////
void SkinToneMatcher::OffsetValue_f(cv::Mat& input_RGB, cv::Scalar& offset)
{
    cv::Mat input_HSV;
    cv::cvtColor(input_RGB, input_HSV, CV_RGB2HSV);
    
    if(offset[1] < -1) // Black&White special case
    {
        for(auto itr = input_HSV.begin<cv::Vec3f>(), end = input_HSV.end<cv::Vec3f>();
            itr != end;
            ++itr)
        {
            (*itr)[1] = 0;
            (*itr)[2] += (float)offset[2];
            if((*itr)[2] < 0.0f)
            {
                (*itr)[2] = 0.0f;
            }
            else if((*itr)[2] > 1.0f)
            {
                (*itr)[2] = 1.0f;
            }
        }
    }
    else
    {
        for(auto itr = input_HSV.begin<cv::Vec3f>(), end = input_HSV.end<cv::Vec3f>();
            itr != end;
            ++itr)
        {
            (*itr)[0] += (float)offset[0];
            if((*itr)[0] < 0.0f)
            {
                (*itr)[0] += 360.0f;
            }
            else if((*itr)[0] > 360.0f)
            {
                (*itr)[0] -= 360.0f;
            }
            
            (*itr)[1] += (float)offset[1];
            if((*itr)[1] < 0.0f)
            {
                (*itr)[1] = 0.0f;
            }
            else if((*itr)[2] > 1.0f)
            {
                (*itr)[2] = 1.0f;
            }
            
            (*itr)[2] += (float)offset[2];
            if((*itr)[2] < 0.0f)
            {
                (*itr)[2] = 0.0f;
            }
            else if((*itr)[2] > 1.0f)
            {
                (*itr)[2] = 1.0f;
            }
            
        }
    }
    
    cv::cvtColor(input_HSV, input_RGB, CV_HSV2RGB);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
cv::Scalar SkinToneMatcher::AvgSkinColorHSV_f(const cv::Mat& input)
{
    cv::Mat output(1, 1, CV_32FC3);
    output.setTo(cv::mean(input));
    cv::cvtColor(output, output, CV_RGB2HSV);
    auto color = output.begin<cv::Vec3f>();
    
    return cv::Scalar((*color)[0], (*color)[1], (*color)[2]);
}
