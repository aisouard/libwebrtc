//
// Created by ax on 25/09/16.
//

#ifndef LIBWEBRTC_SETLOCALSESSIONDESCRIPTIONOBSERVER_H
#define LIBWEBRTC_SETLOCALSESSIONDESCRIPTIONOBSERVER_H


#include <webrtc/api/jsep.h>

class SetLocalSessionDescriptionObserver:
    public webrtc::SetSessionDescriptionObserver {
public:
  SetLocalSessionDescriptionObserver(webrtc::SessionDescriptionInterface* desc);

  void OnSuccess();
  void OnFailure(const std::string& error);

private:
  webrtc::SessionDescriptionInterface* _desc;

protected:
  ~SetLocalSessionDescriptionObserver() {}
};


#endif //LIBWEBRTC_SETLOCALSESSIONDESCRIPTIONOBSERVER_H
