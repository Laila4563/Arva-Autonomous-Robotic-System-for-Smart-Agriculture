#include "opencv2/opencv.hpp"
#include "opencv2/core/core.hpp"
#include "opencv2/highgui/highgui.hpp"

#include "model.h"
#include "dataType.h"

#include "ncnn/net.h"
#include "ncnn/cpu.h"
#include "ncnn/layer.h"
#include <ncnn/benchmark.h>

typedef unsigned char uint8;



class DeepSort 
{
public:
    DeepSort(std::string bin_path, std::string param_path);
    ~DeepSort();

    bool getRectsFeature(const cv::Mat& img, DETECTIONS& d);
    // virtual bool predict(cv::Mat& frame) { }

private:
    ncnn::Net feature_extractor;
    std::string BIN_PATH;
    std::string PARAM_PATH;
    bool use_gpu = false;
    const int feature_dim = 512;
    const float norm[3] = { 0.229, 0.224, 0.225 };
    const float mean[3] = { 0.485, 0.456, 0.406 };

    ncnn::UnlockedPoolAllocator blob_pool_allocator;
    ncnn::PoolAllocator workspace_pool_allocator;
};
