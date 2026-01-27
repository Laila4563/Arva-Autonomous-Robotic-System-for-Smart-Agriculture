#include "MPU6050.h"

static constexpr const char* DEFAULT_I2C_DEV = "/dev/i2c-1";

MPU6050::MPU6050(int i2cAddress) : fd(-1), MPU_ADDR(i2cAddress) {

    fd = ::open(DEFAULT_I2C_DEV, O_RDWR);
    if (fd < 0) {
        std::perror("MPU6050: opening i2c device");
    }
    else {

        if (ioctl(fd, I2C_SLAVE, MPU_ADDR) < 0) {
            std::perror("MPU6050: ioctl I2C_SLAVE");
            ::close(fd);
            fd = -1;
        }
    }

}

MPU6050::~MPU6050() {


    if (fd >= 0) {
        ::close(fd);
        fd = -1;
    }
}

bool MPU6050::initialize() {
    if (fd < 0) return false;

    if (!writeReg(PWR_MGMT_1, 0x00)) {
        return false;
    }

    usleep(100000);
    return true;
}

bool MPU6050::writeReg(uint8_t reg, uint8_t value) {
    if (fd < 0) return false;

    uint8_t buf[2];
    buf[0] = reg;
    buf[1] = value;

    ssize_t written = ::write(fd, buf, 2);
    if (written != 2) {
        std::fprintf(stderr, "MPU6050: writeReg failed reg=0x%02x err=%s\n", reg, std::strerror(errno));
        return false;
    }
    return true;
}

int16_t MPU6050::readWord(int reg) {
    if (fd < 0) return 0;

    uint8_t reg_buf = static_cast<uint8_t>(reg);

    ssize_t w = ::write(fd, &reg_buf, 1);
    if (w != 1) {
        std::fprintf(stderr, "MPU6050: readWord write reg failed reg=0x%02x err=%s\n", reg, std::strerror(errno));
        return 0;
    }

    uint8_t data[2] = { 0,0 };
    ssize_t r = ::read(fd, data, 2);
    if (r != 2) {
        std::fprintf(stderr, "MPU6050: readWord read failed reg=0x%02x read=%zd err=%s\n", reg, r, std::strerror(errno));
        return 0;
    }

    int16_t value = static_cast<int16_t>((data[0] << 8) | data[1]);
    return value;
}

AccelData MPU6050::getAcceleration() {
    AccelData data;
    data.x = readWord(ACCEL_XOUT_H);
    data.y = readWord(ACCEL_XOUT_H + 2);
    data.z = readWord(ACCEL_XOUT_H + 4);
    return data;
}

GyroData MPU6050::getRotation() {
    GyroData data;
    data.x = readWord(GYRO_XOUT_H);
    data.y = readWord(GYRO_XOUT_H + 2);
    data.z = readWord(GYRO_XOUT_H + 4);
    return data;
}

TempData MPU6050::getTemperature() {
    TempData data;

    int16_t rawTemp = readWord(TEMP_OUT_H);
    data.temperature = rawTemp / 340.0f + 36.53f;
    return data;
}