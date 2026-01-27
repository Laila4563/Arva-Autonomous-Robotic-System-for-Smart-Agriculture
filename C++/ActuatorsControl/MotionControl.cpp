#include "MotionControl.h"

MotionControl::MotionControl(Motor& left, Motor& right, MPU6050& sensor)
    : leftMotor(left), rightMotor(right), sensor(sensor), onFinish(nullptr) {
}

void MotionControl::setOnFinish(std::function<void(float)> callback) {
    onFinish = callback;
}

void MotionControl::turn(float angle) {
    float heading = 0.0f;
    float targetHeading = angle;

    std::cout << "[MotionControl] Turning " << angle << "°...\n";

    if (angle > 0) {
        leftMotor.moveForward();
        rightMotor.moveBackward();
    }
    else {
        leftMotor.moveBackward();
        rightMotor.moveForward();
    }

    unsigned long lastTime = micros();

    while (true) {
        unsigned long currentTime = micros();
        float dt = (currentTime - lastTime) / 1e6f;
        lastTime = currentTime;

        GyroData gyro = sensor.getRotation();
        std::cout << "z: " << gyro.z << std::endl;
        float angularRate = static_cast<float>(gyro.z) / sensitivity;

        heading += angularRate * dt;

        std::cout << "[MotionControl] Heading: " << heading << "°\n";

        if ((angle > 0 && heading >= targetHeading) ||
            (angle < 0 && heading <= targetHeading)) {
            break;
        }
        std::this_thread::sleep_for(std::chrono::milliseconds(1));
    }

    leftMotor.stop();
    rightMotor.stop();

    std::cout << "[MotionControl] Target " << targetHeading
        << "° reached. Turn complete.\n";

    if (onFinish) onFinish(angle);
}

void MotionControl::moveForward() {
    leftMotor.moveForward();
    rightMotor.moveForward();
}

void MotionControl::moveBackward() {
    leftMotor.moveBackward();
    rightMotor.moveBackward();
}

void MotionControl::stop() {
    leftMotor.stop();
    rightMotor.stop();
}

void MotionControl::setSpeed(float percentage) {
    leftMotor.setSpeed(percentage);
    rightMotor.setSpeed(percentage);
}