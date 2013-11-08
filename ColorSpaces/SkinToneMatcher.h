#pragma once

#include <OpenCV2/opencv.hpp>
//#include <opencv2/opencv.hpp>



class SkinToneMatcher
{
private:
  SkinToneMatcher() {};

public:
  
  //////////////////////////////////////////////////////////////////////////////////////////////////
  // Method:    MatchSkinToon
  // FullName:  SkinToonMatcher::MatchSkinToon
  // Access:    public static 
  // Returns:   void
  // Qualifier:
  // Parameter: cv::Mat & input
  //   Input image.
  // Parameter: cv::Mat & output
  //   Output image (can be the same as input)
  // Parameter: float hue
  //   Target hue
  // Parameter: float saturation
  //   Target saturation
  // Parameter: float value
  //   Target value
  // Parameter: float valStdThresold
  //   Threshold in multiple of value standard deviation. value below (mean - valStdThresold * std)
  //   will be mapped to (mean - valStdThresold * std) ~ (mean - valStdMax * std)
  // Parameter: float valStdMax
  //   Max value standard deviation for output.
  //////////////////////////////////////////////////////////////////////////////////////////////////
    static cv::Scalar MatchSkinToon(const cv::Mat& input, cv::Mat& output,
    float hue, float saturation, float value,
    //float satStdThresold = -0.25f, float satStdMax = 1.75f,
    float valStdThresold = 0.0f, float valStdMax = 3.0f);

  static void MatchSkinToon_f(const cv::Mat& input, cv::Mat& output, cv::Mat& meanMap,
    float hue, float saturation, float value, bool generateMeanMap,
    //float satStdThresold = -0.25f, float satStdMax = 1.75f,
    float valStdThresold = 0.0f, float valStdMax = 3.0f);

  static void OffsetValue(cv::Mat& input, cv::Scalar& offset);
  
  static void OffsetValue_f(cv::Mat& input, cv::Scalar& offset);

  static void RemoveSaturation(cv::Mat& input);

  static void CopyThroughtRegion(const cv::Mat& input, cv::Mat& output);

  static cv::Scalar AvgSkinColorHSV_f(const cv::Mat& input);
};
