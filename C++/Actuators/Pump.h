#pragma once
#include <wiringPi.h>
#include <atomic>
#include "../Config/Config.h"

#define pumpScaler 1024

class Pump {
public:
    Pump(int powerPin, int flowRatePin);
    Pump(const Pump& other) noexcept;
    Pump(Pump&& other) noexcept;
    Pump& operator=(const Pump& other) noexcept;
    Pump& operator=(Pump&& other) noexcept;
    ~Pump();

    void turnOn();
    void turnOff();
    bool isOn() const;

    void setFlowRate(float percentage); 

private:
    int powerPin_{ -1 };
    int flowRatePin_{ -1 };
    int flowRate_{ 0 };
    bool on_{ false };

    void claimPins();
    void releasePins();

    static inline int percentageToPwm(float percentage) {
        if (percentage < 0.f) percentage = 0.f;
        if (percentage > 100.f) percentage = 100.f;
        return static_cast<int>((percentage * pumpScaler) / 100.f);
    }
};