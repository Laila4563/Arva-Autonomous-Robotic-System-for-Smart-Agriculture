#include "Pump.h"

void Pump::claimPins() {
    if (powerPin_ >= 0) assignPin(powerPin_);

    if (powerPin_ >= 0) pinMode(powerPin_, OUTPUT);


    if (powerPin_ >= 0) digitalWrite(powerPin_, LOW);

}

void Pump::releasePins() {
    if (powerPin_ >= 0) deassignPin(powerPin_);
}

Pump::Pump(int powerPin)
    : powerPin_(powerPin), on_(false)
{
    claimPins();

}

Pump::Pump(const Pump& other) noexcept
    : powerPin_(other.powerPin_), on_(false)
{
    claimPins();
    digitalWrite(powerPin_, LOW);
}

Pump::Pump(Pump&& other) noexcept
    : powerPin_(other.powerPin_), on_(other.on_)
{
    other.powerPin_ = -1;
    other.on_ = false;

    claimPins();
    digitalWrite(powerPin_, LOW);
}

Pump& Pump::operator=(const Pump& other) noexcept {
    if (this != &other) {
        releasePins();

        powerPin_ = other.powerPin_;
        on_ = false;

        claimPins();
        digitalWrite(powerPin_, LOW);
    }
    return *this;
}

Pump& Pump::operator=(Pump&& other) noexcept {
    if (this != &other) {
        releasePins();

        powerPin_ = other.powerPin_;
        on_ = other.on_;

        other.powerPin_ = -1;
        other.on_ = false;

        claimPins();
        digitalWrite(powerPin_, LOW);
    }
    return *this;
}

void Pump::turnOn() {
    on_ = true;
    if (powerPin_ >= 0) digitalWrite(powerPin_, HIGH);
}

void Pump::turnOff() {
    on_ = false;
    if (powerPin_ >= 0) digitalWrite(powerPin_, LOW);
}

bool Pump::isOn() const {
    return on_;
}



Pump::~Pump() {
    turnOff();
    releasePins();
}