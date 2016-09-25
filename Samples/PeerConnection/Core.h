//
// Created by ax on 24/09/16.
//

#ifndef LIBWEBRTC_CORE_H
#define LIBWEBRTC_CORE_H

#include "webrtc/api/peerconnectioninterface.h"
#include "webrtc/base/thread.h"

class Core {
public:
  static bool Init();
  static bool Update();
  static bool Cleanup();

  static rtc::Thread *GetSignalingThread();
  static rtc::Thread *GetWorkerThread();
  static webrtc::PeerConnectionFactoryInterface *GetPeerConnectionFactory();

private:
  static rtc::Thread *_signalingThread;
  static rtc::Thread *_workerThread;
  static webrtc::PeerConnectionFactoryInterface *_peerConnectionFactory;
};


#endif //LIBWEBRTC_CORE_H
