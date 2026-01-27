#include "LNPK107SoilSensor.h"

const char* LNPK107SoilSensor::units[5] = {
    "pH",
    "%RH",
    "℃",
    "us/cm",
    "mg/kg"
};

LNPK107SoilSensor::LNPK107SoilSensor(const std::string& device, int Id, int Baud)
    : m_dev(device)
{
    id = Id;
    baud = Baud;
    if (begin())
    {
        SerialStatus = true;
    }
    else
    {
        SerialStatus = false;
    }
}

LNPK107SoilSensor::~LNPK107SoilSensor() {

    closeSerial();
}

bool LNPK107SoilSensor::begin() {
    return openSerial() && configureSerial(baud);
}

bool LNPK107SoilSensor::openSerial() {
    if (m_fd >= 0) return true;
    m_fd = open(m_dev.c_str(), O_RDWR | O_NOCTTY | O_NONBLOCK);
    if (m_fd < 0) {
        perror(("open " + m_dev).c_str());
        return false;
    }

    int flags = fcntl(m_fd, F_GETFL, 0);
    flags &= ~O_NONBLOCK;
    fcntl(m_fd, F_SETFL, flags);
    return true;
}

void LNPK107SoilSensor::closeSerial() {
    if (m_fd >= 0) {
        close(m_fd);
        m_fd = -1;
    }
}

bool LNPK107SoilSensor::configureSerial(int baud) {
    if (m_fd < 0) return false;
    struct termios tty;
    memset(&tty, 0, sizeof tty);
    if (tcgetattr(m_fd, &tty) != 0) {
        perror("tcgetattr");
        return false;
    }

    cfmakeraw(&tty);

    speed_t speed;
 
    speed = B9600;
    
    cfsetispeed(&tty, B9600);
    cfsetospeed(&tty, B9600);
    tty.c_cflag &= ~CSTOPB;    
    tty.c_cflag &= ~PARENB;    
    tty.c_cflag &= ~CRTSCTS;   
    tty.c_cflag |= CLOCAL | CREAD;
    tty.c_cc[VMIN] = 0;
    tty.c_cc[VTIME] = 10;      
    tcsetattr(m_fd, TCSANOW, &tty);
    tcflush(m_fd, TCIOFLUSH);
    return true;
}

bool LNPK107SoilSensor::is_recent(const std::chrono::steady_clock::time_point& tp) const
{
    if (tp == std::chrono::steady_clock::time_point::min()) return false;
    auto now = std::chrono::steady_clock::now();
    return (now - tp) <= period;
}


void LNPK107SoilSensor::MODBUS_CRC16_Update(uint8_t data[8]) {
    uint16_t crc = 0xFFFF;

    for (uint8_t i = 0; i < 6; i++) {
        crc ^= data[i];
        for (uint8_t j = 0; j < 8; j++) {
            if (crc & 0x0001) {
                crc = (crc >> 1) ^ 0xA001; 
            }
            else {
                crc >>= 1;
            }
        }
    }

    data[6] = (uint8_t)(crc & 0xFF);  
    data[7] = (uint8_t)(crc >> 8);
}

bool LNPK107SoilSensor::sendRequest(uint8_t* request, int requestLength, uint8_t* response, int responseLength)
{
    std::fill_n(response, responseLength, 0xFF);
    MODBUS_CRC16_Update(request);
    tcflush(m_fd, TCIFLUSH);
    ssize_t written = write(m_fd, request, requestLength);
    if (written != requestLength) {
        perror("write");
        return -1;
    }
    tcdrain(m_fd);

    size_t total_read = 0;
    auto start = std::chrono::steady_clock::now();
    const int timeout_ms = 700;
    while (total_read < responseLength) {
        fd_set readfds;
        FD_ZERO(&readfds);
        FD_SET(m_fd, &readfds);
        struct timeval tv;
        tv.tv_sec = 0;
        tv.tv_usec = 100 * 1000;
        int rv = select(m_fd + 1, &readfds, nullptr, nullptr, &tv);
        if (rv > 0 && FD_ISSET(m_fd, &readfds)) {
            ssize_t r = read(m_fd, response + total_read, responseLength - total_read);
            if (r > 0) total_read += r;
            else if (r < 0) {
                perror("read");
                return false;
            }
        }
        auto now = std::chrono::steady_clock::now();
        if (std::chrono::duration_cast<std::chrono::milliseconds>(now - start).count() > timeout_ms) break;
    }

    if (total_read < responseLength) {
        fprintf(stderr, "Timeout reading response (got %zu bytes, expected %u)\n", total_read, responseLength);
        return false;
    }

    return true;
}

double LNPK107SoilSensor::Convert_PH(const uint8_t response[2]) {
    return (response[0] << 8 | response[1]) / 100.0;
}

double LNPK107SoilSensor::Convert_Moisture(const uint8_t response[2]) {
    return (response[0] << 8 | response[1]) / 10.0;
}

double LNPK107SoilSensor::Convert_Temp(const uint8_t response[2]) {
    return (int16_t)(response[0] << 8 | response[1]) / 10.0;
}

double LNPK107SoilSensor::Convert_EC(const uint8_t response[2]) {
    return response[0] << 8 | response[1];
}

double LNPK107SoilSensor::Convert_N(const uint8_t response[2]) {
    return response[0] << 8 | response[1];
}

double LNPK107SoilSensor::Convert_P(const uint8_t response[2]) {
    return response[0] << 8 | response[1];
}

double LNPK107SoilSensor::Convert_K(const uint8_t response[2]) {
    return response[0] << 8 | response[1];
}


double LNPK107SoilSensor::getPh() {
    Snycronizer sync(*this);
    uint8_t request[8] = { id, 0X03, 0X00, 0X00, 0X00, 0X00, 0x00 ,0x00 };
    uint8_t response[7];
    request[ADDR_H_POS] = PH_ADDR_H;
    request[ADDR_L_POS] = PH_ADDR_L;
    request[SIZE_POS] = 1;

    if (sendRequest(request, 8, response, 7))
        return Convert_PH(&response[3]);
    else 
        return -1;
}

double LNPK107SoilSensor::getEc()
{
    Snycronizer sync(*this);
    uint8_t request[8] = { id, 0X03, 0X00, 0X00, 0X00, 0X00, 0x00 ,0x00 };
    uint8_t response[7];
    request[ADDR_H_POS] = EC_ADDR_H;
    request[ADDR_L_POS] = EC_ADDR_L;
    request[SIZE_POS] = 1;

    if (sendRequest(request, 8, response, 7))
        return Convert_EC(&response[3]);
    else
        return -1;
}


double LNPK107SoilSensor::getMoisture()
{

    auto now = std::chrono::steady_clock::now();


    {
        std::lock_guard<std::mutex> lg(cache_mutex_);

        if (is_recent(lastMoistureRead)) {
            
        }
        else {

            if (is_recent(lastTempRead)) {
                lastMoistureRead = lastTempRead;
                return cachedMoisture;
            }
        }
    }

    Snycronizer sync(*this);
    uint8_t request[8] = { id, 0X03, 0X00, 0X00, 0X00, 0X00, 0x00 ,0x00 };
    uint8_t response[9];
    request[ADDR_H_POS] = MOISTURE_ADDR_H;
    request[ADDR_L_POS] = MOISTURE_ADDR_L;
    request[SIZE_POS] = 2;

    if (sendRequest(request, 8, response, 9))
    {
        double newTemp = Convert_Temp(&response[5]);
        double newMoisture = Convert_Moisture(&response[3]);

        
        {
            std::lock_guard<std::mutex> lg(cache_mutex_);
            cachedTemp = newTemp;
            cachedMoisture = newMoisture;
            auto t = std::chrono::steady_clock::now();
            lastMoistureRead = t;
        }

        return newMoisture;
    }
    else
        return -1;
}

double LNPK107SoilSensor::getTemp()
{

    auto now = std::chrono::steady_clock::now();

    {
        std::lock_guard<std::mutex> lg(cache_mutex_);
        if (is_recent(lastTempRead)) {

        }
        else {

            if (is_recent(lastMoistureRead)) {
                lastTempRead = lastMoistureRead;
                return cachedTemp;
            }
        }
    }

    Snycronizer sync(*this);
    uint8_t request[8] = { id, 0X03, 0X00, 0X00, 0X00, 0X00, 0x00 ,0x00 };
    uint8_t response[9];
    request[ADDR_H_POS] = MOISTURE_ADDR_H;
    request[ADDR_L_POS] = MOISTURE_ADDR_L;
    request[SIZE_POS] = 2;

    if (sendRequest(request, 8, response, 9))
    {
        double newMoisture = Convert_Moisture(&response[3]);
        double newTemp = Convert_Temp(&response[5]);

        {
            std::lock_guard<std::mutex> lg(cache_mutex_);
            cachedTemp = newTemp;
            cachedMoisture = newMoisture;
            auto t = std::chrono::steady_clock::now();
            lastTempRead = t;
        }

        return newTemp;
    }
    else
        return -100;
}

double LNPK107SoilSensor::getPhosphorus()
{
    
    auto now = std::chrono::steady_clock::now();

    {
        std::lock_guard<std::mutex> lg(cache_mutex_);
        if (is_recent(lastPhosphorusRead)) {

        }
        else {
            if (is_recent(lastNitrogenRead)) {
                lastPhosphorusRead = lastNitrogenRead;
                return cachedPhosphorus;
            }
            else if (is_recent(lastPotassiumRead))
            {
                lastPhosphorusRead = lastPotassiumRead;
                return cachedPhosphorus;
            }
        }
    }

    Snycronizer sync(*this);
    uint8_t request[8] = { id, 0X03, 0X00, 0X00, 0X00, 0X00, 0x00 ,0x00 };
    uint8_t response[11];
    request[ADDR_H_POS] = N_ADDR_H;
    request[ADDR_L_POS] = N_ADDR_L;
    request[SIZE_POS] = 3;

    if (sendRequest(request, 8, response, 11))
    {
        double newN = Convert_N(&response[3]);
        double newP = Convert_P(&response[5]);
        double newK = Convert_K(&response[7]);

        {
            std::lock_guard<std::mutex> lg(cache_mutex_);
            cachedNitrogen = newN;
            cachedPhosphorus = newP;
            cachedPotassium = newK;
            auto t = std::chrono::steady_clock::now();
            lastPhosphorusRead = t;
        }

        return newP;
    }
    else
        return -1;
}

double LNPK107SoilSensor::getPotassium()
{

    auto now = std::chrono::steady_clock::now();

    {
        std::lock_guard<std::mutex> lg(cache_mutex_);
        if (is_recent(lastPotassiumRead)) {

        }
        else {
            if (is_recent(lastNitrogenRead)) {
                lastPotassiumRead = lastNitrogenRead;
                return cachedPotassium;
            }
            else if (is_recent(lastPhosphorusRead))
            {
                lastPotassiumRead = lastPhosphorusRead;
                return cachedPotassium;
            }
        }
    }

    Snycronizer sync(*this);
    uint8_t request[8] = { id, 0X03, 0X00, 0X00, 0X00, 0X00, 0x00 ,0x00 };
    uint8_t response[11];
    request[ADDR_H_POS] = N_ADDR_H;
    request[ADDR_L_POS] = N_ADDR_L;
    request[SIZE_POS] = 3;

    if (sendRequest(request, 8, response, 11))
    {
        double newN = Convert_N(&response[3]);
        double newP = Convert_P(&response[5]);
        double newK = Convert_K(&response[7]);

        {
            std::lock_guard<std::mutex> lg(cache_mutex_);
            cachedNitrogen = newN;
            cachedPhosphorus = newP;
            cachedPotassium = newK;
            auto t = std::chrono::steady_clock::now();
            lastPotassiumRead = t;
        }

        return newK;
    }
    else
        return -1;
}

double LNPK107SoilSensor::getNitrogen() 
{
    
    auto now = std::chrono::steady_clock::now();

    {
        std::lock_guard<std::mutex> lg(cache_mutex_);
        if (is_recent(lastNitrogenRead)) {

        }
        else {
  
            if (is_recent(lastPhosphorusRead)) {
                lastNitrogenRead = lastPhosphorusRead;
                return cachedNitrogen;
            }
            else if (is_recent(lastPotassiumRead))
            {
                lastNitrogenRead = lastPotassiumRead;
                return cachedNitrogen;
            }
        }
    }
    Snycronizer sync(*this);
    uint8_t request[8] = { id, 0X03, 0X00, 0X00, 0X00, 0X00, 0x00 ,0x00 };
    uint8_t response[11];
    request[ADDR_H_POS] = N_ADDR_H;
    request[ADDR_L_POS] = N_ADDR_L;
    request[SIZE_POS] = 3;

    if (sendRequest(request, 8, response, 11))
    {
        double newN = Convert_N(&response[3]);
        double newP = Convert_P(&response[5]);
        double newK = Convert_K(&response[7]);

        {
            std::lock_guard<std::mutex> lg(cache_mutex_);
            cachedNitrogen = newN;
            cachedPhosphorus = newP;
            cachedPotassium = newK;
            auto t = std::chrono::steady_clock::now();
            lastNitrogenRead = t;
        }

        return newN;
    }
    else
        return -1;
}
NPKValues::NPKValues(double Nitrogen, double Phosphorus, double Potassium)
    : nitrogen(Nitrogen), phosphorus(Phosphorus), potassium(Potassium) {}

NPKValues LNPK107SoilSensor::getNPK()
{
    return NPKValues(getNitrogen(),getPhosphorus(),getPotassium());
}

Temp_MoistureValues LNPK107SoilSensor::getTempXMoisture()
{
    return Temp_MoistureValues(getTemp(), getMoisture());
}

Temp_MoistureValues::Temp_MoistureValues(double Temp, double Moisture) : temp(Temp), moisture(Moisture) {}

bool LNPK107SoilSensor::validatePh(double ph)
{
    return ph >= 0.0 && ph <= 14.0;
}

bool LNPK107SoilSensor::validateMoisture(double moisture)
{
    return moisture >= 0.0 && moisture <= 100.0;
}

bool LNPK107SoilSensor::validateTemp(double temp)
{
    return temp >= -40.0 && temp <= 85.0;
}

bool LNPK107SoilSensor::validateEc(double ec_us_cm) {
    return ec_us_cm >= 0.0 && ec_us_cm <= 20000.0;
}

bool LNPK107SoilSensor::validateNitrogen(double nitrogen_mgkg)
{
    return nitrogen_mgkg >= 0.0 && nitrogen_mgkg <= 10000.0;
}

bool LNPK107SoilSensor::validatePotassium(double potassium_mgkg) {
    return potassium_mgkg >= 0.0 && potassium_mgkg <= 5000.0;
}

bool LNPK107SoilSensor::validatePhosphorus(double phosphorus_mgkg) {
    return phosphorus_mgkg >= 0.0 && phosphorus_mgkg <= 1000.0; 
}

std::string LNPK107SoilSensor::getUnit(unitType reading)
{
    if (reading >= 0 && reading <= 4)
        return std::string(units[reading]);
    else
        return "not valid unit";
}

bool LNPK107SoilSensor::Opened()
{
    return SerialStatus;
}

LNPK107SoilSensor::Snycronizer::Snycronizer(LNPK107SoilSensor& parent_)
    : parent(parent_), lock(parent_.mutex_)
{
    auto now = std::chrono::steady_clock::now();

    while (parent.last_present != std::chrono::steady_clock::time_point::min()) {
        auto next_allowed = parent.last_present + parent.period;
        if (now >= next_allowed) break;

        auto wait_for = next_allowed - now;
        parent.cond_.wait_for(lock, wait_for);
        now = std::chrono::steady_clock::now();
    }

}

LNPK107SoilSensor::Snycronizer::~Snycronizer()
{
    
    parent.last_present = std::chrono::steady_clock::now();
    parent.cond_.notify_one();
}

double NPKValues::Nitrogen() const
{
    return nitrogen;
}

double NPKValues::Phosphorus() const
{
    return phosphorus;
}

double NPKValues::Potassium() const
{
    return potassium;
}

double Temp_MoistureValues::Temp() const
{
    return temp;
}

double Temp_MoistureValues::Moisture() const
{
    return moisture;
}