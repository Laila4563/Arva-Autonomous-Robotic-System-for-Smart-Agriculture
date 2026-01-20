#include <iostream>
#include <cstdlib>
#include <ctime>
#include <vector>
#include <algorithm>
#include "MapAlgorithim.h"
void buildArenaSurroundCurrent(Map& map, int targetCol, int targetRow,
    int minSize = 40, int wallThickness = 5,
    int corridorWidth = 6, int bufferCells = 1);


int main()
{
    cv::utils::logging::setLogLevel(cv::utils::logging::LOG_LEVEL_SILENT);
    Map map(200, 200); // 200cm x 200cm world

    buildArenaSurroundCurrent(map, 6, 4);
    map.setTargetLocation(18, 34);
    cv::Mat img = map.generatePicture();
    cv::imshow("Map", img);
    cv::waitKey(0);

    int stepCount = 0;
    for (auto move = map.NextMove(); !(move.done || move.unreachable); move = map.NextMove())
    {
        if (move.hasAngle)
            map.turn(move.angle);

        // BREAK DOWN LARGE MOVES INTO SINGLE-CELL MOVES
        int remainingDistance = move.distance;
        int cellSize = 4; // or whatever your precision is

        while (remainingDistance > 0) {
            // Move one cell at a time
            int moveThisStep = std::min(cellSize, remainingDistance);
            map.moved(moveThisStep);
            remainingDistance -= moveThisStep;

            std::cout << "Single Step - Distance: " << moveThisStep
                << ", Angle: " << (move.hasAngle ? move.angle : 0) << std::endl;

            // Update display after each single cell move
            cv::Mat img = map.generatePicture();
            cv::imshow("Map", img);
            cv::waitKey(250);
        }
    }
}

void buildArenaSurroundCurrent(Map& map, int targetCol, int targetRow,
    int minSize, int wallThickness,
    int corridorWidth, int bufferCells)
{
    // snapshot (used only for coordinates/precision; occupancy checks are advisory)
    json snap = map.mapAsJson();
    int rows = snap["rows"].get<int>();
    int cols = snap["cols"].get<int>();
    int precision = snap["precision"].get<int>(); // cm per cell
    float curX = snap["currentX"].get<float>();
    float curY = snap["currentY"].get<float>();
    auto grid = snap["array"];

    int curCol = static_cast<int>(std::round(curX));
    int curRow = static_cast<int>(std::round(curY));

    // bounding box of arena centered on current location
    int half = std::max(1, minSize / 2);
    int left = curCol - half;
    int right = curCol + half;
    int top = curRow - half;
    int bottom = curRow + half;

    // Ensure at least some margin so walls don't overlap robot
    left = std::min(left, curCol - 2);
    right = std::max(right, curCol + 2);
    top = std::min(top, curRow - 2);
    bottom = std::max(bottom, curRow + 2);

    // Corridor: compute approximate column/row corridor region from current -> target
    // We'll open the outer wall and inner ring in the direction from robot to target.
    int dirCol = targetCol - curCol;
    int dirRow = targetRow - curRow;
    // pick dominant direction to make opening
    bool preferHorizontal = (std::abs(dirCol) >= std::abs(dirRow));

    int halfCor = corridorWidth / 2;
    // corridor center line (in grid coords) starts at targetCol/targetRow projection onto arena edge
    // We'll compute corridor cols/rows relative to target position inside arena bounds later.

    // helper checks
    auto isTargetCell = [&](int r, int c)->bool {
        return (c == targetCol && r == targetRow);
        };
    auto isRobotCell = [&](int r, int c)->bool {
        return (c == curCol && r == curRow);
        };
    auto isInSnapshotBounds = [&](int r, int c)->bool {
        return (r >= 0 && r < rows && c >= 0 && c < cols);
        };
    auto isCloseToTarget = [&](int r, int c)->bool {
        return (std::abs(r - targetRow) <= bufferCells && std::abs(c - targetCol) <= bufferCells);
        };
    auto hasObstacleSnapshot = [&](int r, int c)->bool {
        if (!isInSnapshotBounds(r, c)) return false;
        int v = grid[r][c].get<int>();
        return (v == static_cast<int>(Map::Entities::Obstacle) || v == static_cast<int>(Map::Entities::Plant));
        };

    // convert a cell (r,c) to a turn/add sequence (in cm) based on current position.
    auto placeCell = [&](int r, int c)->void {
        // guard: never place on robot or target or target-buffer
        if (isRobotCell(r, c)) return;
        if (isTargetCell(r, c)) return;
        if (isCloseToTarget(r, c)) return;

        // avoid overwriting an existing obstacle/plant in snapshot near this cell (advisory)
        if (hasObstacleSnapshot(r, c)) return;

        // vector from current position in cells
        float dxCells = static_cast<float>(c) - curX; // forward along +X
        float dyCells = static_cast<float>(r) - curY; // lateral (down positive)

        if (std::abs(dxCells) < 1e-6f && std::abs(dyCells) < 1e-6f) return; // same cell

        // convert to cm
        float forwardCm = dxCells * static_cast<float>(precision);
        float lateralCm = dyCells * static_cast<float>(precision);

        double angleRad = std::atan2(-lateralCm, forwardCm); // your angle convention
        double angleDeg = angleRad * 180.0 / M_PI;

        int distCm = static_cast<int>(std::round(std::hypot(forwardCm, lateralCm)));
        if (distCm < precision) distCm = precision; // ensure at least one cell

        // commit: rotate, add, rotate back
        map.turn(angleDeg);
        map.add(Map::Entities::Obstacle, distCm);
        map.turn(-angleDeg);
        };

    // 1) Inner ring immediately around the robot (surround)
    // Leave an opening directed toward the target (so robot is not trapped), width = corridorWidth
    if (preferHorizontal) {
        // opening to left or right?
        bool openRight = (dirCol > 0);
        int ringCols[4] = { curCol - 1, curCol + 1, curCol - 2, curCol + 2 }; // candidate ring offsets
        // build ring of radius 1..ringRadius
        int ringRadius = 2;
        for (int dr = -ringRadius; dr <= ringRadius; ++dr) {
            for (int dc = -ringRadius; dc <= ringRadius; ++dc) {
                int r = curRow + dr;
                int c = curCol + dc;
                // skip inner cell
                if (isRobotCell(r, c)) continue;
                // decide whether this cell is inside the opening corridor toward target
                if (openRight && c > curCol && std::abs(r - curRow) <= halfCor) continue;
                if (!openRight && c < curCol && std::abs(r - curRow) <= halfCor) continue;
                // place
                placeCell(r, c);
            }
        }
    }
    else {
        // opening up or down?
        bool openDown = (dirRow > 0);
        int ringRadius = 2;
        for (int dr = -ringRadius; dr <= ringRadius; ++dr) {
            for (int dc = -ringRadius; dc <= ringRadius; ++dc) {
                int r = curRow + dr;
                int c = curCol + dc;
                if (isRobotCell(r, c)) continue;
                if (openDown && r > curRow && std::abs(c - curCol) <= halfCor) continue;
                if (!openDown && r < curRow && std::abs(c - curCol) <= halfCor) continue;
                placeCell(r, c);
            }
        }
    }

    // 2) Outer thick perimeter wall (rectangle) around the bounding box [top..bottom] x [left..right]
    // We'll leave one opening (corridor) on the perimeter in direction of the target.
    // Compute corridor location on the perimeter:
    int corStartR = 0, corEndR = 0, corStartC = 0, corEndC = 0;
    if (preferHorizontal) {
        // corridor on left or right edge
        int edgeCol = (dirCol >= 0) ? right : left;
        // corridor vertical span centered at projection of target row
        int centerR = std::max(top + 1, std::min(targetRow, bottom - 1));
        corStartR = std::max(top, centerR - halfCor);
        corEndR = std::min(bottom, centerR + halfCor);
        corStartC = corEndC = edgeCol;
    }
    else {
        // corridor on top or bottom edge
        int edgeRow = (dirRow >= 0) ? bottom : top;
        int centerC = std::max(left + 1, std::min(targetCol, right - 1));
        corStartC = std::max(left, centerC - halfCor);
        corEndC = std::min(right, centerC + halfCor);
        corStartR = corEndR = edgeRow;
    }

    // draw walls of thickness 'wallThickness' by filling perimeter stripes, leaving corridor open
    for (int t = 0; t < wallThickness; ++t) {
        // top stripe
        int rtop = top + t;
        for (int c = left; c <= right; ++c) {
            // skip corridor cells
            if (rtop >= corStartR && rtop <= corEndR && corStartC == corEndC && c == corStartC) continue;
            if (rtop == corStartR && corStartR == corEndR && c >= corStartC && c <= corEndC) {
                // skip if this top stripe intersects horizontal corridor
                continue;
            }
            placeCell(rtop, c);
        }
        // bottom stripe
        int rbot = bottom - t;
        for (int c = left; c <= right; ++c) {
            if (rbot >= corStartR && rbot <= corEndR && corStartC == corEndC && c == corStartC) continue;
            if (rbot == corStartR && corStartR == corEndR && c >= corStartC && c <= corEndC) continue;
            placeCell(rbot, c);
        }
        // left stripe
        int cleft = left + t;
        for (int r = top; r <= bottom; ++r) {
            if (cleft >= corStartC && cleft <= corEndC && corStartR == corEndR && r == corStartR) continue;
            if (cleft == corStartC && corStartC == corEndC && r >= corStartR && r <= corEndR) continue;
            placeCell(r, cleft);
        }
        // right stripe
        int cright = right - t;
        for (int r = top; r <= bottom; ++r) {
            if (cright >= corStartC && cright <= corEndC && corStartR == corEndR && r == corStartR) continue;
            if (cright == corStartC && corStartC == corEndC && r >= corStartR && r <= corEndR) continue;
            placeCell(r, cright);
        }
    }

    // 3) Sparse interior scatter (but ensure corridor path from perimeter to robot remains free)
    // We'll create a straight corridor (cells) from the perimeter opening to the robot and keep it clear,
    // then scatter obstacles elsewhere in the interior.
    // Determine corridor center line from opening towards robot:
    std::vector<std::pair<int, int>> corridorCells;
    if (preferHorizontal) {
        // opening column is corStartC (==corEndC)
        int openCol = corStartC;
        // floor-step from openCol towards curCol along columns, at row = clamp(targetRow..)
        int rowCenter = std::max(top + 1, std::min(targetRow, bottom - 1));        int step = (curCol >= openCol) ? 1 : -1;
        for (int c = openCol; c != curCol + step; c += step) {
            for (int rr = rowCenter - halfCor; rr <= rowCenter + halfCor; ++rr) {
                if (rr < top || rr > bottom) continue;
                // mark corridor cells (do NOT place obstacles here)
                corridorCells.emplace_back(rr, c);
            }
        }
    }
    else {
        int openRow = corStartR;
        int colCenter = std::max(left + 1, std::min(targetCol, right - 1));        int step = (curRow >= openRow) ? 1 : -1;
        for (int r = openRow; r != curRow + step; r += step) {
            for (int cc = colCenter - halfCor; cc <= colCenter + halfCor; ++cc) {
                if (cc < left || cc > right) continue;
                corridorCells.emplace_back(r, cc);
            }
        }
    }

    auto isInCorridor = [&](int r, int c)->bool {
        for (auto& p : corridorCells) if (p.first == r && p.second == c) return true;
        return false;
        };

    // scatter interior obstacles, skipping corridor and target/robot
    for (int r = top + 1; r <= bottom - 1; ++r) {
        for (int c = left + 1; c <= right - 1; ++c) {
            if (isRobotCell(r, c) || isTargetCell(r, c) || isCloseToTarget(r, c)) continue;
            // Instead of just skipping corridor cells, mark them as PathCell
            if (isInCorridor(r, c)) {
                // Mark as path cell instead of obstacle
                // You'll need a new function like map.setCellAsPath(r, c)
                continue;
            }
            // random chance to place (roughly 30%)
            if ((std::rand() % 100) < 30) placeCell(r, c);
        }
    }

    // Done: arena built. You can visualize with map.generatePicture() and check corridor.
}