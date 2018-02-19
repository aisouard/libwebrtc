/*
 * Copyright (c) 2017 Axel Isouard <axel@isouard.fr>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <webrtc/api/peerconnectioninterface.h>
#include <webrtc/base/ssladapter.h>
#include <webrtc/base/thread.h>

#ifdef WIN32
#include <webrtc/base/win32socketinit.h>
#include <webrtc/base/win32socketserver.h>
#include <Windows.h>
#endif

int main(int argc, char **argv) {
#ifdef WIN32
  rtc::EnsureWinsockInit();
  rtc::Win32SocketServer w32_ss;
  rtc::Win32Thread w32_thread(&w32_ss);
  rtc::ThreadManager::Instance()->SetCurrentThread(&w32_thread);
#endif

  rtc::InitializeSSL();
  rtc::InitRandom(rtc::Time());
  rtc::ThreadManager::Instance()->WrapCurrentThread();

  rtc::Thread *signalingThread = new rtc::Thread();
  rtc::Thread *workerThread = new rtc::Thread();

  signalingThread->SetName("signaling_thread", NULL);
  workerThread->SetName("worker_thread", NULL);

  if (!signalingThread->Start() || !workerThread->Start()) {
    return 1;
  }

  rtc::scoped_refptr<webrtc::PeerConnectionFactoryInterface> pcFactory =
      webrtc::CreatePeerConnectionFactory(signalingThread,
                                          workerThread,
                                          NULL, NULL, NULL);

  pcFactory = NULL;

  if (rtc::ThreadManager::Instance()->CurrentThread() == signalingThread) {
    rtc::ThreadManager::Instance()->SetCurrentThread(NULL);
  }

  signalingThread->Stop();
  workerThread->Stop();

  delete signalingThread;
  delete workerThread;

  rtc::CleanupSSL();
  return 0;
}
