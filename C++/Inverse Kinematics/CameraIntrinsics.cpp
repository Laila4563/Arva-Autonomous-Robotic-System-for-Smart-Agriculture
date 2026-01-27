#include "CameraIntrinsics.h"

CameraIntrinsics::CameraIntrinsics(float Z_m, float focal_mm, float sensor_w_mm, float sensor_h_mm, IntSize sensorRes, IntSize currentRes)
    : Z(Z_m),
    sensorRes(sensorRes),
    currentRes(currentRes)
{
    float px_per_mm_x = static_cast<float>(sensorRes.x) / sensor_w_mm;
    float px_per_mm_y = static_cast<float>(sensorRes.y) / sensor_h_mm;
    fx_native = focal_mm * px_per_mm_x;
    fy_native = focal_mm * px_per_mm_y;

    cx_native = static_cast<float>(sensorRes.x) * 0.5f;
    cy_native = static_cast<float>(sensorRes.y) * 0.5f;

    sx = static_cast<float>(currentRes.x) / static_cast<float>(sensorRes.x);
    sy = static_cast<float>(currentRes.y) / static_cast<float>(sensorRes.y);

    fx = fx_native * sx;
    fy = fy_native * sy;

    cx = static_cast<float>(currentRes.x) * 0.5f;
    cy = static_cast<float>(currentRes.y) * 0.5f;
}

XYf CameraIntrinsics::PixelsToDistance(float px, float py) const {
    float dx_pix = px - cx;
    float dy_pix = py - cy;

    float X = (dx_pix / fx) * Z;
    float Y = (dy_pix / fy) * Z;

    return XYf{ X, Y };
}

XYf CameraIntrinsics::getOrigin() const
{

    float half_w_pix = static_cast<float>(currentRes.x) * 0.5f;
    float half_h_pix = static_cast<float>(currentRes.y) * 0.5f;

    float half_w_m = (half_w_pix / fx) * Z;
    float half_h_m = (half_h_pix / fy) * Z;

    return XYf{ half_w_m, half_h_m };
}

float CameraIntrinsics::getFx() const
{
    return fx;
}

float CameraIntrinsics::getFy() const
{
    return fy;
}

float CameraIntrinsics::getCx() const
{
    return cx;
}

float CameraIntrinsics::getCy() const
{
    return cy;
}

void CameraIntrinsics::log_debug_line(const std::string& s)
{
    std::ofstream f("/tmp/cam_draw_debug.log", std::ios::app);
    if (f) {
        f << s << std::endl;
    }
}

void CameraIntrinsics::DrawRulerDotsDebug(cv::Mat& frame, float cm)
{
    try {
        if (cm <= 0.0f) {
            log_debug_line("DrawRulerDotsDebug: cm <= 0 -> return");
            return;
        }
        if (Z <= 0.0f) {
            log_debug_line("DrawRulerDotsDebug: Z <= 0 -> return");
            return;
        }
        if (currentRes.x <= 0 || currentRes.y <= 0) {
            log_debug_line("DrawRulerDotsDebug: invalid currentRes -> return");
            return;
        }
        if (!frame.data) {
            log_debug_line("DrawRulerDotsDebug: frame.data == nullptr -> return");
            return;
        }
        if (frame.cols <= 0 || frame.rows <= 0) {
            log_debug_line("DrawRulerDotsDebug: frame has zero dims -> return");
            return;
        }

        {
            std::ostringstream oss;
            oss << "Frame: cols=" << frame.cols << " rows=" << frame.rows
                << " type=" << frame.type() << " channels=" << frame.channels()
                << " step=" << frame.step[0];
            log_debug_line(oss.str());
        }

        float half_m = (cm * 0.5f) / 100.0f;
        if (!std::isfinite(half_m)) {
            log_debug_line("DrawRulerDotsDebug: half_m not finite -> return");
            return;
        }

        if (!std::isfinite(fx) || !std::isfinite(Z) || fx == 0.0f) {
            log_debug_line("DrawRulerDotsDebug: fx/Z invalid -> return");
            return;
        }

        float dx_pix = (half_m * fx) / Z;
        if (!std::isfinite(dx_pix)) {
            log_debug_line("DrawRulerDotsDebug: dx_pix not finite -> return");
            return;
        }

        float s_x = 1.0f, s_y = 1.0f;
        if (currentRes.x > 0) s_x = frame.cols / static_cast<float>(currentRes.x);
        if (currentRes.y > 0) s_y = frame.rows / static_cast<float>(currentRes.y);

        if (!std::isfinite(s_x) || !std::isfinite(s_y)) {
            log_debug_line("DrawRulerDotsDebug: s_x or s_y not finite -> return");
            return;
        }

        float cx_frame = frame.cols * 0.5f;
        float cy_frame = frame.rows * 0.5f;


        long double dx_pix_scaled_ld = static_cast<long double>(dx_pix) * static_cast<long double>(s_x);

        long double clamp_limit = std::max(frame.cols, frame.rows) * 10.0L;
        if (dx_pix_scaled_ld > clamp_limit) dx_pix_scaled_ld = clamp_limit;
        if (dx_pix_scaled_ld < -clamp_limit) dx_pix_scaled_ld = -clamp_limit;

        long long x_left_ll = static_cast<long long>(std::llround(cx_frame - dx_pix_scaled_ld));
        long long x_right_ll = static_cast<long long>(std::llround(cx_frame + dx_pix_scaled_ld));
        long long y_ll = static_cast<long long>(std::llround(cy_frame));

        int x_left = static_cast<int>(std::max(0LL, std::min(static_cast<long long>(frame.cols - 1), x_left_ll)));
        int x_right = static_cast<int>(std::max(0LL, std::min(static_cast<long long>(frame.cols - 1), x_right_ll)));
        int y = static_cast<int>(std::max(0LL, std::min(static_cast<long long>(frame.rows - 1), y_ll)));

        {
            std::ostringstream oss;
            oss << "Computed: dx_pix=" << dx_pix << " s_x=" << s_x
                << " dx_pix_scaled=" << static_cast<double>(dx_pix_scaled_ld)
                << " x_left=" << x_left << " x_right=" << x_right << " y=" << y;
            log_debug_line(oss.str());
        }

        int radius = std::max(2, static_cast<int>(std::round(std::min(frame.cols, frame.rows) * 0.01f)));

        if (!frame.isContinuous() || frame.elemSize() <= 0) {
            log_debug_line("DrawRulerDotsDebug: frame not continuous or invalid elemSize - cloning before draw");
            frame = frame.clone();
        }

        if (x_left >= 0 && x_left < frame.cols && y >= 0 && y < frame.rows) {
            cv::circle(frame, cv::Point(x_left, y), radius, cv::Scalar(0, 0, 255), cv::FILLED, cv::LINE_AA);
        }
        else {
            log_debug_line("DrawRulerDotsDebug: left point out of bounds, not drawing left");
        }

        if (x_right >= 0 && x_right < frame.cols && y >= 0 && y < frame.rows) {
            cv::circle(frame, cv::Point(x_right, y), radius, cv::Scalar(0, 0, 255), cv::FILLED, cv::LINE_AA);
        }
        else {
            log_debug_line("DrawRulerDotsDebug: right point out of bounds, not drawing right");
        }

        log_debug_line("DrawRulerDotsDebug: draw complete");
    }
    catch (const std::exception& e) {
        std::ostringstream oss;
        oss << "DrawRulerDotsDebug: caught exception: " << e.what();
        log_debug_line(oss.str());
    }
    catch (...) {
        log_debug_line("DrawRulerDotsDebug: caught unknown exception");
    }
}