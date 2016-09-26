//
// Created by ax on 25/09/16.
//

#ifndef LIBWEBRTC_CREATEOFFEROBSERVER_H
#define LIBWEBRTC_CREATEOFFEROBSERVER_H

#include <webrtc/api/jsep.h>
#include "IPeer.h"

class CreateSessionObserver: public webrtc::CreateSessionDescriptionObserver {
public:
  CreateSessionObserver(IPeer *peer);

  void OnSuccess(webrtc::SessionDescriptionInterface* desc);
  void OnFailure(const std::string& error);

private:
  IPeer *_peer;

protected:
  ~CreateSessionObserver() {}
};


#endif //LIBWEBRTC_CREATEOFFEROBSERVER_H
