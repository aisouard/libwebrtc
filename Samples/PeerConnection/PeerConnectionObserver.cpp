//
// Created by ax on 25/09/16.
//

#include <third_party/jsoncpp/source/include/json/writer.h>
#include "DataChannelObserver.h"
#include "PeerConnectionObserver.h"
#include "Console.h"

using webrtc::PeerConnectionInterface;
using webrtc::MediaStreamInterface;
using webrtc::DataChannelInterface;
using webrtc::IceCandidateInterface;

PeerConnectionObserver::PeerConnectionObserver(IPeer *peer):
    _peer(peer), _dataChannelObserver(NULL) {
}

void PeerConnectionObserver::OnSignalingChange(
    PeerConnectionInterface::SignalingState new_state) {
  Console::Print("[PeerConnectionObserver::OnSignalingChange] new signaling state: %d",
                 new_state);
}

void PeerConnectionObserver::OnAddStream(rtc::scoped_refptr<MediaStreamInterface> stream) {
  Console::Print("[PeerConnectionObserver::OnAddStream]");
}

void PeerConnectionObserver::OnRemoveStream(rtc::scoped_refptr<MediaStreamInterface> stream) {
  Console::Print("[PeerConnectionObserver::OnRemoveStream]");
}

void PeerConnectionObserver::OnDataChannel(
    rtc::scoped_refptr<DataChannelInterface> data_channel) {
  Console::Print("[PeerConnectionObserver::OnDataChannel] %s", data_channel->label().c_str());
  _dataChannelObserver = new DataChannelObserver(data_channel);
  data_channel->RegisterObserver(_dataChannelObserver);
  _peer->SetDataChannel(data_channel);
}

void PeerConnectionObserver::OnRenegotiationNeeded() {
}

void PeerConnectionObserver::OnIceConnectionChange(
    PeerConnectionInterface::IceConnectionState new_state) {
  if (new_state == PeerConnectionInterface::kIceConnectionCompleted) {
    Console::Print("Connected!");
  } else if (new_state > PeerConnectionInterface::kIceConnectionCompleted) {
    Console::Print("Disconnected.");
  }
}

void PeerConnectionObserver::OnIceGatheringChange(
    PeerConnectionInterface::IceGatheringState new_state) {
  if (new_state == PeerConnectionInterface::kIceGatheringGathering) {
    Console::Print("Gathering ICE candidates, please wait.");
    return;
  }

  if (new_state != PeerConnectionInterface::kIceGatheringComplete) {
    return;
  }

  Json::FastWriter writer;
  writer.write(_iceCandidates);

  Console::Print("Done, paste this array of ICE candidates once requested." \
                 "\n\n%s", writer.write(_iceCandidates).c_str());
}

void PeerConnectionObserver::OnIceCandidate(const IceCandidateInterface* candidate) {
  Json::Value jmessage;

  jmessage["sdpMid"] = candidate->sdp_mid();
  jmessage["sdpMLineIndex"] = candidate->sdp_mline_index();
  std::string sdp;
  if (!candidate->ToString(&sdp)) {
    Console::Print("[PeerConnectionObserver::OnIceCandidate] Failed to serialize candidate");
    return;
  }
  jmessage["candidate"] = sdp;
  _iceCandidates.append(jmessage);
}

void PeerConnectionObserver::OnIceCandidatesRemoved(
    const std::vector<cricket::Candidate>& candidates) {
  Console::Print("[PeerConnectionObserver::OnIceCandidatesRemoved]");

}

void PeerConnectionObserver::OnIceConnectionReceivingChange(bool receiving) {
}