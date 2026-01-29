#pragma once

#include <thread>
#include <atomic>
#include <chrono>
#include <mutex>
#include <condition_variable>

#include "../ActuatorsControl/ArmControl.h" 
#include "../Actuators/Pump.h"       

class IrrigationControl {
public:

    IrrigationControl(ArmControl& arm, Pump& pump);
    ~IrrigationControl();


    void spray(int x, int y,
        std::chrono::milliseconds intervalSpray,
        std::chrono::milliseconds intervalPause);


    void stop() noexcept;


    bool isRunning() const noexcept;



private:
    ArmControl& arm_;
    Pump& pump_;

    std::thread worker_;
    mutable std::mutex mtx_;
    std::condition_variable cv_;
    std::atomic<bool> running_{ false };
    std::atomic<bool> requestStop_{ false };

    void workerLoop(int x, int y,
        std::chrono::milliseconds intervalSpray,
        std::chrono::milliseconds intervalPause);
};
