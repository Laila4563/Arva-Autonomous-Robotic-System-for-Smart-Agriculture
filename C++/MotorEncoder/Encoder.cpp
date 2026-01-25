#include "Encoder.h"
#include <fstream>
#include <unistd.h>

MotorEncoder::MotorEncoder(int pulses_per_rev)
    : _ppr(pulses_per_rev), _running(false), _current_rpm(0.0) {}

MotorEncoder::~MotorEncoder() {
    stopMonitoring();
}

void MotorEncoder::startMonitoring(int gpio_pin) {
    _pin = gpio_pin;
    _running = true;
    _worker_thread = std::thread(&MotorEncoder::run, this);
}

void MotorEncoder::stopMonitoring() {
    _running = false;
    if (_worker_thread.joinable()) {
        _worker_thread.join();
    }
}

void MotorEncoder::run() {

    auto last_time = std::chrono::steady_clock::now();

    while (_running) {
        // --- This is where the Hardware Reading happens ---
        // For demonstration, we simulate a pulse detection.
        // In production, you'd use a poll() on the GPIO file descriptor.
        
        bool pulse_detected = false; 
        /* Hardware check logic here */

        if (pulse_detected) {
            auto now = std::chrono::steady_clock::now();
            auto duration = std::chrono::duration_cast<std::chrono::nanoseconds>(now - last_time).count();
            
            if (duration > 0) {
                double rpm = (60.0 * 1e9) / (duration * _ppr);
                _current_rpm = rpm;

                // Sync the timestamp to the event log
                std::lock_guard<std::mutex> lock(_log_mutex);
                _event_log.push_back({
                    std::chrono::system_clock::now().time_since_epoch().count(),
                    rpm
                });
            }
            last_time = now;
        }
        std::this_thread::sleep_for(std::chrono::microseconds(100)); // Polling interval
    }
}

double MotorEncoder::getRPM() {
    return _current_rpm.load();
}

std::vector<EncoderEvent> MotorEncoder::getEventLog() {
    std::lock_guard<std::mutex> lock(_log_mutex);
    return _event_log;
}

int main() {
    MotorEncoder encoder(20); //ppr = 20
    encoder.startMonitoring(17); // Use GPIO 17

    for(int i = 0; i < 5; ++i) {
        std::cout << "Current RPM: " << encoder.getRPM() << std::endl;
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }

    encoder.stopMonitoring();
    return 0;
}