#ifndef ULTRASONIC_SENSOR_H
#define ULTRASONIC_SENSOR_H

#include "gpio.h"
#include <iostream>
#include <ctime>
#include <chrono>
#include <thread>
#include <time.h>

class UltrasonicSensor {
public:

    UltrasonicSensor(int triggerPin, int echoPin);

    float getDistance();

    ~UltrasonicSensor();

private:
    int triggerPin_;
    int echoPin_;

    static long long nowMicros();
};

#endif