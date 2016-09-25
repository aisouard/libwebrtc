//
// Created by ax on 25/09/16.
//

#include <third_party/jsoncpp/source/include/json/writer.h>
#include "SetLocalSessionDescriptionObserver.h"
#include "UnixConsole.h"

SetLocalSessionDescriptionObserver::SetLocalSessionDescriptionObserver(
    webrtc::SessionDescriptionInterface* desc): _desc(desc) {
}

void SetLocalSessionDescriptionObserver::OnSuccess() {
  std::string sdp;

  _desc->ToString(&sdp);

  Json::FastWriter writer;
  Json::Value jmessage;
  jmessage["type"] = _desc->type();
  jmessage["sdp"] = sdp;

  Console::Print("Here is the SDP, paste it to the remote client and paste " \
                 "their answer here.\n\n%s", writer.write(jmessage).c_str());
}

void SetLocalSessionDescriptionObserver::OnFailure(const std::string& error) {
  Console::Print("[SetLocalSessionDescriptionObserver::OnFailure] %s",
                 error.c_str());
}