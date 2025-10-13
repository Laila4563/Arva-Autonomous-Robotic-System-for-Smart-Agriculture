#include "MapAlgorithm.h"

int **Map::allocateArray(int newRows, int newCols)
{
    int **newArray = new int *[newRows];
    for (int i = 0; i < newRows; ++i)
        newArray[i] = new int[newCols]();
    return newArray;
}

char **Map::allocateDirArray(int newRows, int newCols)
{
    char **newDirMap = new char *[newRows];
    for (int i = 0; i < newRows; ++i)
    {
        newDirMap[i] = new char[newCols];
        std::memset(newDirMap[i], ' ', newCols);
    }
    return newDirMap;
}

void Map::ensureFit(int newRow, int newCol)
{
    int padTop = 0, padBottom = 0, padLeft = 0, padRight = 0;

    if (newRow < 0)
        padTop = (prealloc_cm > 0) ? std::max(prealloc_cm / precision, -newRow) : -newRow;
    if (newRow >= rows)
        padBottom = (prealloc_cm > 0) ? std::max(prealloc_cm / precision, newRow - rows + 1) : newRow - rows + 1;
    if (newCol < 0)
        padLeft = (prealloc_cm > 0) ? std::max(prealloc_cm / precision, -newCol) : -newCol;
    if (newCol >= cols)
        padRight = (prealloc_cm > 0) ? std::max(prealloc_cm / precision, newCol - cols + 1) : newCol - cols + 1;

    if (padTop == 0 && padBottom == 0 && padLeft == 0 && padRight == 0)
        return;

    int newRows = rows + padTop + padBottom;
    int newCols = cols + padLeft + padRight;
    int **newArray = allocateArray(newRows, newCols);
    char **newDirMap = allocateDirArray(newRows, newCols);

    for (int i = 0; i < rows; ++i)
    {
        std::memcpy(newArray[i + padTop] + padLeft, array[i], cols * sizeof(int));
        std::memcpy(newDirMap[i + padTop] + padLeft, dirMap[i], cols * sizeof(char));
    }

    for (int i = 0; i < rows; ++i)
    {
        delete[] array[i];
        delete[] dirMap[i];
    }
    delete[] array;
    delete[] dirMap;

    array = newArray;
    dirMap = newDirMap;

    originRow += padTop;
    originCol += padLeft;
    currentY += padTop;
    currentX += padLeft;
    rows = newRows;
    cols = newCols;
}

void Map::internalUpdate(float cm, float angle)
{
    float angleRad = angle * M_PI / 180.0f;
    float dx = std::cos(angleRad);
    float dy = -std::sin(angleRad);

    char directionChar = (std::abs(dx) > std::abs(dy)) ? 'H' : 'V';

    int subdivisions = std::max(2, static_cast<int>(std::ceil(cm / (precision / 2.0f))));
    float subDistance_cm = cm / subdivisions;
    float cellStep = subDistance_cm / precision;

    for (int i = 0; i < subdivisions; ++i)
    {
        currentX += dx * cellStep;
        currentY += dy * cellStep;
        int mapX = std::round(currentX);
        int mapY = std::round(currentY);

        ensureFit(mapY, mapX);

        mapX = std::round(currentX);
        mapY = std::round(currentY);

        // array[mapY][mapX] = 1;
        // dirMap[mapY][mapX] = directionChar;

        markRobotArea(mapY, mapX);
    }
}

Map::Map() : rows(1), cols(1), originRow(0), originCol(0), currentX(0), currentY(0)
{
    array = allocateArray(rows, cols);
    dirMap = allocateDirArray(rows, cols);
    array[originRow][originCol] = 0;
    dirMap[originRow][originCol] = 'S';
}

Map::~Map()
{
    for (int i = 0; i < rows; ++i)
    {
        delete[] array[i];
        delete[] dirMap[i];
    }
    delete[] array;
    delete[] dirMap;
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

void Map::update(float cm)
{
    internalUpdate(cm, lastAngle);
    if (onUpdate)
    {
        onUpdate();
    }
}

void Map::update(float cm, float angle)
{
    float newEffectiveAngle = lastAngle + angle;
    internalUpdate(cm, newEffectiveAngle);
    lastAngle = newEffectiveAngle;
    if (onUpdate)
    {
        onUpdate();
    }
}

void Map::update(float cm, float angle, int estimated_prealloc_cm)
{
    prealloc_cm = estimated_prealloc_cm;
    float newEffectiveAngle = lastAngle + angle;
    internalUpdate(cm, newEffectiveAngle);
    lastAngle = newEffectiveAngle;
    if (onUpdate)
    {
        onUpdate();
    }
}

void Map::updateAngle(float angle)
{
    float newEffectiveAngle = lastAngle + angle;
    lastAngle = newEffectiveAngle;
    if (onUpdate)
    {
        onUpdate();
    }
}

void Map::print() const
{
    for (int i = 0; i < rows; ++i)
    {
        for (int j = 0; j < cols; ++j)
        {
            if (i == currentY && j == currentX)
                std::cout << "2";
            else if (array[i][j] == 1)
                std::cout << "1";
            else
                std::cout << " ";
        }
        std::cout << '\n';
    }
}

void Map::printValues() const
{
    for (int i = 0; i < rows; ++i)
    {
        for (int j = 0; j < cols; ++j)
            std::cout << array[i][j] << " ";
        std::cout << '\n';
    }
}

float Map::snapToNearestRightAngle(float angle)
{
    angle = fmod(angle, 360.0f);
    if (angle < 0)
        angle += 360.0f;

    float options[] = {0.0f, 90.0f, 180.0f, 270.0f};

    float closest = options[0];
    float minDiff = std::abs(angle - closest);
    for (int i = 1; i < 4; ++i)
    {
        float diff = std::abs(angle - options[i]);
        if (diff < minDiff)
        {
            minDiff = diff;
            closest = options[i];
        }
    }

    return closest;
}

Map::Direction Map::nextMove() const
{

    int startRow = static_cast<int>(std::round(currentY));
    int startCol = static_cast<int>(std::round(currentX));

    auto inBounds = [this](int r, int c) -> bool
    {
        return (r >= 0 && r < rows && c >= 0 && c < cols);
    };

    typedef std::pair<int, int> Cell;
    std::vector<std::vector<bool>> external(rows, std::vector<bool>(cols, false));
    std::queue<Cell> extQueue;

    for (int r = 0; r < rows; ++r)
    {
        for (int c : {0, cols - 1})
        {
            if (inBounds(r, c) && array[r][c] == 0 && !external[r][c])
            {
                external[r][c] = true;
                extQueue.push({r, c});
            }
        }
    }
    for (int c = 0; c < cols; ++c)
    {
        for (int r : {0, rows - 1})
        {
            if (inBounds(r, c) && array[r][c] == 0 && !external[r][c])
            {
                external[r][c] = true;
                extQueue.push({r, c});
            }
        }
    }

    const int ext_dr[4] = {-1, 1, 0, 0};
    const int ext_dc[4] = {0, 0, -1, 1};
    while (!extQueue.empty())
    {
        Cell cur = extQueue.front();
        extQueue.pop();
        for (int i = 0; i < 4; ++i)
        {
            int nr = cur.first + ext_dr[i];
            int nc = cur.second + ext_dc[i];
            if (inBounds(nr, nc) && !external[nr][nc] && array[nr][nc] == 0)
            {
                external[nr][nc] = true;
                extQueue.push({nr, nc});
            }
        }
    }

    struct Step
    {
        int dr, dc;
        Direction dir;
    };
    const Step steps[] = {
        {-1, 0, Direction::Top},
        {1, 0, Direction::Bottom},
        {0, -1, Direction::Left},
        {0, 1, Direction::Right}};
    for (const auto &step : steps)
    {
        int nr = startRow + step.dr;
        int nc = startCol + step.dc;
        if (inBounds(nr, nc) && array[nr][nc] == 0 && !external[nr][nc])
        {
            return step.dir;
        }
    }

    typedef std::pair<int, int> Cell;
    std::vector<std::vector<bool>> bfsVisited(rows, std::vector<bool>(cols, false));
    std::vector<std::vector<Cell>> parent(rows, std::vector<Cell>(cols, {-1, -1}));

    std::queue<Cell> q;
    q.push({startRow, startCol});
    bfsVisited[startRow][startCol] = true;

    Cell target = {-1, -1};
    bool found = false;

    while (!q.empty() && !found)
    {
        Cell cur = q.front();
        q.pop();

        if (array[cur.first][cur.second] == 0 &&
            !(cur.first == startRow && cur.second == startCol) &&
            !external[cur.first][cur.second])
        {
            target = cur;
            found = true;
            break;
        }

        for (const auto &step : steps)
        {
            int nr = cur.first + step.dr;
            int nc = cur.second + step.dc;
            if (inBounds(nr, nc) && !bfsVisited[nr][nc] && !external[nr][nc])
            {
                bfsVisited[nr][nc] = true;
                parent[nr][nc] = cur;
                q.push({nr, nc});
            }
        }
    }

    if (!found)
        return Direction::Done;

    std::vector<Cell> path;
    for (Cell cur = target; cur.first != -1; cur = parent[cur.first][cur.second])
    {
        path.push_back(cur);
        if (cur.first == startRow && cur.second == startCol)
            break;
    }
    std::reverse(path.begin(), path.end());

    if (path.size() < 2)
        return Direction::Done;

    Cell nextCell = path[1];
    int dRow = nextCell.first - startRow;
    int dCol = nextCell.second - startCol;

    if (dRow == -1 && dCol == 0)
        return Direction::Top;
    if (dRow == 1 && dCol == 0)
        return Direction::Bottom;
    if (dRow == 0 && dCol == -1)
        return Direction::Left;
    if (dRow == 0 && dCol == 1)
        return Direction::Right;

    int candARow = startRow + dRow;
    int candACol = startCol;
    int candBRow = startRow;
    int candBCol = startCol + dCol;

    auto manhattanDist = [&](int r, int c)
    {
        return std::abs(r - target.first) + std::abs(c - target.second);
    };
    int distA = manhattanDist(candARow, candACol);
    int distB = manhattanDist(candBRow, candBCol);

    if (distA <= distB)
    {
        return (dRow < 0) ? Direction::Top : Direction::Bottom;
    }
    else
    {
        return (dCol < 0) ? Direction::Left : Direction::Right;
    }
}

float Map::normalizeAngle(float angle)
{
    while (angle < 0)
        angle += 360;
    while (angle >= 360)
        angle -= 360;
    return angle;
}

float Map::calculateRelativeAngle(float prevAngle, float currentAngle)
{
    float angleDiff = currentAngle - prevAngle;
    angleDiff = normalizeAngle(angleDiff);

    if (angleDiff > 180)
    {
        angleDiff -= 360;
    }
    return angleDiff;
}

void Map::apply(Direction movement)
{
    float prevAngle = snapToNearestRightAngle(lastAngle);
    float currentAngle = 0;
    switch (movement)
    {
    case Direction::Top:
    {
        currentAngle = 90;
    }
    break;
    case Direction::Left:
    {
        currentAngle = 180;
    }
    break;
    case Direction::Bottom:
    {
        currentAngle = 270;
    }
    break;
    case Direction::Right:
    {
        currentAngle = 0;
    }
    break;
    default:
        return;
    }
    float relativeAngle = calculateRelativeAngle(prevAngle, currentAngle);
    if (prevAngle == currentAngle)
    {
        if (onContinousHandler)
        {
            onContinousHandler(precision);
        }
        update(precision);
    }
    else
    {
        if (onChangeHandler)
        {
            onChangeHandler(precision, relativeAngle);
        }
        update(precision, relativeAngle);
    }
}

json Map::mapAsJson()
{
    json jsonObject;

    jsonObject["array"] = json::array();
    for (int i = 0; i < rows; ++i)
    {
        json row = json::array();
        for (int jIndex = 0; jIndex < cols; ++jIndex)
        {
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

// new functions
//  ============================================================================
//  Function: markRobotArea
//  Purpose : Marks a rectangular area around the robot's current position
//            on the occupancy grid instead of a single point. This creates
//            an adaptive robot footprint (e.g., 2x2 cells) so the robot
//            occupies an area rather than one cell.
//
//  Params  : centerY, centerX - robot's current center coordinates in grid cells
//  ============================================================================
void Map::markRobotArea(int centerY, int centerX)
{
    // Calculate half dimensions of the robot footprint in cells
    int halfW = ROBOT_WIDTH_CELLS / 2;
    int halfH = ROBOT_HEIGHT_CELLS / 2;

    // Define the rectangular area (top-left and bottom-right corners)
    int minRow = centerY - halfH;
    int maxRow = centerY + halfH;
    int minCol = centerX - halfW;
    int maxCol = centerX + halfW;

    // Ensure that the map is large enough to include this area
    ensureFit(minRow, minCol);
    ensureFit(maxRow, maxCol);

    // Clamp rectangle boundaries within valid map dimensions
    minRow = std::max(0, minRow);
    minCol = std::max(0, minCol);
    maxRow = std::min(rows - 1, maxRow);
    maxCol = std::min(cols - 1, maxCol);

    // Mark all cells in the robot’s footprint area
    for (int r = minRow; r <= maxRow; ++r)
    {
        for (int c = minCol; c <= maxCol; ++c)
        {
            if (r >= 0 && r < rows && c >= 0 && c < cols)
            {
                array[r][c] = 1;    // mark as occupied / visited
                dirMap[r][c] = 'R'; // mark as robot presence
            }
        }
    }
}

// ============================================================================
// Function: findPathToTarget
// Purpose : Uses Breadth-First Search (BFS) to find the shortest path
//           from the robot’s current grid location to a target location.
//           Returns a sequence of movement directions to reach the goal.
//
// Params  : targetRow, targetCol - target cell coordinates in the map
// Returns : vector<Direction> representing the step-by-step directions
// ============================================================================
std::vector<Map::Direction> Map::findPathToTarget(int targetRow, int targetCol)
{
    typedef std::pair<int, int> Cell; // shorthand for a grid cell (row, col)

    // Lambda to check if a cell is within the map boundaries
    auto inBounds = [this](int r, int c)
    {
        return r >= 0 && r < rows && c >= 0 && c < cols;
    };

    // BFS data structures
    std::queue<Cell> q; // queue for BFS exploration
    std::vector<std::vector<bool>> visited(rows, std::vector<bool>(cols, false));
    std::vector<std::vector<Cell>> parent(rows, std::vector<Cell>(cols, {-1, -1}));

    // Start from the robot’s current (rounded) position
    int startR = static_cast<int>(std::round(currentY));
    int startC = static_cast<int>(std::round(currentX));

    q.push({startR, startC});
    visited[startR][startC] = true;

    // Movement offsets for 4 possible directions (up, down, left, right)
    const int dr[4] = {-1, 1, 0, 0};
    const int dc[4] = {0, 0, -1, 1};
    const Direction dirs[4] = {Direction::Top, Direction::Bottom, Direction::Left, Direction::Right};

    bool found = false;

    // Perform BFS traversal until target is found or queue is empty
    while (!q.empty() && !found)
    {
        auto [r, c] = q.front();
        q.pop();

        // Check if we've reached the target cell
        if (r == targetRow && c == targetCol)
        {
            found = true;
            break;
        }

        // Explore 4 neighboring cells
        for (int i = 0; i < 4; ++i)
        {
            int nr = r + dr[i]; // new row
            int nc = c + dc[i]; // new column

            // Only enqueue valid, unvisited, and non-blocked cells
            if (inBounds(nr, nc) && !visited[nr][nc] && array[nr][nc] == 0)
            {
                visited[nr][nc] = true;
                parent[nr][nc] = {r, c}; // remember where we came from
                q.push({nr, nc});
            }
        }
    }

    std::vector<Direction> path;

    // If target not found, return empty path
    if (!found)
        return path;

    // Reconstruct path by walking backwards from target → start
    Cell cur = {targetRow, targetCol};
    while (!(cur.first == startR && cur.second == startC))
    {
        Cell prev = parent[cur.first][cur.second];
        if (prev.first == -1)
            break; // safety check (no parent)

        // Determine direction moved between previous and current cell
        int dr_ = cur.first - prev.first;
        int dc_ = cur.second - prev.second;

        if (dr_ == -1 && dc_ == 0)
            path.push_back(Direction::Top);
        else if (dr_ == 1 && dc_ == 0)
            path.push_back(Direction::Bottom);
        else if (dr_ == 0 && dc_ == -1)
            path.push_back(Direction::Left);
        else if (dr_ == 0 && dc_ == 1)
            path.push_back(Direction::Right);

        cur = prev; // step back to continue reconstructing
    }

    // Reverse the path to go from start → target
    std::reverse(path.begin(), path.end());
    return path;
}

// ============================================================================
// Function: visualizeMap
// Purpose : Generates a visual representation of the occupancy grid
//           using OpenCV. Displays visited cells as white and the
//           robot’s current location as green. Can be used to animate
//           exploration or pathfinding in real time.
//
// Params  : windowName - title for the OpenCV display window
// ============================================================================
void Map::visualizeMap(const std::string &windowName) const
{
    int cellSize = 10; // number of pixels representing one map cell

    // Create a blank black image large enough to represent the grid
    cv::Mat img(rows * cellSize, cols * cellSize, CV_8UC3, cv::Scalar(0, 0, 0));

    // Draw visited/occupied cells as white rectanglesz
    for (int r = 0; r < rows; ++r)
    {
        for (int c = 0; c < cols; ++c)
        {
            if (array[r][c] == 1)
            {
                cv::Rect cellRect(c * cellSize, r * cellSize, cellSize, cellSize);
                cv::rectangle(img, cellRect, cv::Scalar(255, 255, 255), cv::FILLED);
            }
        }
    }

    // Draw robot's current location as a green square
    int curR = static_cast<int>(std::round(currentY));
    int curC = static_cast<int>(std::round(currentX));
    cv::rectangle(
        img,
        cv::Rect(curC * cellSize, curR * cellSize, cellSize, cellSize),
        cv::Scalar(0, 255, 0), // green color
        cv::FILLED);

    // Display the image in an OpenCV window
    cv::imshow(windowName, img);
    cv::waitKey(1); // short delay to allow refresh; use >0 for pause
}
