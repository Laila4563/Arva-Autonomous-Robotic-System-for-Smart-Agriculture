#include "MapAlgorithm.h"
#include <thread>
#include <chrono>

int main()
{
  // Initialize the map
  Map map;

  // Optional: attach event handlers for debugging/logging
  map.setOnUpdate([]()
                  { std::cout << "[INFO] Map updated.\n"; });

  map.setOnContinous([](int step)
                    { std::cout << "[INFO] Continuous movement step = " << step << "\n"; });

  map.setOnChange([](int step, float angle)
                  { std::cout << "[INFO] Direction changed by " << angle << " degrees.\n"; });

  // Simulate a simple path
  std::cout << "[INFO] Simulating robot path...\n";
  map.update(10, 0);   // Move right 10 cm
  map.update(5, 90);   // Turn up and move 5 cm
  map.update(10, -90); // Turn right again and move 10 cm

  // Visualize the map
  map.visualizeMap("Robot Mapping Visualization");

  // Test adaptive size: robot moves outside initial bounds
  map.update(20, 0); // Move far right to trigger ensureFit()
  map.visualizeMap("Robot Mapping Visualization");

  // Test BFS pathfinding
  int targetRow = 10, targetCol = 10;
  std::cout << "[INFO] Generating BFS path to (" << targetRow << ", " << targetCol << ")...\n";
  auto path = map.findPathToTarget(targetRow, targetCol);

  if (path.empty())
    std::cout << "[WARN] No path found.\n";
  else
    std::cout << "[INFO] Path length = " << path.size() << "\n";

  // Follow the BFS path visually
  for (auto dir : path)
  {
    map.apply(dir);
    map.visualizeMap("Robot Mapping Visualization");
    std::this_thread::sleep_for(std::chrono::milliseconds(200));
  }

  std::cout << "[DONE] Mapping complete.\n";
  cv::waitKey(0);
  return 0;
}