//
// Created by ax on 24/09/16.
//

#ifndef LIBWEBRTC_PEER_H
#define LIBWEBRTC_PEER_H

#include <third_party/jsoncpp/source/include/json/value.h>
#include "webrtc/api/test/fakeconstraints.h"
#include "webrtc/api/peerconnectioninterface.h"

class Peer : public webrtc::PeerConnectionObserver {
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
  void SendMessage(const std::string& message);

  /*
   * webrtc::PeerConnectionObserver methods
   */
  void OnSignalingChange(
      webrtc::PeerConnectionInterface::SignalingState new_state);

  void OnAddStream(rtc::scoped_refptr<webrtc::MediaStreamInterface> stream);
  void OnRemoveStream(rtc::scoped_refptr<webrtc::MediaStreamInterface> stream);

  void OnDataChannel(
      rtc::scoped_refptr<webrtc::DataChannelInterface> data_channel);

  void OnRenegotiationNeeded();

  void OnIceConnectionChange(
      webrtc::PeerConnectionInterface::IceConnectionState new_state);
  void OnIceGatheringChange(
      webrtc::PeerConnectionInterface::IceGatheringState new_state);

  void OnIceCandidate(const webrtc::IceCandidateInterface* candidate);
  void OnIceCandidatesRemoved(
      const std::vector<cricket::Candidate>& candidates);
  void OnIceConnectionReceivingChange(bool receiving);

private:
  rtc::scoped_refptr<webrtc::PeerConnectionInterface> _peerConnection;
  webrtc::FakeConstraints _mediaConstraints;
  rtc::scoped_refptr<webrtc::DataChannelInterface> _dataChannel;
  webrtc::DataChannelObserver *_dataChannelObserver;
  Json::Value _iceCandidates;
};

#endif //LIBWEBRTC_PEER_H
