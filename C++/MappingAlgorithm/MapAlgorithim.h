#pragma once
#include <iostream>
#include <cmath>
#include <cstring>
#include <algorithm>
#include <cstdlib>
#include <limits>
#include <functional>
#include <vector>
#include <opencv2/opencv.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>
#include <nlohmann/json.hpp>
#include <mutex>
#include <deque>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

using json = nlohmann::json;

class Map {
public:
	enum class Direction { Left, Right, Top, Bottom, Done };

	// Map cell entity types
	enum class Entities : int {
		freeDistance = 0,
		Obstacle = 1,
		currentLocation = 2,
		Plant = 4
	};

private:
	struct Motion {
		int distance;
		double angle;
		bool done;
		bool unreachable;
		bool hasAngle;
	};

	int** array = nullptr;
	char** dirMap = nullptr;
	unsigned char** tempVisited = nullptr;

	int rows = 0, cols = 0;
	int originRow = 0, originCol = 0;

	float currentX = 0, currentY = 0;
	float targetX = -1, targetY = -1;
	float lastAngle = 90.0f;

	static constexpr int precision = 4; // cm per grid cell

	std::function<void()> onUpdate = nullptr;
	std::function<void(int)> onContinousHandler = nullptr;
	std::function<void(int, float)> onChangeHandler = nullptr;

	// Allocation helpers
	int** allocateArray(int newRows, int newCols);
	char** allocateDirArray(int newRows, int newCols);
	unsigned char** allocateTempVisitedArray(int newRows, int newCols);
	void freeTempVisitedArray(unsigned char** arr, int r);

	// Fixed-map helpers
	bool isInside(int r, int c) const;

	// Movement
	void internalUpdate(float cm, float angle);
	void markRecentCell(int r, int c);
	bool isImmediateBacktrack(int r, int c) const;

	// Robot footprint
	void inflateObstaclesForRobotSize();
	int robotWidthCm = 0;
	int robotHeightCm = 0;
	int robotRadiusCells = 0;

	// Backtrack prevention
	std::deque<std::pair<int, int>> recentCells;
	size_t recentLimit = 4;

	// Thread-safety
	std::mutex mapMutex;

public:
	Map(int widthCm, int heightCm);
	~Map();

	// Handlers
	void setOnUpdate(std::function<void()> handler);
	void setOnContinous(std::function<void(int)> handler);
	void setOnChange(std::function<void(int, float)> handler);

	// Motion API
	void moved(int cm);
	void turn(double angle);
	void apply(Direction movement);

	// Robot size
	void setRobotSizeCm(int widthCm, int heightCm);

	// Memory
	void clearRecentVisits();

	// World interaction
	void add(Entities entity, int distanceCm);

	// Visualization / logic
	void print() const;
	void printValues() const;
	void setTargetLocation(float x, float y);
	float snapToNearestRightAngle(float angle);
	Direction nextMove();
	float normalizeAngle(float angle);
	float calculateRelativeAngle(float prevAngle, float currentAngle);
	Motion NextMove();
	json mapAsJson();
	cv::Mat generatePicture();
};
