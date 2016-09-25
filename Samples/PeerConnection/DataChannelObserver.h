//
// Created by ax on 25/09/16.
//

#ifndef LIBWEBRTC_DATACHANNELOBSERVER_H
#define LIBWEBRTC_DATACHANNELOBSERVER_H

#include <webrtc/api/datachannelinterface.h>

class DataChannelObserver: public webrtc::DataChannelObserver {
public:
  DataChannelObserver(webrtc::DataChannelInterface *dataChannel);

  void OnStateChange();
  void OnMessage(const webrtc::DataBuffer& buffer);
  void OnBufferedAmountChange(uint64_t previous_amount);

private:
  webrtc::DataChannelInterface *_dataChannel;
};

#endif //LIBWEBRTC_DATACHANNELOBSERVER_H
