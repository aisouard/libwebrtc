//
// Created by ax on 25/09/16.
//

#ifndef LIBWEBRTC_UNIXCONSOLE_H
#define LIBWEBRTC_UNIXCONSOLE_H

class Console {
public:
  static bool Init();
  static bool Update(std::string &input);
  static void Cleanup();
  static void Reset(int num);
  static void Print(const std::string &line, ...);
  static void Show();
  static void Hide();
  static void Back();
};

#endif //LIBWEBRTC_UNIXCONSOLE_H
