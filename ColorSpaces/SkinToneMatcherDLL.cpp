#include <OpenCV2/opencv.hpp>
#include <math.h>
#include <vector>
#include "SkinToneMatcher.h"


#ifdef __ARM_NEON__
#include "libASM.h"
#endif

extern "C"
{
  // for B&W, set saturation to -101
    void MatchSkinTone(char *texture, int *meanMap, int size,
    float hue, float saturation, float value, bool generateMeanMap)
  {
      
#ifdef __ARM_NEON__
    int width = (int)sqrt((float)size);
    cv::Mat input4C(width, width, CV_32FC4, texture);
    cv::Mat input3C(width, width, CV_32FC3);
      
    cv::Mat meanMapMat(width, width, CV_32FC3, meanMap);
      
    asm_rgba_to_rgb((float32_t*)input4C.data, (float32_t*)input3C.data, size);

    SkinToneMatcher::MatchSkinToon_f(input3C, input3C, meanMapMat, hue, saturation / 100, value / 100, generateMeanMap);

    asm_rgb_to_rgba((float32_t*)input3C.data, (float32_t*)input4C.data, size);
#endif
  }

  // for B&W, set saturationOffset to -101
  void OffsetHSV(char *texture, int size,
    float hueOffset, float saturationOffset, float valueOffset)
  {
    int width = (int)sqrt((float)size);

    cv::Mat input4C(width, width, CV_32FC4, texture);
    cv::Mat input3C(width, width, CV_32FC3);

    int from_to[] = {0,0,  1,1,  2,2};  // RGBA -> RGB, RGB -> RGBA
    cv::mixChannels(&input4C, 1, &input3C, 1, from_to, 3);

    cv::Scalar offset(hueOffset, saturationOffset / 100, valueOffset / 100);
      
    SkinToneMatcher::OffsetValue_f(input3C, offset);

    cv::mixChannels(&input3C, 1, &input4C, 1, from_to, 3);
  }

  void AvgSkinColorHSV(char *texture, int size,
    float &hue, float &saturation, float &value)
  {
    int width = (int)sqrt((float)size);

    cv::Mat input4C(width, width, CV_32FC4, texture);
    cv::Scalar avgHSV = SkinToneMatcher::AvgSkinColorHSV_f(input4C);

    hue = (float)avgHSV[0];
    saturation = (float)(avgHSV[1] * 100.0);
    value = (float)(avgHSV[2] * 100);
  }
}