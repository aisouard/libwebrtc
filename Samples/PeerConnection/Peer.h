//
// Created by ax on 24/09/16.
//

#ifndef LIBWEBRTC_PEER_H
#define LIBWEBRTC_PEER_H

#include <third_party/jsoncpp/source/include/json/value.h>
#include "webrtc/api/test/fakeconstraints.h"
#include "webrtc/api/peerconnectioninterface.h"

#include "IPeer.h"

class Peer: public IPeer {
public:
  Peer();
  ~Peer();

  void CreateOffer(webrtc::CreateSessionDescriptionObserver *createSDPObserver);
  void CreateAnswer(webrtc::CreateSessionDescriptionObserver *createSDPObserver);

  bool AddIceCandidate(webrtc::IceCandidateInterface *candidate);

  void SetLocalSessionDescription(webrtc::SessionDescriptionInterface* desc,
                                  webrtc::SetSessionDescriptionObserver *setSDPObserver);
  void SetRemoteSessionDescription(webrtc::SessionDescriptionInterface* desc,
                                  webrtc::SetSessionDescriptionObserver *setSDPObserver);

  bool IsConnected();
  void SetDataChannel(webrtc::DataChannelInterface *dataChannel);
  void SendMessage(const std::string& message);

private:
  rtc::scoped_refptr<webrtc::PeerConnectionInterface> _peerConnection;
  webrtc::PeerConnectionObserver *_peerConnectionObserver;
  webrtc::FakeConstraints _mediaConstraints;
  rtc::scoped_refptr<webrtc::DataChannelInterface> _dataChannel;
  webrtc::DataChannelObserver *_dataChannelObserver;
};

#endif //LIBWEBRTC_PEER_H
