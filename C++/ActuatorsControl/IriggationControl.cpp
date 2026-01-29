#include "IriggationControl.h"
#include <iostream>

IrrigationControl::IrrigationControl(ArmControl& arm, Pump& pump) noexcept
    : arm_(arm), pump_(pump) {
}

IrrigationControl::~IrrigationControl() {
    stop();
}

void IrrigationControl::spray(int x, int y,
    std::chrono::milliseconds intervalSpray,
    std::chrono::milliseconds intervalPause) {

        {
            std::unique_lock<std::mutex> lk(mtx_);
            if (running_) {
                requestStop_ = true;
                cv_.notify_all();
            }
        }
        if (worker_.joinable()) {
            worker_.join();
        }

        requestStop_ = false;
        running_ = true;
        worker_ = std::thread(&IrrigationControl::workerLoop, this, x, y, intervalSpray, intervalPause);
}

void IrrigationControl::stop() noexcept {
    {
        std::lock_guard<std::mutex> lk(mtx_);
        if (!running_) return;
        requestStop_ = true;
        cv_.notify_all();
    }
    if (worker_.joinable()) {
        worker_.join();
    }
    running_ = false;
    requestStop_ = false;

    try {
        if (pump_.isOn()) pump_.turnOff();
    }
    catch (...) {

    }
}

bool IrrigationControl::isRunning() const noexcept {
    return running_.load();
}

void IrrigationControl::workerLoop(int x, int y,
    std::chrono::milliseconds intervalSpray,
    std::chrono::milliseconds intervalPause) {
    auto safeWait = [this](std::chrono::milliseconds dur) -> bool {
        std::unique_lock<std::mutex> lk(mtx_);
        return !cv_.wait_for(lk, dur, [this]() { return requestStop_.load(); });

        };

    while (!requestStop_.load()) {

        try {
            arm_.aimAt(x, y);
        }
        catch (const std::exception& e) {
            std::cerr << "[IrrigationControl] aimAt threw: " << e.what() << "\n";
            
        }
        catch (...) {
            std::cerr << "[IrrigationControl] aimAt unknown exception\n";
        }


        if (!safeWait(std::chrono::milliseconds(200))) break;

        try {
            pump_.turnOn();
        }
        catch (const std::exception& e) {
            std::cerr << "[IrrigationControl] pump turnOn threw: " << e.what() << "\n";

        }


        if (!safeWait(intervalSpray)) break;


        try {
            pump_.turnOff();
        }
        catch (const std::exception& e) {
            std::cerr << "[IrrigationControl] pump turnOff threw: " << e.what() << "\n";
        }


        if (!safeWait(intervalPause)) break;
    }

    try {
        if (pump_.isOn()) pump_.turnOff();
    }
    catch (...) {}

    running_ = false;
}