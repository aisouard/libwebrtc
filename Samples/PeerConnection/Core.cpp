//
// Created by ax on 24/09/16.
//

#include "webrtc/base/ssladapter.h"
#include "Core.h"

rtc::Thread *Core::_signalingThread = NULL;
rtc::Thread *Core::_workerThread = NULL;
webrtc::PeerConnectionFactoryInterface *Core::_peerConnectionFactory = NULL;

bool Core::Init() {
  rtc::InitializeSSL();
  rtc::InitRandom(rtc::Time());
  rtc::ThreadManager::Instance()->WrapCurrentThread();

  _signalingThread = new rtc::Thread();
  _workerThread = new rtc::Thread();

  _signalingThread->SetName("signaling_thread", NULL);
  _workerThread->SetName("worker_thread", NULL);

  if (!_signalingThread->Start() || !_workerThread->Start()) {
    return false;
  }

  _peerConnectionFactory =
      webrtc::CreatePeerConnectionFactory(_signalingThread,
                                          _workerThread,
                                          NULL, NULL, NULL).release();

  return true;
}

bool Core::Update() {
  return rtc::Thread::Current()->ProcessMessages(0);
}

bool Core::Cleanup() {
  _peerConnectionFactory->Release();
  _peerConnectionFactory = NULL;

  _signalingThread->Stop();
  _workerThread->Stop();

  delete _signalingThread;
  delete _workerThread;

  _signalingThread = NULL;
  _workerThread = NULL;

  return rtc::CleanupSSL();
}

rtc::Thread *Core::GetSignalingThread() {
  return _signalingThread;
}

rtc::Thread *Core::GetWorkerThread() {
  return _workerThread;
}

webrtc::PeerConnectionFactoryInterface *Core::GetPeerConnectionFactory() {
  return _peerConnectionFactory;
}











