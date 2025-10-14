#pragma once
#include <iostream>
#include <cmath>
#include <cstring>
#include <algorithm>
#include <cstdlib>
#include <limits>
#include <functional>
#include <opencv2/opencv.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>
#include <nlohmann/json.hpp>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif
using json = nlohmann::json;

class Map
{
public:
    enum class Direction
    {
        Left,
        Right,
        Top,
        Bottom,
        Done
    };

private:
    int **array;
    char **dirMap;
    int rows, cols;
    int originRow, originCol;
    float currentX, currentY, targetX = -1, targetY = -1;
    float lastAngle = 90.0f;
    int prealloc_cm = 0;

    float robotLengthCm;
    float robotWidthCm;
    float marginCells;

    static constexpr int precision = 4;
    std::function<void()> onUpdate = nullptr;
    std::function<void(int)> onContinousHandler = nullptr;
    std::function<void(int, float)> onChangeHandler = nullptr;

    int **allocateArray(int newRows, int newCols);
    char **allocateDirArray(int newRows, int newCols);
    void ensureFit(int newRow, int newCol);
    void internalUpdate(float cm, float angle);

public:
    Map(float lengthCM, float widthCM);

    ~Map();
    void setOnUpdate(std::function<void()> handler);
    void setOnContinous(std::function<void(int)> handler);
    void setOnChange(std::function<void(int, float)> handler);
    void update(float cm);
    void update(float cm, float angle);
    void update(float cm, float angle, int estimated_prealloc_cm);
    void updateAngle(float angle);
    void print() const;
    void printValues() const;
    void setTargetLocation(float x, float y);
    float snapToNearestRightAngle(float angle);
    Direction nextMove();
    float normalizeAngle(float angle);
    float calculateRelativeAngle(float prevAngle, float currentAngle);
    void apply(Direction movement);
    json mapAsJson();
    cv::Mat generatePicture();
};
