#ifndef MPU6050_INTERFACE_H
#define MPU6050_INTERFACE_H

#include <cstdint>

struct AccelData {
	int16_t x;
	int16_t y;
	int16_t z;
};


struct GyroData {
	int16_t x;
	int16_t y;
	int16_t z;
};


struct TempData {
	float temperature;
};


class MPU6050Interface {
public:
	virtual ~MPU6050Interface() = default;


	virtual bool initialize() = 0;


	virtual AccelData getAcceleration() = 0;


	virtual GyroData getRotation() = 0;


	virtual TempData getTemperature() = 0;
};

#endif