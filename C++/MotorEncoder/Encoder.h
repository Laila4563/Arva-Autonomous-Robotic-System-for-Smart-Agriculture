#pragma once

#include <iostream>
#include <vector>
#include <chrono>
#include <thread>
#include <atomic>
#include <mutex>

// Structure to hold our synchronized event data
struct EncoderEvent {
    long long timestamp;
    double rpm;
};

class MotorEncoder {
public:
    MotorEncoder(int pulses_per_rev = 20);
    ~MotorEncoder();

    void startMonitoring(int gpio_pin);
    void stopMonitoring();
    double getRPM();
    std::vector<EncoderEvent> getEventLog();

private:
    void run(); // The background thread logic
    
    int _ppr;
    int _pin;
    std::atomic<bool> _running;
    std::atomic<double> _current_rpm;
    std::thread _worker_thread;
    
    std::vector<EncoderEvent> _event_log;
    std::mutex _log_mutex; // Protects the vector from simultaneous access
};

#endif