#ifndef SOILSENSOR_H
#define SOILSENSOR_H

#include <fcntl.h>
#include <cstdio>
#include <string>
#include <fstream>
#include <string.h>
#include <termios.h>
#include <cstdint>
#include <unistd.h>
#include <chrono>
#include <mutex>
#include <condition_variable>

#define PH_ADDR_H 0x00
#define PH_ADDR_L 0x06
#define MOISTURE_ADDR_H 0x00
#define MOISTURE_ADDR_L 0x12
#define TEMP_ADDR_H 0x00
#define TEMP_ADDR_L 0x13
#define EC_ADDR_H 0x00
#define EC_ADDR_L 0x15
#define N_ADDR_H 0x00
#define N_ADDR_L 0x1E
#define P_ADDR_H 0x00
#define P_ADDR_L 0x1F
#define K_ADDR_H 0x00
#define K_ADDR_L 0x20
#define ID_ADDR_H 0x01
#define ID_ADDR_L 0x00
#define BAUD_ADDR_H 0x01
#define BAUD_ADDR_L 0x01
#define ADDR_H_POS 2
#define ADDR_L_POS 3
#define SIZE_POS 5

class NPKValues;
class Temp_MoistureValues;

class LNPK107SoilSensor {

public:

    enum unitType
    {
        pH = 0,
        moisture = 1,
        temp=2,
        Ec=3,
        nitrogen=4,
        potassium=4,
        phosphorus=4
    };

    LNPK107SoilSensor(const std::string& device = "/dev/ttyUSB0", int Id = 1, int Baud = 9600);
    ~LNPK107SoilSensor();

    double getPh();
    double getEc();
    double getMoisture();
    double getTemp();
    double getPhosphorus();
    double getPotassium();
    double getNitrogen();

    NPKValues getNPK();
    Temp_MoistureValues getTempXMoisture();

    bool validatePh(double ph);
    bool validateMoisture(double moisture);
    bool validateTemp(double temp);
    bool validateEc(double ec_us_cm);
    bool validateNitrogen(double nitrogen_mgkg);
    bool validatePotassium(double potassium_mgkg);
    bool validatePhosphorus(double phosphorus_mgkg);

    std::string getUnit(unitType reading);

    bool Opened();

private:
    static const char* units[5];
    friend class Snycronizer;
    double  cachedTemp=-100, cachedMoisture=-1, cachedNitrogen=-1, cachedPotassium=-1, cachedPhosphorus=-1;
    bool SerialStatus;
    bool begin();
    bool openSerial();
    void closeSerial();
    bool configureSerial(int baud);
    bool is_recent(const std::chrono::steady_clock::time_point& tp) const;
    static void MODBUS_CRC16_Update(uint8_t data[8]);
    bool sendRequest(uint8_t* request, int requestLength, uint8_t* response, int responseLength);
    static double Convert_PH(const uint8_t response[2]);
    static double Convert_Moisture(const uint8_t response[2]);
    static double Convert_Temp(const uint8_t response[2]);
    static double Convert_EC(const uint8_t response[2]);
    static double Convert_N(const uint8_t response[2]);
    static double Convert_P(const uint8_t response[2]);
    static double Convert_K(const uint8_t response[2]);

    std::string m_dev;
    int m_fd = -1;
    int id, baud;

    class Snycronizer {
    public:
        explicit Snycronizer(LNPK107SoilSensor& parent_);
        ~Snycronizer();
        Snycronizer(const Snycronizer&) = delete;
        Snycronizer& operator=(const Snycronizer&) = delete;
        Snycronizer(Snycronizer&&) = delete;
        Snycronizer& operator=(Snycronizer&&) = delete;

    private:
        LNPK107SoilSensor& parent;
        std::unique_lock<std::mutex> lock;
    };

    static constexpr auto period = std::chrono::seconds(1);

    std::mutex mutex_;
    std::mutex cache_mutex_;
    std::condition_variable cond_;
    std::chrono::steady_clock::time_point last_present{ std::chrono::steady_clock::time_point::min() };
    std::chrono::steady_clock::time_point lastTempRead{ std::chrono::steady_clock::time_point::min() };
    std::chrono::steady_clock::time_point lastMoistureRead{ std::chrono::steady_clock::time_point::min() };
    std::chrono::steady_clock::time_point lastNitrogenRead{ std::chrono::steady_clock::time_point::min() };
    std::chrono::steady_clock::time_point lastPhosphorusRead{ std::chrono::steady_clock::time_point::min() };
    std::chrono::steady_clock::time_point lastPotassiumRead{ std::chrono::steady_clock::time_point::min() };
};

class NPKValues {
private:
    double nitrogen, phosphorus, potassium;

    NPKValues(double Nitrogen, double Phosphorus, double Potassium);
    friend class LNPK107SoilSensor;

public:
    double Nitrogen() const;
    double Phosphorus() const;
    double Potassium() const;
};

class Temp_MoistureValues {
private:
    double temp, moisture;

    Temp_MoistureValues(double Temp, double Moisture);
    friend class LNPK107SoilSensor;

public:
    double Temp() const;
    double Moisture() const;
};

#endif 