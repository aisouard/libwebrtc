//
// Created by ax on 26/09/16.
//

#ifndef LIBWEBRTC_IPEER_H
#define LIBWEBRTC_IPEER_H

#include "webrtc/api/peerconnectioninterface.h"

class IPeer {
public:
  virtual void CreateOffer(webrtc::CreateSessionDescriptionObserver *createSDPObserver) = 0;
  virtual void CreateAnswer(webrtc::CreateSessionDescriptionObserver *createSDPObserver) = 0;

  virtual bool AddIceCandidate(webrtc::IceCandidateInterface *candidate) = 0;

  virtual void SetLocalSessionDescription(webrtc::SessionDescriptionInterface* desc,
                                  webrtc::SetSessionDescriptionObserver *setSDPObserver) = 0;
  virtual void SetRemoteSessionDescription(webrtc::SessionDescriptionInterface* desc,
                                   webrtc::SetSessionDescriptionObserver *setSDPObserver) = 0;

  virtual bool IsConnected() = 0;
  virtual void SetDataChannel(webrtc::DataChannelInterface *dataChannel) = 0;
  virtual void SendMessage(const std::string& message) = 0;
};

#endif //LIBWEBRTC_IPEER_H
