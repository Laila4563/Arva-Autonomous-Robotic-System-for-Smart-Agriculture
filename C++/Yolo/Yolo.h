#pragma once
#ifdef _WIN32
#define NOMINMAX
#endif
#include <fstream>
#include <string>
#include <vector>
#include <opencv2/opencv.hpp>
#include <ncnn/net.h>
#include <opencv2/dnn.hpp>
#include "../AiVisionModel/AiVisionModel.h"
struct ObjectPoints {
    float x, y;
    int   class_id;
    std::string class_name;
};

struct Object {
    cv::Rect_<float> rect;
    int label;
    float prob;
    bool matched;
};

struct PreprocessResult {
    ncnn::Mat  in_mat;
    cv::Mat    im0;
    float      scale;
    int        pad_w;
    int        pad_h;
};

class Yolo : public AiVisionModel {
public:
    Yolo(
        const std::string& param_path,
        const std::string& bin_path,
        const std::string& classesJson,
        int input_w = 640,
        int input_h = 640);

    std::vector<Object> infer(const cv::Mat& frame);
    void view(const cv::Mat& frame, const std::vector<Object>& dets);
    std::vector<ObjectPoints> getObjectPoints(const std::vector<Object>& dets);
    void viewObjectPoints(const cv::Mat& frame, const std::vector<Object>& dets);
    void setResolution(int w, int h);
    int getResX() const;
    int getResY() const;
    void exportPic(const cv::Mat& frame, const std::vector<Object>& dets, const std::string& filename);
private:
    ncnn::Net _net;
    int _input_w;
    int _input_h;
    const float _conf_th = 0.25f;
    const float _nms_th = 0.45f;
    PreprocessResult preprocess(const cv::Mat& bgr);
    std::vector<Object> postprocess(const ncnn::Mat& out, float scale, int pad_w, int pad_h);
    ncnn::Mat extract_tensor(const ncnn::Mat& raw);
};

