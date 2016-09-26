//
// Created by ax on 25/09/16.
//

#ifndef LIBWEBRTC_PEERCONNECTIONOBSERVER_H
#define LIBWEBRTC_PEERCONNECTIONOBSERVER_H

#include <third_party/jsoncpp/source/include/json/value.h>
#include <webrtc/api/peerconnectioninterface.h>
#include "IPeer.h"

class PeerConnectionObserver: public webrtc::PeerConnectionObserver {
public:
  PeerConnectionObserver(IPeer *peer);

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
  IPeer *_peer;
  webrtc::DataChannelObserver *_dataChannelObserver;
  Json::Value _iceCandidates;
};


#endif //LIBWEBRTC_PEERCONNECTIONOBSERVER_H
