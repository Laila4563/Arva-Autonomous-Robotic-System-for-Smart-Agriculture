#ifndef MPU6050_H
#define MPU6050_H

#include "MPU6050Interface.h"
#include <cstdint>
#include <string>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/i2c-dev.h>
#include <cerrno>
#include <cstdio>
#include <cstring>

#define sensitivity 131.0f
#define PWR_MGMT_1   0x6B
#define ACCEL_XOUT_H 0x3B
#define GYRO_XOUT_H  0x43
#define TEMP_OUT_H   0x41

class MPU6050 : public MPU6050Interface {
private:
	int fd;
	const int MPU_ADDR;

	int16_t readWord(int reg);
	bool writeReg(uint8_t reg, uint8_t value);

public:

	MPU6050(int i2cAddress = 0x68);
	virtual ~MPU6050();


	bool initialize() override;
	AccelData getAcceleration() override;
	GyroData getRotation() override;
	TempData getTemperature() override;
};


#endif