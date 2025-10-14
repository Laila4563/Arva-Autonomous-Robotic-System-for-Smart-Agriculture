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

        // ensureFit(mapY, mapX);
        ensureFit(mapY + marginCells, mapX + marginCells);
        ensureFit(mapY - marginCells, mapX - marginCells);

        mapX = std::round(currentX);
        mapY = std::round(currentY);

        // dirMap[mapY][mapX] = directionChar;
        for (int r = mapY - marginCells; r <= mapY + marginCells; ++r)
        {
            for (int c = mapX - marginCells; c <= mapX + marginCells; ++c)
            {
                // Safety check, although ensureFit should cover this now
                if (r >= 0 && r < rows && c >= 0 && c < cols)
                {
                    dirMap[r][c] = directionChar;
                }
            }
        }
    }
}

Map::Map(float lengthCM, float widthCM) : rows(1), cols(1), originRow(0), originCol(0), currentX(0), currentY(0)
{
    float maxDimCm = std::max(lengthCM, widthCM);

    marginCells = static_cast<int>(std::ceil((maxDimCm / 2.0f) / precision));

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

void Map::setTargetLocation(float x, float y)
{
    targetX = x;
    targetY = y;
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

Map::Direction Map::nextMove()
{
    if (targetY == -1 || targetX == -1)
    {
        return Direction::Done;
    }

    int curCol = static_cast<int>(std::round(currentX));
    int curRow = static_cast<int>(std::round(currentY));
    int tgtCol = static_cast<int>(std::round(targetX));
    int tgtRow = static_cast<int>(std::round(targetY));

    const float doneThreshold = 0.5f;
    if (std::hypot(targetX - currentX, targetY - currentY) <= doneThreshold)
    {
        return Direction::Done;
    }

    int dx = tgtCol - curCol;
    int dy = tgtRow - curRow;

    auto isFree = [&](int r, int c) -> bool
    {
        // if (r < 0 || r >= rows || c < 0 || c >= cols)
        // {

        //     return true;
        // }
        // return array[r][c] == 0;

        // 1. Iterate over the robot's bounding box area, defined by marginCells,
        //    centered around the proposed move (r, c).
        for (int rowCheck = r - marginCells; rowCheck <= r + marginCells; ++rowCheck)
        {
            for (int colCheck = c - marginCells; colCheck <= c + marginCells; ++colCheck)
            {
                // 2. Boundary Check: If the robot's margin extends outside the current map area,
                //    it is considered a collision (not free).
                if (rowCheck < 0 || rowCheck >= rows || colCheck < 0 || colCheck >= cols)
                {
                    return false; // Collision with map boundary/wall
                }

                // 3. Obstacle Check: If any cell in the robot's bounding box is an obstacle (1),
                //    the move is not free.
                if (array[rowCheck][colCheck] == 1)
                {
                    return false; // Collision with an obstacle
                }
            }
        }
        return true; // The entire robot area is free
    };

    auto manhattan = [&](int r, int c) -> int
    {
        return std::abs(tgtRow - r) + std::abs(tgtCol - c);
    };

    std::vector<std::pair<Direction, std::pair<int, int>>> candidates;
    bool preferX = (std::abs(dx) >= std::abs(dy));

    auto pushCandidate = [&](Direction dir, int r, int c)
    {
        candidates.emplace_back(dir, std::make_pair(r, c));
    };

    if (preferX)
    {
        if (dx > 0)
            pushCandidate(Direction::Right, curRow, curCol + 1);
        else if (dx < 0)
            pushCandidate(Direction::Left, curRow, curCol - 1);

        if (dy > 0)
            pushCandidate(Direction::Bottom, curRow + 1, curCol);
        else if (dy < 0)
            pushCandidate(Direction::Top, curRow - 1, curCol);
    }
    else
    {
        if (dy > 0)
            pushCandidate(Direction::Bottom, curRow + 1, curCol);
        else if (dy < 0)
            pushCandidate(Direction::Top, curRow - 1, curCol);

        if (dx > 0)
            pushCandidate(Direction::Right, curRow, curCol + 1);
        else if (dx < 0)
            pushCandidate(Direction::Left, curRow, curCol - 1);
    }

    pushCandidate(Direction::Top, curRow - 1, curCol);
    pushCandidate(Direction::Bottom, curRow + 1, curCol);
    pushCandidate(Direction::Left, curRow, curCol - 1);
    pushCandidate(Direction::Right, curRow, curCol + 1);

    std::vector<std::pair<Direction, std::pair<int, int>>> uniqueCandidates;
    for (auto &p : candidates)
    {
        bool seen = false;
        for (auto &q : uniqueCandidates)
        {
            if (q.first == p.first)
            {
                seen = true;
                break;
            }
        }
        if (!seen)
            uniqueCandidates.push_back(p);
    }

    int currentDist = manhattan(curRow, curCol);
    for (auto &c : uniqueCandidates)
    {
        int nr = c.second.first;
        int nc = c.second.second;
        if (!isFree(nr, nc))
            continue;
        int newDist = manhattan(nr, nc);
        if (newDist < currentDist)
        {
            return c.first;
        }
    }

    for (auto &c : uniqueCandidates)
    {
        int nr = c.second.first;
        int nc = c.second.second;
        if (isFree(nr, nc))
        {
            return c.first;
        }
    }

    targetX = -1;
    targetY = -1;
    return Direction::Done;
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

cv::Mat Map::generatePicture()
{
    const int minFinalWidth = 1280;
    const int minFinalHeight = 720;
    const int baseCellPixelSize = 10;

    int gridWidth = cols * baseCellPixelSize;
    int gridHeight = rows * baseCellPixelSize;

    int currentColIdx = static_cast<int>(std::round(currentX));
    int currentRowIdx = static_cast<int>(std::round(currentY));
    int targetColIdx = static_cast<int>(std::round(targetX));
    int targetRowIdx = static_cast<int>(std::round(targetY));

    int robotDrawMargin = marginCells;

    cv::Mat gridImage(gridHeight, gridWidth, CV_8UC3, cv::Scalar(0, 0, 0));
    for (int i = 0; i < rows; i++)
    {
        for (int j = 0; j < cols; j++)
        {

            if (i == currentRowIdx && j == currentColIdx)
            {
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
            else if (array[i][j] == 1)
            {
                cv::rectangle(gridImage,
                              cv::Rect(j * baseCellPixelSize, i * baseCellPixelSize, baseCellPixelSize, baseCellPixelSize),
                              cv::Scalar(255, 255, 255),
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

    for (int i = 0; i < rows; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            int x = static_cast<int>(j * baseCellPixelSize * scaleFactor) + offsetX;
            int y = static_cast<int>(i * baseCellPixelSize * scaleFactor) + offsetY;
            int size = static_cast<int>(baseCellPixelSize * scaleFactor);

            // 1. Draw the Robot (Green)
            // Check if the current cell (i, j) is part of the robot's drawn area
            if (i >= currentRowIdx - robotDrawMargin && i <= currentRowIdx + robotDrawMargin &&
                j >= currentColIdx - robotDrawMargin && j <= currentColIdx + robotDrawMargin)
            {
                // Draw the robot's full area in green. This now replaces the single-dot drawing.
                cv::rectangle(finalImage, cv::Rect(x, y, size, size), cv::Scalar(0, 255, 0), cv::FILLED);
            }
            // 2. Draw the Target (Red) - Only if it's NOT covered by the robot
            else if (i == targetRowIdx && j == targetColIdx) 
            {
                // Draw the target center (use a slightly larger shape to make it visible)
                cv::rectangle(finalImage, cv::Rect(x - (size * 0.25), y - (size * 0.25), size * 1.5, size * 1.5), cv::Scalar(0, 0, 255), cv::FILLED);
            }
            // 3. Draw Obstacles/Walls (White)
            else if (array[i][j] == 1)
            {
                cv::rectangle(finalImage, cv::Rect(x, y, size, size), cv::Scalar(255, 255, 255), cv::FILLED);
            }
            // 4. Draw Map Borders (White)
            else if (i == 0 || j == 0 || j == (cols - 1) || i == (rows - 1))
            {
                cv::rectangle(finalImage, cv::Rect(x, y, size, size), cv::Scalar(255, 255, 255), cv::FILLED);
            }
        }
    }

    return finalImage;
}
