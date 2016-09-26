//
// Created by ax on 25/09/16.
//

#ifndef LIBWEBRTC_SETREMOTESESSIONDESCRIPTIONOBSERVER_H
#define LIBWEBRTC_SETREMOTESESSIONDESCRIPTIONOBSERVER_H

#include <webrtc/api/jsep.h>
#include "IPeer.h"

class SetRemoteSessionDescriptionObserver:
    public webrtc::SetSessionDescriptionObserver {
public:
  SetRemoteSessionDescriptionObserver(IPeer *peer, webrtc::SessionDescriptionInterface* desc);

  void OnSuccess();
  void OnFailure(const std::string& error);

private:
  IPeer *_peer;
  webrtc::SessionDescriptionInterface* _desc;

protected:
  ~SetRemoteSessionDescriptionObserver() {}
};


#endif //LIBWEBRTC_SETREMOTESESSIONDESCRIPTIONOBSERVER_H
