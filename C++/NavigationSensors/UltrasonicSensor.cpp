#include "UltrasonicSensor.h"

static constexpr float SOUND_SPEED_CM_PER_US = 0.0343f;
static constexpr long long ECHO_START_TIMEOUT_US = 30000;
static constexpr long long ECHO_END_TIMEOUT_US = 30000;

UltrasonicSensor::UltrasonicSensor(int triggerPin, int echoPin)
    : triggerPin_(triggerPin), echoPin_(echoPin)
{
    pinMode(triggerPin_, OUTPUT);
    pinMode(echoPin_, INPUT);

    // ensure trigger is low
    digitalWrite(triggerPin_, LOW);
    std::this_thread::sleep_for(std::chrono::milliseconds(2));
}

UltrasonicSensor::~UltrasonicSensor() {

}

long long UltrasonicSensor::nowMicros() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (long long)ts.tv_sec * 1000000LL + (ts.tv_nsec / 1000LL);
}

float UltrasonicSensor::getDistance() {

    digitalWrite(triggerPin_, LOW);
    std::this_thread::sleep_for(std::chrono::microseconds(2));

    digitalWrite(triggerPin_, HIGH);
    std::this_thread::sleep_for(std::chrono::microseconds(10));
    digitalWrite(triggerPin_, LOW);


    long long startWait = nowMicros();
    while (digitalRead(echoPin_) == LOW) {
        if (nowMicros() - startWait > ECHO_START_TIMEOUT_US) {

            return -1.0f;
        }

        std::this_thread::sleep_for(std::chrono::microseconds(10));
    }


    long long tStart = nowMicros();

    while (digitalRead(echoPin_) == HIGH) {
        if (nowMicros() - tStart > ECHO_END_TIMEOUT_US) {

            return -1.0f;
        }
        std::this_thread::sleep_for(std::chrono::microseconds(10));
    }

    long long tEnd = nowMicros();
    long long durationUs = tEnd - tStart;

    float distanceCm = (durationUs * SOUND_SPEED_CM_PER_US) / 2.0f;

    return distanceCm;
}