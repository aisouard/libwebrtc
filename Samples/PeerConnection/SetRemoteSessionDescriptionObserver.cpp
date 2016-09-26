//
// Created by ax on 25/09/16.
//

#include "SetRemoteSessionDescriptionObserver.h"
#include "CreateSessionObserver.h"
#include "Console.h"


SetRemoteSessionDescriptionObserver::SetRemoteSessionDescriptionObserver(
    Peer *peer, webrtc::SessionDescriptionInterface* desc):
    _peer(peer), _desc(desc) {
}

void SetRemoteSessionDescriptionObserver::OnSuccess() {
  if (_desc->type() == webrtc::SessionDescriptionInterface::kOffer) {
    rtc::scoped_refptr<CreateSessionObserver> createAnswerObserver =
        new rtc::RefCountedObject<CreateSessionObserver>(_peer);

    _peer->CreateAnswer(createAnswerObserver);
  }
}

void SetRemoteSessionDescriptionObserver::OnFailure(const std::string& error) {
  Console::Print("[SetRemoteSessionDescriptionObserver::OnFailure] %s",
                 error.c_str());
}
