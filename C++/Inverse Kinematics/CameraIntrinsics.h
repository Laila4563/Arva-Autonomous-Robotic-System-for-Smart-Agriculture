#pragma once
#include <cmath>
#include <fstream>
#include <sstream>
#include <string>
#include <algorithm>
#include <iomanip>
#include <opencv2/opencv.hpp>

struct IntSize {
    int x;
    int y;
};

struct XYf {
    float x;
    float y;
};

class CameraIntrinsics {
public:

    CameraIntrinsics(float Z_m,
        float focal_mm,
        float sensor_w_mm, float sensor_h_mm,
        IntSize sensorRes,
        IntSize currentRes);

    XYf PixelsToDistance(float px, float py) const;


    XYf getOrigin() const;

    float getFx() const;
    float getFy() const;
    float getCx() const;
    float getCy() const;
    void log_debug_line(const std::string& s);
    void DrawRulerDotsDebug(cv::Mat& frame, float cm);

private:

    float Z;
    float fx_native;
    float fy_native;
    float cx_native;
    float cy_native;
    float fx, fy, cx, cy;
    float sx, sy;

    IntSize sensorRes;
    IntSize currentRes;
};