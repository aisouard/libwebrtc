//
// Created by ax on 25/09/16.
//

#include "DataChannelObserver.h"
#include "Console.h"


DataChannelObserver::DataChannelObserver(
    webrtc::DataChannelInterface *dataChannel): _dataChannel(dataChannel) {
}

void DataChannelObserver::OnStateChange() {
  Console::Print("[DataChannelObserver::OnStateChange] %s",
      webrtc::DataChannelInterface::DataStateString(_dataChannel->state()));
}

void DataChannelObserver::OnMessage(const webrtc::DataBuffer& buffer) {
  size_t len = buffer.size();
  const unsigned char *data = buffer.data.cdata();
  char *message = new char[len + 1];

  memcpy(message, data, len);
  message[len] = '\0';

  Console::Print("<Remote> %s", message);
  delete[] message;
}

void DataChannelObserver::OnBufferedAmountChange(uint64_t previous_amount) {
}
