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

	// Map cell entity types (use these when writing into array[r][c])
	enum class Entities : int {
		freeDistance = 0,
		Obstacle = 1,
		currentLocation = 2,
		Plant = 4
	};

private:
	struct Motion {
		int distance;    // centimeters to move forward (0 => no move)
		double angle;    // degrees to turn relative to current heading (positive CCW)
		bool done;       // true when target reached or cleared (no more motion)
		bool unreachable; // true when the target was cleared because it's unreachable
		bool hasAngle;   // true when angle != 0 (caller should rotate)
	};
	int** array;
	char** dirMap;
	int rows, cols;
	int originRow, originCol;
	float currentX, currentY, targetX = -1, targetY = -1;
	float lastAngle = 90.0f;
	int prealloc_cm = 0;

	static constexpr int precision = 4; // cm per grid cell

	std::function<void()> onUpdate = nullptr;
	std::function<void(int)> onContinousHandler = nullptr;
	std::function<void(int, float)> onChangeHandler = nullptr;

	int** allocateArray(int newRows, int newCols);
	char** allocateDirArray(int newRows, int newCols);
	void ensureFit(int newRow, int newCol);
	void internalUpdate(float cm, float angle); // existing movement logic
	// mark that robot occupied grid cell (r,c) in recent history
	void markRecentCell(int r, int c);

	// whether moving into (r,c) is disallowed as immediate backtrack
	bool isImmediateBacktrack(int r, int c) const;

	// compute/refresh inflated obstacles according to robotRadiusCells
	// call this after setRobotSizeCm or when map layout changes
	void inflateObstaclesForRobotSize();

	// allocate and free tempVisited grid like array/dirMap
	unsigned char** allocateTempVisitedArray(int newRows, int newCols);
	void freeTempVisitedArray(unsigned char** arr, int r);

	// Thread-safety
	std::mutex mapMutex;

	// Robot footprint (cm)
	int robotWidthCm = 0;
	int robotHeightCm = 0;
	int robotRadiusCells = 0; // computed from width/height and precision

	// Temporary "recent visit" memory to avoid immediate backtracking
	std::deque<std::pair<int, int>> recentCells; // store recent grid cells visited (r,c)
	size_t recentLimit = 4; // small fixed window, adjust if needed

	// Optional fast per-cell temporary marker (same size as array)
	// 0 = not recently visited, 1 = recently visited
	unsigned char** tempVisited = nullptr;

public:
	
	Map();
	~Map();

	// Handlers
	void setOnUpdate(std::function<void()> handler);
	void setOnContinous(std::function<void(int)> handler);
	void setOnChange(std::function<void(int, float)> handler);

	// New API (replaces the old update overloads)
	// moved: move straight for 'cm' centimeters using the current heading (lastAngle).
	void moved(int cm);
	// sizing
	void setRobotSizeCm(int widthCm, int heightCm);

	// temp-visit control (exposed so tests can clear/inspect)
	void clearRecentVisits();


	// turn: rotate by 'angle' degrees (positive = CCW, negative = CW).
	// Subdivision handling is internal (no position change).
	void turn(double angle);

	// Kept for backwards compatibility: apply chooses direction and performs turn+move
	void apply(Direction movement);

	// Add an entity at 'distanceCm' in front of current location (user-provided semantics).
	// distanceCm measured in centimeters; function maps that to nearest grid cell.
	void add(Entities entity, int distanceCm);

	// Visual / debug / io
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

