#include "Yolo.h"


Yolo::Yolo(
    const std::string& param_path,
    const std::string& bin_path,
    const std::string& classesJson,
    int input_w,
    int input_h
) :  _input_w(input_w), _input_h(input_h), AiVisionModel(param_path, bin_path, classesJson)
{
    _net.load_param(this->param.c_str());
    _net.load_model(this->bin.c_str());

    _net.opt.openmp_blocktime = 0;
    _net.opt.use_fp16_storage = true;
    _net.opt.use_fp16_arithmetic = true;
}

void Yolo::setResolution(int w, int h) {
    _input_w = w;
    _input_h = h;
}

int Yolo::getResX() const {
    return _input_w;
}

int Yolo::getResY() const {
    return _input_h;
}

PreprocessResult Yolo::preprocess(const cv::Mat& bgr)
{
    cv::Mat rgb;
    if (bgr.channels() == 3) {
        cv::cvtColor(bgr, rgb, cv::COLOR_BGR2RGB);
    }
    else if (bgr.channels() == 4) {
        cv::cvtColor(bgr, rgb, cv::COLOR_BGRA2RGB);
    }
    else {
        cv::cvtColor(bgr, rgb, cv::COLOR_GRAY2RGB);
    }

    cv::Mat im0 = rgb.clone(); 

    const int target_h = _input_w;
    const int target_w = _input_h;

    const int orig_h = rgb.rows;
    const int orig_w = rgb.cols;

    const float r = std::min(static_cast<float>(target_h) / static_cast<float>(orig_h),
        static_cast<float>(target_w) / static_cast<float>(orig_w));

    const int new_w = static_cast<int>(orig_w * r);
    const int new_h = static_cast<int>(orig_h * r);

    const int dw = target_w - new_w;
    const int dh = target_h - new_h;

    const int pad_left = dw / 2;
    const int pad_right = dw - pad_left;
    const int pad_top = dh / 2;
    const int pad_bottom = dh - pad_top;

    cv::Mat resized;
    cv::resize(rgb, resized, cv::Size(new_w, new_h), 0, 0, cv::INTER_LINEAR);

    cv::Mat padded;
    cv::copyMakeBorder(resized, padded,
        pad_top, pad_bottom, pad_left, pad_right,
        cv::BORDER_CONSTANT, cv::Scalar(114, 114, 114));

    padded.convertTo(padded, CV_32F, 1.f / 255.f);

    const int out_w = padded.cols;
    const int out_h = padded.rows;

    ncnn::Mat in_mat(out_w, out_h, 3);

    const int area = out_w * out_h;
    for (int c = 0; c < 3; ++c) {
        float* dst = in_mat.channel(c);
        int idx = 0;
        for (int y = 0; y < out_h; ++y) {
            const float* row_ptr = padded.ptr<float>(y);
            const int row_base = y * out_w;
            for (int x = 0; x < out_w; ++x) {
                dst[row_base + x] = row_ptr[x * 3 + c];
            }
        }
        (void)idx; 
    }

    return { in_mat, im0, r, pad_left, pad_top };
}

std::vector<Object> Yolo::infer(const cv::Mat& frame) {
    auto prep = preprocess(frame);

    ncnn::Extractor ex = _net.create_extractor();
    ex.input("in0", prep.in_mat);

    ncnn::Mat out;
    ex.extract("out0", out);

    ncnn::Mat extracted = extract_tensor(out);

    return postprocess(extracted, prep.scale, prep.pad_w, prep.pad_h);
}

ncnn::Mat Yolo::extract_tensor(const ncnn::Mat& raw)
{
    if (raw.dims == 3 && raw.c > 6)
    {
        const int area = raw.w * raw.h;
        ncnn::Mat out(raw.w, raw.h, 6);
        for (int c = 0; c < 6; ++c)
        {
            const float* rptr = raw.channel(c);
            float* wptr = out.channel(c);

            std::memcpy(wptr, rptr, area * sizeof(float));
        }
        return out;
    }
    else if (raw.dims == 2 && raw.h >= 6)
    {
        const int F = raw.h;
        const int B = raw.w;
        ncnn::Mat out(B, 1, 6);

        for (int f = 0; f < 6; ++f)
        {
            const float* rptr = raw.row(f);
            float* wptr = out.channel(f);
            std::memcpy(wptr, rptr, B * sizeof(float));
        }
        return out;
    }
    return raw; 
}

std::vector<Object> Yolo::postprocess(
    const ncnn::Mat& m,
    float r, int pad_w, int pad_h)
{
    if (m.dims != 3 || m.c != 6)
        return {};

    const int W = m.w;
    const int H = m.h;
    const int N = W * H;

    const float* px = m.channel(0);
    const float* py = m.channel(1);
    const float* pw = m.channel(2);
    const float* ph = m.channel(3);
    const float* pconf = m.channel(4);
    const float* pcls = m.channel(5);

    std::vector<cv::Rect2d> boxes;
    std::vector<float>      scores;
    std::vector<int>        clsids;

    boxes.reserve(256);
    scores.reserve(256);
    clsids.reserve(256);

    for (int i = 0; i < N; ++i)
    {
        const float conf = pconf[i];
        if (conf <= _conf_th) continue;

        const float cx = (px[i] - pad_w) / r;
        const float cy = (py[i] - pad_h) / r;
        const float w = pw[i] / r;
        const float h = ph[i] / r;

        const float x1 = cx - 0.5f * w;
        const float y1 = cy - 0.5f * h;

        boxes.emplace_back(x1, y1, w, h);
        scores.push_back(conf);
        clsids.push_back(static_cast<int>(pcls[i]));
    }

    std::vector<int> keep;
    cv::dnn::NMSBoxes(boxes, scores, _conf_th, _nms_th, keep);

    std::vector<Object> dets;
    dets.reserve(keep.size());

    for (int idx : keep)
    {
        Object result;
        result.rect = boxes[idx];
        result.prob = scores[idx];
        result.label = clsids[idx];
        result.matched = false;
        dets.push_back(result);
    }

    return dets;
}

void Yolo::view(const cv::Mat& frame, const std::vector<Object>& dets)
{
    cv::Mat vis = frame.clone();
    for (const auto& d : dets) {
        cv::rectangle(vis, d.rect, cv::Scalar(0, 255, 0), 2);
        const std::string label = this->class_names[d.label] + " " + cv::format("%.2f", d.prob);
        cv::putText(vis, label, cv::Point(int(d.rect.x), int(d.rect.y) - 5), cv::FONT_HERSHEY_SIMPLEX, 0.6, cv::Scalar(0, 255, 0), 2);
    }
    cv::imshow("Detections", vis);
    cv::waitKey(0);
}
void Yolo::exportPic(const cv::Mat& frame, const std::vector<Object>& dets, const std::string& filename)
{
    
    const int fontFace = cv::FONT_HERSHEY_SIMPLEX;
    const double fontScale = 0.6;
    const int thickness = 2;
    const int margin = 5; 

   
    int need_top = 0, need_bottom = 0, need_left = 0, need_right = 0;
    for (const auto& d : dets) {
        const std::string label = this->class_names[d.label] + " " + cv::format("%.2f", d.prob);
        int baseline = 0;
        cv::Size textSize = cv::getTextSize(label, fontFace, fontScale, thickness, &baseline);

        int topY = int(d.rect.y) - margin - textSize.height;
        if (topY < 0) need_top = std::max(need_top, -topY);

        int leftX = int(d.rect.x);
        if (leftX < 0) need_left = std::max(need_left, -leftX + margin);

        int rightExt = int(d.rect.x) + textSize.width - frame.cols;
        if (rightExt > 0) need_right = std::max(need_right, rightExt + margin);

        int bottomY = int(d.rect.y) + int(d.rect.height) + margin + textSize.height;
        if (bottomY > frame.rows) need_bottom = std::max(need_bottom, bottomY - frame.rows + margin);
    }

    
    cv::Mat vis;
    if (need_top || need_bottom || need_left || need_right) {
        cv::copyMakeBorder(frame, vis, need_top, need_bottom, need_left, need_right,
            cv::BORDER_CONSTANT, cv::Scalar(255, 255, 255)); // white blank area
    }
    else {
        vis = frame.clone();
    }

    
    for (const auto& d : dets) {
        cv::Rect r(
            int(d.rect.x) + need_left,
            int(d.rect.y) + need_top,
            int(d.rect.width),
            int(d.rect.height)
        );
        cv::rectangle(vis, r, cv::Scalar(0, 255, 0), 2);

        const std::string label = this->class_names[d.label] + " " + cv::format("%.2f", d.prob);
        int baseline = 0;
        cv::Size textSize = cv::getTextSize(label, fontFace, fontScale, thickness, &baseline);

      
        int text_x = r.x;
        int text_y = r.y - margin;

     
        if (text_y - textSize.height < 0) {
            text_y = r.y + r.height + textSize.height + margin;
        }

        cv::putText(vis, label, cv::Point(text_x, text_y),
            fontFace, fontScale, cv::Scalar(0, 255, 0), thickness);
    }

    if (!cv::imwrite(filename, vis)) {
        std::cerr << "Failed to save image to " << filename << std::endl;
    }
}
std::vector<ObjectPoints> Yolo::getObjectPoints(const std::vector<Object>& dets)
{
    std::vector<ObjectPoints> points;
    points.reserve(dets.size());
    for (const auto& d : dets) {
        const float cx = d.rect.x + d.rect.width * 0.5f;
        const float cy = d.rect.y + d.rect.height * 0.5f;
        points.push_back({ cx, cy, d.label, this->class_names[d.label] });
    }
    return points;
}

void Yolo::viewObjectPoints(const cv::Mat& frame, const std::vector<Object>& dets)
{
    cv::Mat vis = frame.clone();
    for (const auto& d : dets) {
        cv::rectangle(vis, d.rect, cv::Scalar(0, 255, 0), 2);
        const std::string label = this->class_names[d.label] + " " + cv::format("%.2f", d.prob);
        cv::putText(vis, label, cv::Point(int(d.rect.x), int(d.rect.y) - 5), cv::FONT_HERSHEY_SIMPLEX, 0.6, cv::Scalar(0, 255, 0), 2);
    }
    const auto points = getObjectPoints(dets);
    for (const auto& p : points) {
        cv::circle(vis, cv::Point2f(p.x, p.y), 5, cv::Scalar(0, 0, 255), cv::FILLED);
        cv::putText(vis, "target", cv::Point(int(p.x) + 8, int(p.y) - 8), cv::FONT_HERSHEY_SIMPLEX, 0.6, cv::Scalar(0, 0, 255), 2);
    }
    cv::imshow("Detections + Targets", vis);
    cv::waitKey(0);
}
