#pragma once

#include <string>
#include <vector>
#include <fstream>
#include <stdexcept>
#include <nlohmann/json.hpp>
#include <ncnn/cpu.h>
#include <opencv2/opencv.hpp>
#include <iostream>

#define NUM_Threads 4


class AiVisionModel
{
public:
    explicit AiVisionModel(const std::string& Param, const std::string& Bin, const std::string& classesJsonPath = "");
protected:
    std::vector<std::string> loadClassNames(const std::string& json_path);
    std::vector<std::string> class_names;
    std::string param, bin;
};