//
// Created by ax on 25/09/16.
//

#include "CreateSessionObserver.h"
#include "Console.h"
#include "SetLocalSessionDescriptionObserver.h"

using namespace webrtc;

CreateSessionObserver::CreateSessionObserver(IPeer *peer): _peer(peer) {
}

void CreateSessionObserver::OnSuccess(SessionDescriptionInterface* desc) {
  rtc::scoped_refptr<SetLocalSessionDescriptionObserver> observer =
      new rtc::RefCountedObject<SetLocalSessionDescriptionObserver>(desc);

  _peer->SetLocalSessionDescription(desc, observer);
}

void CreateSessionObserver::OnFailure(const std::string& error) {
  Console::Print("[CreateSessionObserver::OnFailure] %s", error.c_str());
}