#include "Pump.h"

void Pump::claimPins() {
    if (powerPin_ >= 0) assignPin(powerPin_);
    if (flowRatePin_ >= 0) assignPin(flowRatePin_);

    if (powerPin_ >= 0) pinMode(powerPin_, OUTPUT);

    if (flowRatePin_ >= 0) {
        pinMode(flowRatePin_, PWM_OUTPUT);
        pwmSetMode(PWM_MODE_MS);
        pwmSetRange(pumpScaler);
    }

    if (powerPin_ >= 0) digitalWrite(powerPin_, LOW);
    if (flowRatePin_ >= 0) pwmWrite(flowRatePin_, 0);
}

void Pump::releasePins() {
    if (powerPin_ >= 0) deassignPin(powerPin_);
    if (flowRatePin_ >= 0) deassignPin(flowRatePin_);
}

Pump::Pump(int powerPin, int flowRatePin)
    : powerPin_(powerPin), flowRatePin_(flowRatePin), on_(false)
{
    claimPins();
    setFlowRate(100.f); 
}

Pump::Pump(const Pump& other) noexcept
    : powerPin_(other.powerPin_), flowRatePin_(other.flowRatePin_),
    flowRate_(other.flowRate_), on_(false)
{
    claimPins();
    pwmWrite(flowRatePin_, flowRate_);
    digitalWrite(powerPin_, LOW);
}

Pump::Pump(Pump&& other) noexcept
    : powerPin_(other.powerPin_), flowRatePin_(other.flowRatePin_),
    flowRate_(other.flowRate_), on_(other.on_)
{
    other.powerPin_ = -1;
    other.flowRatePin_ = -1;
    other.flowRate_ = 0;
    other.on_ = false;

    claimPins();
    pwmWrite(flowRatePin_, flowRate_);
    digitalWrite(powerPin_, LOW);
}

Pump& Pump::operator=(const Pump& other) noexcept {
    if (this != &other) {
        releasePins();

        powerPin_ = other.powerPin_;
        flowRatePin_ = other.flowRatePin_;
        flowRate_ = other.flowRate_;
        on_ = false;

        claimPins();
        pwmWrite(flowRatePin_, flowRate_);
        digitalWrite(powerPin_, LOW);
    }
    return *this;
}

Pump& Pump::operator=(Pump&& other) noexcept {
    if (this != &other) {
        releasePins();

        powerPin_ = other.powerPin_;
        flowRatePin_ = other.flowRatePin_;
        flowRate_ = other.flowRate_;
        on_ = other.on_;

        other.powerPin_ = -1;
        other.flowRatePin_ = -1;
        other.flowRate_ = 0;
        other.on_ = false;

        claimPins();
        pwmWrite(flowRatePin_, flowRate_);
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

void Pump::setFlowRate(float percentage) {
    int pwm = percentageToPwm(percentage);
    flowRate_ = pwm;
    if (flowRatePin_ >= 0) pwmWrite(flowRatePin_, pwm);
}

Pump::~Pump() {
    turnOff();
    if (flowRatePin_ >= 0) pwmWrite(flowRatePin_, 0);
    releasePins();
}
