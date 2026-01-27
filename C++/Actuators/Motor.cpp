#include "Motor.h"

void Motor::claimPins() {
    if (forwardPin_ >= 0) assignPin(forwardPin_);
    if (backwardPin_ >= 0) assignPin(backwardPin_);
    if (speedPin_ >= 0) assignPin(speedPin_);

    if (forwardPin_ >= 0) pinMode(forwardPin_, OUTPUT);
    if (backwardPin_ >= 0) pinMode(backwardPin_, OUTPUT);
    if (speedPin_ >= 0) {
        pinMode(speedPin_, PWM_OUTPUT);
        pwmSetMode(PWM_MODE_MS);
        pwmSetRange(scaler);
    }

    if (forwardPin_ >= 0) digitalWrite(forwardPin_, LOW);
    if (backwardPin_ >= 0) digitalWrite(backwardPin_, LOW);
    if (speedPin_ >= 0) pwmWrite(speedPin_, 0);
}

void Motor::releasePins() {
    if (forwardPin_ >= 0) deassignPin(forwardPin_);
    if (backwardPin_ >= 0) deassignPin(backwardPin_);
    if (speedPin_ >= 0) deassignPin(speedPin_);
}

Motor::Motor(int forwardPin, int backwardPin, int speedPin)
    : forwardPin_(forwardPin), backwardPin_(backwardPin), speedPin_(speedPin), speed_(0)
{
    claimPins();
    setSpeed(100);
}

Motor::Motor(const Motor& other) noexcept
    : forwardPin_(other.forwardPin_), backwardPin_(other.backwardPin_), speedPin_(other.speedPin_),
    speed_(other.speed_)
{
    claimPins();
    if (speed_ > 0 && speedPin_ >= 0) pwmWrite(speedPin_, speed_);
    if (forwardPin_ >= 0) digitalWrite(forwardPin_, LOW);
    if (backwardPin_ >= 0) digitalWrite(backwardPin_, LOW);
}

Motor::Motor(Motor&& other) noexcept
    : forwardPin_(other.forwardPin_), backwardPin_(other.backwardPin_), speedPin_(other.speedPin_),
    speed_(other.speed_)
{
    other.forwardPin_ = -1;
    other.backwardPin_ = -1;
    other.speedPin_ = -1;
    other.speed_ = 0;

    claimPins();
    if (speed_ > 0 && speedPin_ >= 0) pwmWrite(speedPin_, speed_);
    if (forwardPin_ >= 0) digitalWrite(forwardPin_, LOW);
    if (backwardPin_ >= 0) digitalWrite(backwardPin_, LOW);
}

Motor& Motor::operator=(const Motor& other) noexcept {
    if (this != &other) {
        releasePins();

        forwardPin_ = other.forwardPin_;
        backwardPin_ = other.backwardPin_;
        speedPin_ = other.speedPin_;
        speed_ = other.speed_;

        claimPins();
        if (speed_ > 0 && speedPin_ >= 0) pwmWrite(speedPin_, speed_);
        if (forwardPin_ >= 0) digitalWrite(forwardPin_, LOW);
        if (backwardPin_ >= 0) digitalWrite(backwardPin_, LOW);
    }
    return *this;
}

Motor& Motor::operator=(Motor&& other) noexcept {
    if (this != &other) {
        releasePins();

        forwardPin_ = other.forwardPin_;
        backwardPin_ = other.backwardPin_;
        speedPin_ = other.speedPin_;
        speed_ = other.speed_;

        other.forwardPin_ = -1;
        other.backwardPin_ = -1;
        other.speedPin_ = -1;
        other.speed_ = 0;

        claimPins();
        if (speed_ > 0 && speedPin_ >= 0) pwmWrite(speedPin_, speed_);
        if (forwardPin_ >= 0) digitalWrite(forwardPin_, LOW);
        if (backwardPin_ >= 0) digitalWrite(backwardPin_, LOW);
    }
    return *this;
}

void Motor::moveForward() {
    if (backwardPin_ >= 0) digitalWrite(backwardPin_, LOW);
    if (forwardPin_ >= 0) digitalWrite(forwardPin_, HIGH);
}

void Motor::moveBackward() {
    if (forwardPin_ >= 0) digitalWrite(forwardPin_, LOW);
    if (backwardPin_ >= 0) digitalWrite(backwardPin_, HIGH);
}

void Motor::stop() {
    if (forwardPin_ >= 0) digitalWrite(forwardPin_, LOW);
    if (backwardPin_ >= 0) digitalWrite(backwardPin_, LOW);
}

void Motor::setSpeed(int percentage) {
    int pwm = percentageToPwm(percentage);
    speed_ = pwm;
    if (speedPin_ >= 0) pwmWrite(speedPin_, pwm);
}

Motor::~Motor() {
    stop();
    if (speedPin_ >= 0) pwmWrite(speedPin_, 0);
    releasePins();
}