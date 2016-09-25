#include <iostream>
#include <third_party/jsoncpp/source/include/json/reader.h>
#include "Core.h"
#include "CreateSessionObserver.h"
#include "DataChannelObserver.h"
#include "Peer.h"
#include "SetRemoteSessionDescriptionObserver.h"
#include "UnixConsole.h"

enum {
  STATE_EXCHANGE = 0,
  STATE_CHAT
};

static Peer *peer = NULL;
static int state = STATE_EXCHANGE;

void HandleSDP(Json::Value object) {
  std::string type = object["type"].asString();
  std::string sdp = object["sdp"].asString();

  webrtc::SdpParseError error;
  webrtc::SessionDescriptionInterface* desc(
      webrtc::CreateSessionDescription(type, sdp, &error));

  if (!desc) {
    Console::Print("Can't parse the SDP: %s", error.description);
    return;
  }

  rtc::scoped_refptr<SetRemoteSessionDescriptionObserver> observer =
      new rtc::RefCountedObject<SetRemoteSessionDescriptionObserver>(peer, desc);

  peer->SetRemoteSessionDescription(desc, observer);
}

void HandleICECandidate(Json::Value object) {
  std::string sdp_mid = object["sdpMid"].asString();
  int sdp_mlineindex = object["sdpMLineIndex"].asInt();
  std::string sdp = object["candidate"].asString();

  webrtc::SdpParseError error;
  std::unique_ptr<webrtc::IceCandidateInterface> candidate(
      webrtc::CreateIceCandidate(sdp_mid, sdp_mlineindex, sdp, &error));

  if (!candidate.get()) {
    Console::Print("Can't parse the ICE candidate: %s", error.description);
    return;
  }

  if (!peer->AddIceCandidate(candidate.get())) {
    Console::Print("Failed to add the ICE candidate.");
    return;
  }
}

void HandleObject(Json::Value object) {
  if (object.isMember("type") && object["type"].isString() &&
      object.isMember("sdp") && object["sdp"].isString()) {
    HandleSDP(object);
    return;
  }

  if (object.isMember("candidate") && object["candidate"].isString() &&
      object.isMember("sdpMLineIndex") && object["sdpMLineIndex"].isNumeric() &&
      object.isMember("sdpMid") && object["sdpMid"].isString()) {
    HandleICECandidate(object);
    return;
  }

  Console::Print("Unknown object.");
}

void HandleCommand(const std::string& input) {
  Json::Reader reader;
  Json::Value jmessage;

  if (peer->IsConnected()) {
    peer->SendMessage(input);
    return;
  }

  if (!reader.parse(input, jmessage)) {
    Console::Print("Invalid JSON string.");
    return;
  }

  if (jmessage.isArray()) {
    for (Json::ValueIterator it = jmessage.begin();
         it != jmessage.end(); it++) {
      if (!(*it).isObject()) {
        continue;
      }

      HandleObject(*it);
    }
    return;
  }

  if (jmessage.isObject()) {
    HandleObject(jmessage);
    return;
  }

  Console::Print("Must be an array or object.");
}

int main(int argc, char **argv) {
  std::string input;

  if (!Console::Init()) {
    return EXIT_FAILURE;
  }

  Core::Init();

  peer = new Peer();

  if (argc == 1) {
    rtc::scoped_refptr<CreateSessionObserver> createOfferObserver =
        new rtc::RefCountedObject<CreateSessionObserver>(peer);

    peer->CreateOffer(createOfferObserver);
  } else {
    Console::Print("Recipient mode. Paste the offer made by the emitter.\n");
  }

  while (Console::Update(input)) {
    if (input.length()) {
      HandleCommand(input);
    }
    Core::Update();
  }

  delete peer;

  Core::Cleanup();
  Console::Cleanup();
  return EXIT_SUCCESS;
}