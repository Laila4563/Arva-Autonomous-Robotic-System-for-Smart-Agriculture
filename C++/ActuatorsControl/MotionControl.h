#ifndef MOTION_CONTROL_H
#define MOTION_CONTROL_H

#include <functional>
#include "../Actuators/Motor.h"
#include "../NavigationSensors/MPU6050.h"  
#include <iostream>
#include <wiringPi.h>
#include <thread>
#include <chrono>
class MotionControl {
public:
    MotionControl(Motor& left, Motor& right, MPU6050& sensor);
    void turn(float angle);
    void moveForward();
    void moveBackward();
    void stop();
    void setSpeed(float percentage);
    void setOnFinish(std::function<void(float)> callback);

private:
    Motor &leftMotor;
    Motor &rightMotor;
    MPU6050& sensor;
    std::function<void(float)> onFinish;
};
#endif 

