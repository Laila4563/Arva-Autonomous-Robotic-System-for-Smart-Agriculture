#pragma once
#include "../GPIO/gpio.h"
#include <atomic>
#include "../Config/Config.h"

class Pump {
public:
    Pump(int powerPin);
    Pump(const Pump& other) noexcept;
    Pump(Pump&& other) noexcept;
    Pump& operator=(const Pump& other) noexcept;
    Pump& operator=(Pump&& other) noexcept;
    ~Pump();

    void turnOn();
    void turnOff();
    bool isOn() const;

private:
    int powerPin_{ -1 };
    bool on_{ false };

    void claimPins();
    void releasePins();

};