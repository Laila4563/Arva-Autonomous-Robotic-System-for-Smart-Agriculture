#pragma once
#include <iostream>
#include <wiringPi.h>
#include <thread>
#include <atomic>
#include <chrono>
#include <shared_mutex>
#include <condition_variable>
#include <vector>
#include <mutex>
#include <algorithm>
#include "../Config/Config.h" 

#define scaler 1024

class Motor {
public:
    Motor(int forwardPin, int backwardPin, int speedPin);
    Motor(const Motor& other) noexcept;
    Motor(Motor&& other) noexcept;
    Motor& operator=(const Motor& other) noexcept;
    Motor& operator=(Motor&& other) noexcept;

    void moveForward();
    void moveBackward();
    void stop();
    void setSpeed(int percentage);
    ~Motor();

private:
    int forwardPin_{ -1 };
    int backwardPin_{ -1 };
    int speedPin_{ -1 };
    int speed_{ 0 };

    static inline int percentageToPwm(int percentage) {
        if (percentage < 0) percentage = 0;
        if (percentage > 100) percentage = 100;
        return (percentage * scaler) / 100;
    }

    void claimPins();
    void releasePins();
};