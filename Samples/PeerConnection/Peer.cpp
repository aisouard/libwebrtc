//
// Created by ax on 24/09/16.
//

#include <iostream>
#include <third_party/jsoncpp/source/include/json/writer.h>
#include "Peer.h"
#include "Core.h"
#include "UnixConsole.h"
#include "DataChannelObserver.h"

using webrtc::PeerConnectionInterface;
using webrtc::MediaConstraintsInterface;
using webrtc::DataChannelInit;
using webrtc::MediaStreamInterface;
using webrtc::DataChannelInterface;
using webrtc::IceCandidateInterface;
using webrtc::SessionDescriptionInterface;

Peer::Peer() {
  PeerConnectionInterface::RTCConfiguration config;
  PeerConnectionInterface::IceServer googleIceServer;

  googleIceServer.uri = "stun:stun.l.google.com:19302";
  googleIceServer.urls.push_back("stun:stun.l.google.com:19302");
  googleIceServer.urls.push_back("stun:stun1.l.google.com:19302");
  googleIceServer.urls.push_back("stun:stun2.l.google.com:19302");
  googleIceServer.urls.push_back("stun:stun3.l.google.com:19302");
  googleIceServer.urls.push_back("stun:stun4.l.google.com:19302");

  config.servers.push_back(googleIceServer);

  _dataChannel = NULL;
  _dataChannelObserver = NULL;
  _peerConnection = Core::GetPeerConnectionFactory()->
      CreatePeerConnection(config, &_mediaConstraints,
                           NULL, NULL, this);

  _mediaConstraints.AddOptional(
      MediaConstraintsInterface::kEnableDtlsSrtp,
      MediaConstraintsInterface::kValueTrue);

  _mediaConstraints.AddMandatory(
      MediaConstraintsInterface::kOfferToReceiveAudio,
      MediaConstraintsInterface::kValueFalse);

  _mediaConstraints.AddMandatory(
      MediaConstraintsInterface::kOfferToReceiveVideo,
      MediaConstraintsInterface::kValueFalse);
}

Peer::~Peer() {
  if (_dataChannel) {
    _dataChannel->Close();
    _dataChannel = NULL;
  }

  _peerConnection->Close();
  _peerConnection = NULL;

  if (_dataChannelObserver) {
    _dataChannelObserver = NULL;
  }
}

void Peer::CreateOffer(webrtc::CreateSessionDescriptionObserver *createSDPObserver) {
  DataChannelInit init;

  init.reliable = true;
  _dataChannel = _peerConnection->CreateDataChannel("MyDataChannel", &init);
  _dataChannelObserver = new DataChannelObserver(_dataChannel);
  _dataChannel->RegisterObserver(_dataChannelObserver);

  _peerConnection->CreateOffer(createSDPObserver, &_mediaConstraints);
}

void Peer::CreateAnswer(webrtc::CreateSessionDescriptionObserver *createSDPObserver) {
  _peerConnection->CreateAnswer(createSDPObserver, &_mediaConstraints);
}

bool Peer::AddIceCandidate(webrtc::IceCandidateInterface *candidate) {
  return _peerConnection->AddIceCandidate(candidate);
}

void Peer::SetLocalSessionDescription(SessionDescriptionInterface* desc,
                                      webrtc::SetSessionDescriptionObserver *obs) {
  _peerConnection->SetLocalDescription(obs, desc);
}

void Peer::SetRemoteSessionDescription(SessionDescriptionInterface* desc,
                                       webrtc::SetSessionDescriptionObserver *obs) {
  _peerConnection->SetRemoteDescription(obs, desc);
}

bool Peer::IsConnected() {
  if (!_dataChannel) {
    return false;
  }

  return _dataChannel->state() == webrtc::DataChannelInterface::kOpen;
}

void Peer::SendMessage(const std::string& message) {
  webrtc::DataBuffer buffer(message);

  _dataChannel->Send(buffer);
}

/*
 * webrtc::PeerConnectionObserver methods
 */
void Peer::OnSignalingChange(
    PeerConnectionInterface::SignalingState new_state) {
  Console::Print("[Peer::OnSignalingChange] new signaling state: %d",
                 new_state);
}

void Peer::OnAddStream(rtc::scoped_refptr<MediaStreamInterface> stream) {
  Console::Print("[Peer::OnAddStream]");
}

void Peer::OnRemoveStream(rtc::scoped_refptr<MediaStreamInterface> stream) {
  Console::Print("[Peer::OnRemoveStream]");
}

void Peer::OnDataChannel(
    rtc::scoped_refptr<DataChannelInterface> data_channel) {
  Console::Print("[Peer::OnDataChannel] %s", data_channel->label().c_str());
  _dataChannel = data_channel;

  _dataChannelObserver = new DataChannelObserver(_dataChannel);
  _dataChannel->RegisterObserver(_dataChannelObserver);
}

void Peer::OnRenegotiationNeeded() {
}

void Peer::OnIceConnectionChange(
    PeerConnectionInterface::IceConnectionState new_state) {
  if (new_state == PeerConnectionInterface::kIceConnectionCompleted) {
    Console::Print("Connected!");
  } else if (new_state > PeerConnectionInterface::kIceConnectionCompleted) {
    Console::Print("Disconnected.");
  }
}

void Peer::OnIceGatheringChange(
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

void Peer::OnIceCandidate(const IceCandidateInterface* candidate) {
  Json::Value jmessage;

  jmessage["sdpMid"] = candidate->sdp_mid();
  jmessage["sdpMLineIndex"] = candidate->sdp_mline_index();
  std::string sdp;
  if (!candidate->ToString(&sdp)) {
    Console::Print("[Peer::OnIceCandidate] Failed to serialize candidate");
    return;
  }
  jmessage["candidate"] = sdp;
  _iceCandidates.append(jmessage);
}

void Peer::OnIceCandidatesRemoved(
    const std::vector<cricket::Candidate>& candidates) {
  Console::Print("[Peer::OnIceCandidatesRemoved]");

}

void Peer::OnIceConnectionReceivingChange(bool receiving) {
}