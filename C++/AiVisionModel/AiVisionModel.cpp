#include "AiVisionModel.h"

AiVisionModel::AiVisionModel(const std::string& Param, const std::string& Bin, const std::string& classesJsonPath)
{

    ncnn::set_omp_num_threads(NUM_Threads);
    param = Param;
    bin = Bin;
    class_names = loadClassNames(classesJsonPath);
}

std::vector<std::string> AiVisionModel::loadClassNames(const std::string& json_path)
{
    std::ifstream file(json_path);
    if (!file.is_open()) {
        throw std::runtime_error("Failed to open JSON file: " + json_path);
    }

    nlohmann::json j;
    file >> j;

    if (!j.contains("names") || !j["names"].is_array()) {
        throw std::runtime_error("Invalid JSON format: 'names' array missing");
    }

    return j["names"].get<std::vector<std::string>>();
}
