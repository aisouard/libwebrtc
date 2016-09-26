//
// Created by ax on 24/09/16.
//

#include <iostream>
#include <third_party/jsoncpp/source/include/json/writer.h>

#include "Core.h"
#include "DataChannelObserver.h"
#include "Peer.h"
#include "PeerConnectionObserver.h"

using webrtc::DataChannelInit;
using webrtc::PeerConnectionInterface;
using webrtc::MediaConstraintsInterface;
using webrtc::SessionDescriptionInterface;

using webrtc::MediaStreamInterface;
using webrtc::DataChannelInterface;
using webrtc::IceCandidateInterface;

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
  _peerConnectionObserver = new PeerConnectionObserver(this);
  _peerConnection = Core::GetPeerConnectionFactory()->
      CreatePeerConnection(config, &_mediaConstraints,
                           NULL, NULL, _peerConnectionObserver);

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
    _dataChannel->UnregisterObserver();
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

void Peer::SetDataChannel(webrtc::DataChannelInterface *dataChannel) {
  _dataChannel = dataChannel;
}

void Peer::SendMessage(const std::string& message) {
  webrtc::DataBuffer buffer(message);

  _dataChannel->Send(buffer);
}