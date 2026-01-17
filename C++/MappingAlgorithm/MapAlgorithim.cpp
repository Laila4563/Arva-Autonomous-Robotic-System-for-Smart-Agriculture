#include "MapAlgorithim.h"
#include <mutex>
#include <deque>

// --------------------- Implementation --------------------------

int** Map::allocateArray(int newRows, int newCols) {
	int** newArray = new int* [newRows];
	for (int i = 0; i < newRows; ++i)
		newArray[i] = new int[newCols]();
	return newArray;
}

char** Map::allocateDirArray(int newRows, int newCols)
{
	char** newDirMap = new char* [newRows];
	for (int i = 0; i < newRows; ++i) {
		newDirMap[i] = new char[newCols];
		std::memset(newDirMap[i], ' ', newCols);
	}
	return newDirMap;
}

unsigned char** Map::allocateTempVisitedArray(int newRows, int newCols)
{
	unsigned char** arr = new unsigned char* [newRows];
	for (int i = 0; i < newRows; ++i) {
		arr[i] = new unsigned char[newCols]();
	}
	return arr;
}

void Map::freeTempVisitedArray(unsigned char** arr, int r)
{
	if (!arr) return;
	for (int i = 0; i < r; ++i)
		delete[] arr[i];
	delete[] arr;
}

//void Map::ensureFit(int newRow, int newCol)
//{
//	int padTop = 0, padBottom = 0, padLeft = 0, padRight = 0;
//
//	if (newRow < 0)
//		padTop = (prealloc_cm > 0) ? std::max(prealloc_cm / precision, -newRow) : -newRow;
//	if (newRow >= rows)
//		padBottom = (prealloc_cm > 0) ? std::max(prealloc_cm / precision, newRow - rows + 1) : newRow - rows + 1;
//	if (newCol < 0)
//		padLeft = (prealloc_cm > 0) ? std::max(prealloc_cm / precision, -newCol) : -newCol;
//	if (newCol >= cols)
//		padRight = (prealloc_cm > 0) ? std::max(prealloc_cm / precision, newCol - cols + 1) : newCol - cols + 1;
//
//	if (padTop == 0 && padBottom == 0 && padLeft == 0 && padRight == 0)
//		return;
//
//	int newRows = rows + padTop + padBottom;
//	int newCols = cols + padLeft + padRight;
//	int** newArray = allocateArray(newRows, newCols);
//	char** newDirMap = allocateDirArray(newRows, newCols);
//	unsigned char** newTempVisited = allocateTempVisitedArray(newRows, newCols);
//
//	for (int i = 0; i < rows; ++i) {
//		std::memcpy(newArray[i + padTop] + padLeft, array[i], cols * sizeof(int));
//		std::memcpy(newDirMap[i + padTop] + padLeft, dirMap[i], cols * sizeof(char));
//		if (tempVisited)
//			std::memcpy(newTempVisited[i + padTop] + padLeft, tempVisited[i], cols * sizeof(unsigned char));
//
//	}
//	freeTempVisitedArray(tempVisited, rows);
//
//	for (int i = 0; i < rows; ++i) {
//		delete[] array[i];
//		delete[] dirMap[i];
//	}
//	delete[] array;
//	delete[] dirMap;
//
//	array = newArray;
//	dirMap = newDirMap;
//	tempVisited = newTempVisited;
//
//	originRow += padTop;
//	originCol += padLeft;
//	currentY += padTop;
//	currentX += padLeft;
//	rows = newRows;
//	cols = newCols;
//}
bool Map::isInside(int r, int c) const
{
	return (r >= 0 && r < rows && c >= 0 && c < cols);
}

void Map::internalUpdate(float cm, float angle)
{
	float angleRad = angle * M_PI / 180.0f;
	float dx = std::cos(angleRad);
	float dy = -std::sin(angleRad);

	int subdivisions = std::max(2, (int)std::ceil(cm / (precision / 2.0f)));
	float subDistCells = (cm / precision) / subdivisions;

	for (int i = 0; i < subdivisions; ++i) {
		float nextX = currentX + dx * subDistCells;
		float nextY = currentY + dy * subDistCells;

		int r = (int)std::round(nextY);
		int c = (int)std::round(nextX);

		// ❗ HARD STOP AT MAP BOUNDARY
		if (!isInside(r, c))
			break;

		currentX = nextX;
		currentY = nextY;

		markRecentCell(r, c);
		dirMap[r][c] = (std::abs(dx) > std::abs(dy)) ? 'H' : 'V';
	}
}


Map::Map(int widthCm, int heightCm)
{
	cols = widthCm / precision;
	rows = heightCm / precision;

	if (cols <= 0) cols = 1;
	if (rows <= 0) rows = 1;

	array = allocateArray(rows, cols);
	dirMap = allocateDirArray(rows, cols);
	tempVisited = allocateTempVisitedArray(rows, cols);

	// Start robot in CENTER of map
	currentX = cols / 2.0f;
	currentY = rows / 2.0f;

	originRow = 0;
	originCol = 0;

	array[(int)currentY][(int)currentX] =
		static_cast<int>(Entities::currentLocation);

	dirMap[(int)currentY][(int)currentX] = 'S';
}


Map::~Map()
{
	for (int i = 0; i < rows; ++i) {
		delete[] array[i];
		delete[] dirMap[i];
	}
	delete[] array;
	delete[] dirMap;
	freeTempVisitedArray(tempVisited, rows);

}

void Map::setOnUpdate(std::function<void()> handler)
{
	onUpdate = std::move(handler);
}

void Map::setOnContinous(std::function<void(int)> handler)
{
	onContinousHandler = std::move(handler);
}

void Map::setOnChange(std::function<void(int, float)> handler)
{
	onChangeHandler = std::move(handler);
}

// New API implementations

void Map::moved(int cm)
{
	std::lock_guard<std::mutex> lock(mapMutex);

	// Notify continuous movement (if any)
	if (onContinousHandler) {
		onContinousHandler(cm);
	}

	// Perform movement at the current heading
	internalUpdate(static_cast<float>(cm), lastAngle);

	// Fire general update
	if (onUpdate) {
		onUpdate();
	}
}

void Map::turn(double angle)
{
	std::lock_guard<std::mutex> lock(mapMutex);

	// Compute angles and notify change
	float prevAngleSnap = snapToNearestRightAngle(lastAngle);
	float newAngle = lastAngle + static_cast<float>(angle);
	float newAngleSnap = snapToNearestRightAngle(newAngle);

	float relativeAngle = calculateRelativeAngle(prevAngleSnap, newAngleSnap);

	if (onChangeHandler) {
		onChangeHandler(precision, relativeAngle);
	}

	lastAngle = newAngle; // update heading (keeps fractional angles)
	if (onUpdate) {
		onUpdate();
	}
}

void Map::apply(Direction movement)
{
	std::lock_guard<std::mutex> lock(mapMutex);

	float prevAngle = snapToNearestRightAngle(lastAngle);
	float currentAngle = 0;
	switch (movement) {
	case Direction::Top:
		currentAngle = 90;
		break;
	case Direction::Left:
		currentAngle = 180;
		break;
	case Direction::Bottom:
		currentAngle = 270;
		break;
	case Direction::Right:
		currentAngle = 0;
		break;
	default:
		return;
	}

	float relativeAngle = calculateRelativeAngle(prevAngle, currentAngle);

	if (prevAngle == currentAngle)
	{
		if (onContinousHandler) {
			onContinousHandler(precision);
		}
		// move forward precision cm
		moved(precision);
	}
	else
	{
		if (onChangeHandler) {
			onChangeHandler(precision, relativeAngle);
		}
		// rotate then move forward precision cm (keeps same behavior as before)
		turn(relativeAngle);
		moved(precision);
	}
}

void Map::add(Entities entity, int distanceCm)
{
	float angleRad = lastAngle * M_PI / 180.0f;
	float dx = std::cos(angleRad);
	float dy = -std::sin(angleRad);

	int cells = (int)std::round((float)distanceCm / precision);

	int r = (int)std::round(currentY + dy * cells);
	int c = (int)std::round(currentX + dx * cells);

	if (!isInside(r, c))
		return;

	array[r][c] = static_cast<int>(entity);

	if (entity == Entities::Obstacle || entity == Entities::Plant)
		inflateObstaclesForRobotSize();
}


void Map::print() const
{
	for (int i = 0; i < rows; ++i) {
		for (int j = 0; j < cols; ++j) {
			if (i == static_cast<int>(std::round(currentY)) && j == static_cast<int>(std::round(currentX)))
				std::cout << "2";
			else if (array[i][j] == static_cast<int>(Entities::Obstacle))
				std::cout << "1";
			else
				std::cout << " ";
		}
		std::cout << '\n';
	}
}

void Map::printValues() const
{
	for (int i = 0; i < rows; ++i) {
		for (int j = 0; j < cols; ++j)
			std::cout << array[i][j] << " ";
		std::cout << '\n';
	}
}

void Map::setTargetLocation(float x, float y)
{
	std::lock_guard<std::mutex> lock(mapMutex);

	targetX = x; targetY = y;
}

float Map::snapToNearestRightAngle(float angle)
{
	angle = fmod(angle, 360.0f);
	if (angle < 0) angle += 360.0f;

	float options[] = { 0.0f, 90.0f, 180.0f, 270.0f };

	float closest = options[0];
	float minDiff = std::abs(angle - closest);
	for (int i = 1; i < 4; ++i) {
		float diff = std::abs(angle - options[i]);
		if (diff < minDiff) {
			minDiff = diff;
			closest = options[i];
		}
	}

	return closest;
}

Map::Direction Map::nextMove()
{
	std::lock_guard<std::mutex> lock(mapMutex);

	if (targetY == -1 || targetX == -1)
	{
		return Direction::Done;
	}

	int curCol = static_cast<int>(std::round(currentX));
	int curRow = static_cast<int>(std::round(currentY));
	int tgtCol = static_cast<int>(std::round(targetX));
	int tgtRow = static_cast<int>(std::round(targetY));


	const float doneThreshold = 0.5f;
	if (std::hypot(targetX - currentX, targetY - currentY) <= doneThreshold) {
		return Direction::Done;
	}


	int dx = tgtCol - curCol;
	int dy = tgtRow - curRow;


	auto isFree = [&](int r, int c) -> bool {
		if (r < 0 || r >= rows || c < 0 || c >= cols) {
			return true;
		}
		return array[r][c] == static_cast<int>(Entities::freeDistance);
	};

	auto manhattan = [&](int r, int c) -> int {
		return std::abs(tgtRow - r) + std::abs(tgtCol - c);
	};


	std::vector<std::pair<Direction, std::pair<int, int>>> candidates;
	bool preferX = (std::abs(dx) >= std::abs(dy));


	auto pushCandidate = [&](Direction dir, int r, int c) {
		candidates.emplace_back(dir, std::make_pair(r, c));
	};

	if (preferX) {
		if (dx > 0) pushCandidate(Direction::Right, curRow, curCol + 1);
		else if (dx < 0) pushCandidate(Direction::Left, curRow, curCol - 1);

		if (dy > 0) pushCandidate(Direction::Bottom, curRow + 1, curCol);
		else if (dy < 0) pushCandidate(Direction::Top, curRow - 1, curCol);
	}
	else {
		if (dy > 0) pushCandidate(Direction::Bottom, curRow + 1, curCol);
		else if (dy < 0) pushCandidate(Direction::Top, curRow - 1, curCol);

		if (dx > 0) pushCandidate(Direction::Right, curRow, curCol + 1);
		else if (dx < 0) pushCandidate(Direction::Left, curRow, curCol - 1);
	}


	pushCandidate(Direction::Top, curRow - 1, curCol);
	pushCandidate(Direction::Bottom, curRow + 1, curCol);
	pushCandidate(Direction::Left, curRow, curCol - 1);
	pushCandidate(Direction::Right, curRow, curCol + 1);


	std::vector<std::pair<Direction, std::pair<int, int>>> uniqueCandidates;
	for (auto& p : candidates) {
		bool seen = false;
		for (auto& q : uniqueCandidates) {
			if (q.first == p.first) { seen = true; break; }
		}
		if (!seen) uniqueCandidates.push_back(p);
	}


	int currentDist = manhattan(curRow, curCol);
	for (auto& c : uniqueCandidates) {
		int nr = c.second.first;
		int nc = c.second.second;
		if (!isFree(nr, nc)) continue;
		int newDist = manhattan(nr, nc);
		if (newDist < currentDist) {
			return c.first;
		}
	}

	for (auto& c : uniqueCandidates) {
		int nr = c.second.first;
		int nc = c.second.second;
		if (isFree(nr, nc)) {
			return c.first;
		}
	}

	targetX = -1; targetY = -1;
	return Direction::Done;
}


float Map::normalizeAngle(float angle)
{
	while (angle < 0) angle += 360;
	while (angle >= 360) angle -= 360;
	return angle;
}

float Map::calculateRelativeAngle(float prevAngle, float currentAngle)
{
	float angleDiff = currentAngle - prevAngle;
	angleDiff = normalizeAngle(angleDiff);

	if (angleDiff > 180) {
		angleDiff -= 360;
	}
	return angleDiff;
}




Map::Motion Map::NextMove()
{
	Motion out{ 0, 0.0, false, false, false };

	// No target set -> done but not necessarily "unreachable"
	if (targetX == -1 || targetY == -1) {
		out.done = true;
		out.unreachable = false;
		out.hasAngle = false;
		return out;
	}

	// vector to target in grid-cells
	float dxCells = targetX - currentX;
	float dyCells = targetY - currentY;

	const float doneThreshold = 0.5f; // cells
	if (std::hypot(dxCells, dyCells) <= doneThreshold) {
		// Reached target -> mark done
		out.done = true;
		out.unreachable = false;
		out.hasAngle = false;
		out.distance = 0;
		out.angle = 0.0;
		return out;
	}

	auto cellIsFree = [&](int r, int c) -> bool {
		if (!isInside(r, c)) return false;
		int v = array[r][c];
		return (v == static_cast<int>(Entities::freeDistance) || v == static_cast<int>(Entities::currentLocation));
		};

	auto cellIsBlocked = [&](int r, int c) -> bool {
		if (r < 0 || r >= rows || c < 0 || c >= cols) return true;
		int v = array[r][c];
		return (v == static_cast<int>(Entities::Obstacle) || v == static_cast<int>(Entities::Plant));
		};

	auto finalize = [&](int distCm, double angleDeg, bool doneFlag, bool unreachableFlag) -> Map::Motion {
		Map::Motion m;
		m.distance = distCm;
		m.angle = angleDeg;
		m.done = doneFlag;
		m.unreachable = unreachableFlag;
		m.hasAngle = (std::abs(angleDeg) > 1e-3);
		return m;
		};

	int curCol = static_cast<int>(std::round(currentX));
	int curRow = static_cast<int>(std::round(currentY));
	int tgtCol = static_cast<int>(std::round(targetX));
	int tgtRow = static_cast<int>(std::round(targetY));

	// If target cell itself is blocked -> explicitly unreachable (do NOT return done=true)
	if (tgtRow < 0 || tgtRow >= rows || tgtCol < 0 || tgtCol >= cols || cellIsBlocked(tgtRow, tgtCol)) {
		return finalize(0, 0.0, false, true);
	}

	// 1) Try direct straight-line motion (line-of-sight) from current to target.
	{
		const int samples = std::max(2, static_cast<int>(std::ceil(std::max(std::abs(dxCells), std::abs(dyCells)) * 2.0f)));
		bool blocked = false;
		int maxSafeSample = samples;

		for (int i = 1; i <= samples; ++i) {
			float t = static_cast<float>(i) / static_cast<float>(samples);
			float sx = currentX + dxCells * t;
			float sy = currentY + dyCells * t;
			int rr = static_cast<int>(std::round(sy));
			int cc = static_cast<int>(std::round(sx));

			if (cellIsBlocked(rr, cc) || isImmediateBacktrack(rr, cc)) {
				blocked = true;
				maxSafeSample = i - 1;
				break;
			}
		}

		if (!blocked) {
			// line fully free -> go straight to target
			float distCells = std::hypot(dxCells, dyCells);
			int distCm = static_cast<int>(std::round(distCells * precision));
			double angleToTargetDeg = std::atan2(-dyCells, dxCells) * 180.0 / M_PI;
			double relative = calculateRelativeAngle(lastAngle, static_cast<float>(angleToTargetDeg));
			return finalize(distCm, relative, false, false);
		}
		else if (maxSafeSample > 0) {
			// move to farthest free sample point (stops before any plant/obstacle)
			float t = static_cast<float>(maxSafeSample) / static_cast<float>(samples);
			float sx = currentX + dxCells * t;
			float sy = currentY + dyCells * t;
			float distCells = std::hypot(sx - currentX, sy - currentY);
			int distCm = static_cast<int>(std::round(distCells * precision));
			double angleToTargetDeg = std::atan2(-dyCells, dxCells) * 180.0 / M_PI;
			double relative = calculateRelativeAngle(lastAngle, static_cast<float>(angleToTargetDeg));
			if (distCm > 0) {
				return finalize(distCm, relative, false, false);
			}
			// else fallthrough to pathfinding/avoidance
		}
	}

	// A* helper that returns a path (vector of {row,col}) if found
	auto runAStar = [&](int startR, int startC, int goalR, int goalC, std::vector<std::pair<int, int>>& outPath, int maxNodesToExplore = -1) -> bool {
		outPath.clear();
		if (startR < 0 || startR >= rows || startC < 0 || startC >= cols) return false;
		if (goalR < 0 || goalR >= rows || goalC < 0 || goalC >= cols) return false;
		if (cellIsBlocked(startR, startC) || cellIsBlocked(goalR, goalC)) return false;

		const int totalCells = rows * cols;
		auto idx = [&](int r, int c) { return r * cols + c; };

		const float INF_F = std::numeric_limits<float>::infinity();
		std::vector<float> gScore(totalCells, INF_F);
		std::vector<int> parent(totalCells, -1);
		std::vector<char> closed(totalCells, 0);

		struct Node { float f; int r; int c; };
		struct Cmp {
			bool operator()(Node const& a, Node const& b) const { return a.f > b.f; }
		};
		std::priority_queue<Node, std::vector<Node>, Cmp> open;

		auto heuristic = [&](int r, int c) -> float {
			return static_cast<float>(std::abs(r - goalR) + std::abs(c - goalC));
			};

		int startIdx = idx(startR, startC);
		gScore[startIdx] = 0.0f;
		parent[startIdx] = startIdx;
		open.push({ heuristic(startR, startC), startR, startC });

		int nodesSearched = 0;
		const int maxNodes = (maxNodesToExplore <= 0) ? totalCells : std::min(totalCells, maxNodesToExplore);

		const int drs[4] = { -1, 1, 0, 0 };
		const int dcs[4] = { 0, 0, -1, 1 };

		bool found = false;

		while (!open.empty() && (maxNodesToExplore <= 0 || nodesSearched < maxNodes)) {
			Node n = open.top(); open.pop();
			int r = n.r, c = n.c;
			int i = idx(r, c);
			if (closed[i]) continue;
			closed[i] = 1;
			++nodesSearched;

			if (r == goalR && c == goalC) { found = true; break; }

			for (int k = 0; k < 4; ++k) {
				int nr = r + drs[k];
				int nc = c + dcs[k];
				if (nr < 0 || nr >= rows || nc < 0 || nc >= cols) continue;
				if (cellIsBlocked(nr, nc)) continue;
				if (isImmediateBacktrack(nr, nc))
					continue;
				int ni = idx(nr, nc);
				if (closed[ni]) continue;
				float cellCost = 1.0f;
				int cellValue = array[nr][nc];
				if (cellValue == static_cast<int>(Entities::Plant)) {
					cellCost = 100.0f; // High penalty for plants
				}
				// Obstacles already handled by cellIsBlocked()
				float tentative_g = gScore[i] + cellCost;
				if (tentative_g < gScore[ni]) {
					gScore[ni] = tentative_g;
					parent[ni] = i;
					float f = tentative_g + heuristic(nr, nc);
					open.push({ f, nr, nc });
				}
			}
		}

		if (!found) return false;

		// reconstruct path
		int cur = idx(goalR, goalC);
		while (parent[cur] != cur) {
			int r = cur / cols;
			int c = cur % cols;
			outPath.emplace_back(r, c);
			cur = parent[cur];
		}
		// add start
		int sr = cur / cols;
		int sc = cur % cols;
		outPath.emplace_back(sr, sc);
		std::reverse(outPath.begin(), outPath.end());
		return true;
		};

	// 2) Try A* from the rounded current cell directly (if free)
	std::vector<std::pair<int, int>> path;
	bool directStartTried = false;
	if (cellIsFree(curRow, curCol)) {
		directStartTried = true;
		if (runAStar(curRow, curCol, tgtRow, tgtCol, path)) {
			// We have a path. Choose the first actionable cell to head toward
			if (path.size() >= 2) {
				auto nextCell = path[1];
				float dx = static_cast<float>(nextCell.second) - currentX;
				float dy = static_cast<float>(nextCell.first) - currentY; // row is y
				float distCmF = std::hypot(dx, dy) * precision;
				int distCm = static_cast<int>(std::round(distCmF));
				double angleToTargetDeg = std::atan2(-dy, dx) * 180.0 / M_PI;
				double relative = calculateRelativeAngle(lastAngle, static_cast<float>(angleToTargetDeg));
				if (distCm > 0) return finalize(distCm, relative, false, false);
				// else fallthrough
			}
		}
	}

	// 3) If A* failed or current cell wasn't free, try nearby candidate start cells.
	//    We perform a small flood to gather free cells within radius then run A* from each.
	const int candidateRadius = 5; // configurable: how far (in cells) to search for alternative starts
	std::vector<std::pair<int, int>> candidates;

	for (int r = curRow - candidateRadius; r <= curRow + candidateRadius; ++r) {
		for (int c = curCol - candidateRadius; c <= curCol + candidateRadius; ++c) {
			if (r < 0 || r >= rows || c < 0 || c >= cols) continue;
			if (!cellIsFree(r, c)) continue;
			// only consider candidates that are reachable in continuous space (rough check: distance in cells)
			float dCells = std::hypot(static_cast<float>(r) - currentY, static_cast<float>(c) - currentX);
			if (dCells > candidateRadius) continue;
			candidates.emplace_back(r, c);
		}
	}

	if (candidates.empty()) {
		// No free neighbor cells to try -> unreachable (robot is boxed in)
		return finalize(0, 0.0, false, true);
	}

	// For each candidate, run A*. Choose the candidate with the smallest "initial move + path length" cost.
	bool foundAny = false;
	double bestCost = std::numeric_limits<double>::infinity();
	std::vector<std::pair<int, int>> bestPath;
	std::pair<int, int> bestStart = { -1,-1 };

	for (auto& cand : candidates) {
		std::vector<std::pair<int, int>> p;
		if (!runAStar(cand.first, cand.second, tgtRow, tgtCol, p)) continue;
		// compute initial continuous distance from current position to the first path cell that is not the current rounded cell
		std::pair<int, int> firstCell = p.front();
		std::pair<int, int> nextCell;
		if (firstCell.first == curRow && firstCell.second == curCol) {
			if (p.size() >= 2) nextCell = p[1];
			else nextCell = p[0];
		}
		else {
			nextCell = firstCell;
		}

		float dx = static_cast<float>(nextCell.second) - currentX;
		float dy = static_cast<float>(nextCell.first) - currentY;
		double initialMoveCm = std::hypot(dx, dy) * precision;

		// path length in cells (approx) = p.size() - 1
		double pathLenCm = static_cast<double>(std::max(0, static_cast<int>(p.size()) - 1)) * precision;

		double totalCost = initialMoveCm + pathLenCm;
		if (totalCost < bestCost) {
			bestCost = totalCost;
			bestPath = p;
			bestStart = cand;
			foundAny = true;
		}
	}

	if (!foundAny) {
		// No candidate produced a path -> unreachable
		return finalize(0, 0.0, false, true);
	}

	// We have bestPath starting at bestStart. Determine the first actionable cell to move toward from actual continuous position.
	std::pair<int, int> firstCell = bestPath.front();
	std::pair<int, int> nextCell;
	if (firstCell.first == curRow && firstCell.second == curCol) {
		if (bestPath.size() >= 2) nextCell = bestPath[1];
		else nextCell = bestPath[0];
	}
	else {
		nextCell = firstCell;
	}

	float dx = static_cast<float>(nextCell.second) - currentX;
	float dy = static_cast<float>(nextCell.first) - currentY;
	int distCm = static_cast<int>(std::round(std::hypot(dx, dy) * precision));
	double angleToTargetDeg = std::atan2(-dy, dx) * 180.0 / M_PI;
	double relative = calculateRelativeAngle(lastAngle, static_cast<float>(angleToTargetDeg));

	if (distCm > 0) return finalize(distCm, relative, false, false);

	// fallback - should not get here
	return finalize(0, 0.0, false, true);
}



json Map::mapAsJson()
{
	std::lock_guard<std::mutex> lock(mapMutex);

	json jsonObject;

	jsonObject["array"] = json::array();
	for (int i = 0; i < rows; ++i) {
		json row = json::array();
		for (int jIndex = 0; jIndex < cols; ++jIndex) {
			row.push_back(array[i][jIndex]);
		}
		jsonObject["array"].push_back(row);
	}

	jsonObject["currentX"] = currentX;
	jsonObject["currentY"] = currentY;

	jsonObject["rows"] = rows;
	jsonObject["cols"] = cols;
	jsonObject["precision"] = precision;
	return jsonObject;
}

cv::Mat Map::generatePicture()
{
	std::lock_guard<std::mutex> lock(mapMutex);

	const int minFinalWidth = 1280;
	const int minFinalHeight = 720;
	const int baseCellPixelSize = 10;

	int gridWidth = cols * baseCellPixelSize;
	int gridHeight = rows * baseCellPixelSize;

	int currentColIdx = static_cast<int>(std::round(currentX));
	int currentRowIdx = static_cast<int>(std::round(currentY));
	int targetColIdx = static_cast<int>(std::round(targetX));
	int targetRowIdx = static_cast<int>(std::round(targetY));
	cv::Mat gridImage(gridHeight, gridWidth, CV_8UC3, cv::Scalar(0, 0, 0));
	for (int i = 0; i < rows; i++) {
		for (int j = 0; j < cols; j++) {

			if (i == currentRowIdx && j == currentColIdx) {
				cv::rectangle(gridImage,
					cv::Rect(j * baseCellPixelSize, i * baseCellPixelSize, baseCellPixelSize, baseCellPixelSize),
					cv::Scalar(0, 255, 0),
					cv::FILLED);
			}
			else if (i == targetRowIdx && j == targetColIdx)
			{
				cv::rectangle(gridImage,
					cv::Rect(j * baseCellPixelSize, i * baseCellPixelSize, baseCellPixelSize, baseCellPixelSize),
					cv::Scalar(255, 0, 0),
					cv::FILLED);
			}
			else if (array[i][j] == static_cast<int>(Entities::Obstacle)) {
				cv::rectangle(gridImage,
					cv::Rect(j * baseCellPixelSize, i * baseCellPixelSize, baseCellPixelSize, baseCellPixelSize),
					cv::Scalar(255, 255, 255),
					cv::FILLED);
			}
			else if (array[i][j] == static_cast<int>(Entities::Plant)) {
				cv::rectangle(gridImage,
					cv::Rect(j * baseCellPixelSize, i * baseCellPixelSize, baseCellPixelSize, baseCellPixelSize),
					cv::Scalar(0, 128, 0),
					cv::FILLED);
			}
			else if (array[i][j] == static_cast<int>(Entities::currentLocation)) {
				cv::rectangle(gridImage,
					cv::Rect(j * baseCellPixelSize, i * baseCellPixelSize, baseCellPixelSize, baseCellPixelSize),
					cv::Scalar(0, 255, 255),
					cv::FILLED);
			}
			else if (i == 0 || j == 0 || j == (cols - 1) || i == (rows - 1))
			{
				cv::rectangle(gridImage,
					cv::Rect(j * baseCellPixelSize, i * baseCellPixelSize, baseCellPixelSize, baseCellPixelSize),
					cv::Scalar(255, 255, 255),
					cv::FILLED);
			}
		}
	}

	cv::Mat gray;
	cv::cvtColor(gridImage, gray, cv::COLOR_BGR2GRAY);
	cv::Mat edges;
	cv::Canny(gray, edges, 50, 150, 3);

	std::vector<cv::Vec4i> detectedLines;
	cv::HoughLinesP(edges, detectedLines, 1, CV_PI / 180, 30, 30, 5);

	double scaleFactor = 1.5;

	int scaledGridWidth = static_cast<int>(gridWidth * scaleFactor);
	int scaledGridHeight = static_cast<int>(gridHeight * scaleFactor);

	int finalWidth = std::max(minFinalWidth, scaledGridWidth);
	int finalHeight = std::max(minFinalHeight, scaledGridHeight);

	int offsetX = (finalWidth - scaledGridWidth) / 2;
	int offsetY = (finalHeight - scaledGridHeight) / 2;

	cv::Mat finalImage(finalHeight, finalWidth, CV_8UC3, cv::Scalar(0, 0, 0));


	for (int i = 0; i < rows; i++) {
		for (int j = 0; j < cols; j++) {
			int x = static_cast<int>(j * baseCellPixelSize * scaleFactor) + offsetX;
			int y = static_cast<int>(i * baseCellPixelSize * scaleFactor) + offsetY;
			int size = static_cast<int>(baseCellPixelSize * scaleFactor);

			if (i == currentRowIdx && j == currentColIdx) {
				cv::rectangle(finalImage, cv::Rect(x - (size * 0.25), y - (size * 0.25), size * 1.5, size * 1.5), cv::Scalar(0, 255, 0), cv::FILLED);
			}
			else if (i == targetRowIdx && j == targetColIdx)
			{
				cv::rectangle(finalImage, cv::Rect(x - (size * 0.25), y - (size * 0.25), size * 1.5, size * 1.5), cv::Scalar(0, 0, 255), cv::FILLED);
			}
			else if (array[i][j] == static_cast<int>(Entities::Obstacle)) {
				cv::rectangle(finalImage, cv::Rect(x, y, size, size), cv::Scalar(255, 255, 255), cv::FILLED);
			}
			else if (array[i][j] == static_cast<int>(Entities::Plant)) {
				cv::rectangle(finalImage, cv::Rect(x, y, size, size), cv::Scalar(0, 128, 0), cv::FILLED);
			}
			else if (array[i][j] == static_cast<int>(Entities::currentLocation)) {
				cv::rectangle(finalImage, cv::Rect(x, y, size, size), cv::Scalar(0, 255, 255), cv::FILLED);
			}
			else if (i == 0 || j == 0 || j == (cols - 1) || i == (rows - 1))
			{
				cv::rectangle(finalImage, cv::Rect(x, y, size, size), cv::Scalar(255, 255, 255), cv::FILLED);
			}
		}
	}

	return finalImage;
}
void Map::markRecentCell(int r, int c)
{
	// bounds-safe guard (avoid crashes if called before arrays initialized)
	if (r < 0 || r >= rows || c < 0 || c >= cols) return;

	// Avoid duplicate consecutive entries (stay idempotent if robot vibrates in same cell)
	if (!recentCells.empty()) {
		auto last = recentCells.back();
		if (last.first == r && last.second == c) return;
	}

	recentCells.emplace_back(r, c);
	if (tempVisited) tempVisited[r][c] = 1;

	if (recentCells.size() > recentLimit) {
		auto old = recentCells.front();
		recentCells.pop_front();
		if (tempVisited && old.first >= 0 && old.first < rows && old.second >= 0 && old.second < cols)
			tempVisited[old.first][old.second] = 0;
	}
}


bool Map::isImmediateBacktrack(int r, int c) const
{
	// Immediate backtrack = stepping into the cell visited *before* the last one.
	// If we have fewer than 2 entries there is no "previous" cell to block.
	if (recentCells.size() < 2) return false;
	auto prev = recentCells[recentCells.size() - 2];
	return (prev.first == r && prev.second == c);
}


void Map::clearRecentVisits()
{
	recentCells.clear();
	for (int i = 0; i < rows; ++i)
		for (int j = 0; j < cols; ++j)
			tempVisited[i][j] = 0;
}
void Map::setRobotSizeCm(int widthCm, int heightCm)
{
	robotWidthCm = widthCm;
	robotHeightCm = heightCm;

	int maxDim = std::max(widthCm, heightCm);
	robotRadiusCells = (maxDim + precision - 1) / (2 * precision);

	inflateObstaclesForRobotSize();
}
void Map::inflateObstaclesForRobotSize()
{
	if (robotRadiusCells <= 0) return;

	// Snapshot original map
	int** original = allocateArray(rows, cols);
	for (int r = 0; r < rows; ++r)
		for (int c = 0; c < cols; ++c)
			original[r][c] = array[r][c];

	// Inflate from original obstacles/plants only
	for (int r = 0; r < rows; ++r)
	{
		for (int c = 0; c < cols; ++c)
		{
			int v = original[r][c];
			if (v == static_cast<int>(Entities::Obstacle) ||
				v == static_cast<int>(Entities::Plant))
			{
				for (int dr = -robotRadiusCells; dr <= robotRadiusCells; ++dr)
				{
					for (int dc = -robotRadiusCells; dc <= robotRadiusCells; ++dc)
					{
						int rr = r + dr;
						int cc = c + dc;
						if (rr < 0 || cc < 0 || rr >= rows || cc >= cols) continue;

						if (array[rr][cc] == static_cast<int>(Entities::freeDistance))
							array[rr][cc] = static_cast<int>(Entities::Obstacle);

					}
				}
			}
		}
	}

	for (int i = 0; i < rows; ++i) delete[] original[i];
	delete[] original;
}

