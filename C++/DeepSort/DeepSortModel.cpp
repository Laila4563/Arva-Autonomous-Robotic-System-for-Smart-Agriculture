#include "DeepSortModel.h"


DeepSortModel::DeepSortModel(const std::string& deepsort_param, const std::string& deepsort_bin, const std::string& classesJson) : AiVisionModel(deepsort_param, deepsort_bin, classesJson)
{

    deepSort_.reset(new DeepSort(this->bin, this->param)); 
    id_tracker_.reset(new tracker()); 
}

std::vector<DeepSortResult> DeepSortModel::infer(cv::Mat& frame,
    std::vector<Object>& dets)
{
    std::vector<DeepSortResult> results;
    DETECTIONS detections;

    postprocess(frame, dets, detections);

    if (!detections.empty() && deepSort_->getRectsFeature(frame, detections)) {
        id_tracker_->predict();
        id_tracker_->update(detections);

        for (Track& track : id_tracker_->tracks) {
            if (!track.is_confirmed() || track.time_since_update > 1)
            {
                continue;
            }

            auto tlwh = track.to_tlwh();
            cv::Rect_<float> rect(static_cast<float>(tlwh(0)),
                static_cast<float>(tlwh(1)),
                static_cast<float>(tlwh(2)),
                static_cast<float>(tlwh(3)));
            
            DeepSortResult r;
            r.box = rect;
            r.track_id = track.track_id;       
            matchDeepSortResult(r, dets);
            if (r.class_id != -1 && r.class_id>=0 && r.class_id < static_cast<int>(this->class_names.size()))
            {
                r.class_name = this->class_names[r.class_id];
            }
            
            results.push_back(r);
        }
    }
    return results;
}

void DeepSortModel::view(const cv::Mat& frame, const std::vector<DeepSortResult>& results, const std::string& winname)
{
    cv::Mat vis = frame.clone();
    for (const auto& r : results) {
        cv::rectangle(vis, r.box, cv::Scalar(0, 255, 0), 2);

        std::string cls = r.class_name.empty() ? ("class_" + std::to_string(r.class_id)) : r.class_name;

        std::ostringstream label_ss;
        label_ss << cls << " ID:" << r.track_id;
        std::string label = label_ss.str();

        int baseLine = 0;
        cv::Size labelSize = cv::getTextSize(label, cv::FONT_HERSHEY_SIMPLEX, 0.6, 1, &baseLine);
        int top = std::max<int>(static_cast<int>(r.box.y), labelSize.height);

        cv::rectangle(vis,
            cv::Point(static_cast<int>(r.box.x), top - labelSize.height - baseLine),
            cv::Point(static_cast<int>(r.box.x) + labelSize.width, top),
            cv::Scalar(255, 255, 255), cv::FILLED);

        cv::putText(vis, label, cv::Point(static_cast<int>(r.box.x), top - 4),
            cv::FONT_HERSHEY_SIMPLEX, 0.6, cv::Scalar(0, 0, 0), 1);
    }

    cv::imshow(winname, vis);
    cv::waitKey(0); 
}

void DeepSortModel::exportDeepSortPic(const cv::Mat& frame, const std::vector<DeepSortResult>& results, const std::string& filename)
{
    cv::Mat vis = frame.clone();

    for (const auto& r : results) {
        cv::rectangle(vis, r.box, cv::Scalar(0, 255, 0), 2);

        std::string label = r.class_name + " ID:" + std::to_string(r.track_id);
        cv::putText(vis, label, cv::Point(int(r.box.x), int(r.box.y) - 5),
            cv::FONT_HERSHEY_SIMPLEX, 0.6, cv::Scalar(0, 255, 0), 2);
    }

    if (!cv::imwrite(filename, vis)) {
        std::cerr << "Failed to save DeepSORT image to " << filename << std::endl;
    }
}

void DeepSortModel::get_detections(const cv::Rect_<float>& rect, float confidence, DETECTIONS& d)
{
    DETECTION_ROW tmpRow;
    tmpRow.tlwh << rect.x, rect.y, rect.width, rect.height;
    tmpRow.confidence = confidence;
    tmpRow.feature.setZero();
    d.push_back(tmpRow);
}

void DeepSortModel::postprocess(cv::Mat& frame, const std::vector<Object>& outs, DETECTIONS& d)
{
    for (const Object& obj : outs)
    {

        get_detections(obj.rect, obj.prob, d);
    }
}



void DeepSortModel::matchDeepSortResult(DeepSortResult& ds_result, std::vector<Object>& dets) {
    ds_result.score = 0.f; ds_result.class_id = -1;
    for (int i = 0; i < dets.size(); i++)
    { 
        if (dets[i].matched) 
            continue;  
        if (ds_result.box.x == dets[i].rect.x 
            && ds_result.box.y == dets[i].rect.y 
            && ds_result.box.area() == dets[i].rect.area()
            ) { 
            ds_result.class_id = dets[i].label;
            ds_result.score = dets[i].prob;
            dets[i].matched = true;
        } 
    } 
}



