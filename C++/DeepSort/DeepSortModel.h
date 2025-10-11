#pragma once
#include <memory>
#include <vector>
#include <string>
#include <opencv2/opencv.hpp>
#include <iomanip>
#include <sstream>
#include "DeepSort/deepsort.h"
#include "KalmanFilter/tracker.h"
#include "../Yolo/Yolo.h"
#include "../AiVisionModel/AiVisionModel.h"


struct DeepSortResult {
    cv::Rect_<float> box;
    int        track_id;     
    float      score;        
    int        class_id;     
    std::string class_name;  
};


class DeepSortModel : public AiVisionModel {
public:
    DeepSortModel(const std::string& deepsort_param, const std::string& deepsort_bin, const std::string& classesJson);

    std::vector<DeepSortResult> infer(cv::Mat& frame,
         std::vector<Object>& dets);

    void view(const cv::Mat& frame, const std::vector<DeepSortResult>& results, const std::string& winname = "DeepSort");
    void exportDeepSortPic(const cv::Mat& frame, const std::vector<DeepSortResult>& results, const std::string& filename);
private:
    void get_detections(const cv::Rect_<float>& rect, float confidence, DETECTIONS& d);
    void postprocess(cv::Mat& frame, const std::vector<Object>& outs, DETECTIONS& d);

    void matchDeepSortResult(DeepSortResult& ds_result, std::vector<Object>& dets);
    std::unique_ptr<DeepSort> deepSort_;   
    std::unique_ptr<tracker> id_tracker_;
};

