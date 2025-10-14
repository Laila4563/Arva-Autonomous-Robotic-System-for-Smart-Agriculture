#include <iostream>
#include "MapAlgorithm.h"
#include <thread>
int main()
{
  Map map(6,6);
  map.update(4, -90);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4, 45);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4, 45);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4, 90);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4, 45);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4, 45);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4, 90);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.update(4);
  map.setTargetLocation(10, 10);
  cv::imshow("map", map.generatePicture());
  cv::waitKey(0);

  while (true)
  {
    Map::Direction movement = map.nextMove();
    if (movement == Map::Direction::Done)
    {
      std::cout << "Done.\n";
      break;
    }
    map.apply(movement);
    cv::imshow("map", map.generatePicture());
    cv::waitKey(0);
    std::this_thread::sleep_for(std::chrono::milliseconds(100));
  }
}