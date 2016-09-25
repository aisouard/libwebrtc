//
// Created by ax on 25/09/16.
//

#include <csignal>
#include <cstdarg>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <fcntl.h>
#include <termios.h>
#include <unistd.h>
#include "UnixConsole.h"

static int ttyErase;
static int ttyEof;
static struct termios ttyTc;

static size_t cursor;
static std::string buffer;

bool Console::Init() {
  struct termios tc;
  const char* term = getenv("TERM");

  signal(SIGTTIN, SIG_IGN);
  signal(SIGTTOU, SIG_IGN);
  signal(SIGCONT, Console::Reset);
  fcntl(STDIN_FILENO, F_SETFL, fcntl(STDIN_FILENO, F_GETFL, 0) | O_NONBLOCK );

  if (!(isatty(STDIN_FILENO) &&
      !(term && (!strcmp(term, "raw") || !strcmp(term, "dumb"))))) {
    std::cerr << "Input is not a tty." << std::endl;
    return false;
  }

  tcgetattr (STDIN_FILENO, &ttyTc);
  ttyErase = ttyTc.c_cc[VERASE];
  ttyEof = ttyTc.c_cc[VEOF];

  tc = ttyTc;
  tc.c_lflag &= ~(ECHO | ICANON);
  tc.c_iflag &= ~(ISTRIP | INPCK);
  tc.c_cc[VMIN] = 1;
  tc.c_cc[VTIME] = 0;
  tcsetattr (STDIN_FILENO, TCSADRAIN, &tc);

  cursor = 0;
  buffer.clear();
  return true;
}

bool Console::Update(std::string &input) {
  char key;
  ssize_t avail = read(STDIN_FILENO, &key, 1);

  input.clear();
  if (avail == -1) {
    return true;
  }

  if (key == ttyEof) {
    return false;
  }

  if (((key == ttyErase) || (key == 127) || (key == 8)) && cursor > 0)
  {
    buffer.erase(--cursor, 1);
    Console::Back();
    return true;
  }

  if (key == '\n') {
    input = buffer;
    cursor = 0;
    buffer.clear();

    write(STDOUT_FILENO, &key, 1);
    key = '>';
    write(STDOUT_FILENO, &key, 1);
    key = ' ';
    write(STDOUT_FILENO, &key, 1);
    return true;
  }

  if (key < ' ') {
    return true;
  }

  cursor++;
  buffer.append(1, key);
  write(STDOUT_FILENO, &key, 1);
  return true;
}

void Console::Cleanup() {
  tcsetattr (STDIN_FILENO, TCSADRAIN, &ttyTc);
  fcntl(STDIN_FILENO, F_SETFL, fcntl(STDIN_FILENO, F_GETFL, 0) & ~O_NONBLOCK);
}

void Console::Reset(int num) {
  Console::Init();
}

void Console::Show() {
  char key;

  key = '>';
  write(STDOUT_FILENO, &key, 1);
  key = ' ';
  write(STDOUT_FILENO, &key, 1);


  for (size_t i = 0; i < cursor; i++) {
    key = buffer.at(i);
    write(STDOUT_FILENO, &key, 1);
  }
}

void Console::Hide() {
  for (int i = 0; i < cursor + 2; i++) {
    Console::Back();
  }
}

void Console::Print(const std::string &fmt, ...) {
  va_list argptr;
  char string[1024];

  if (!fmt.length()) {
    return;
  }

  va_start(argptr, fmt);
  vsnprintf(string, sizeof(string), fmt.c_str(), argptr);
  va_end(argptr);

  Console::Hide();
  std::cout << string << std::endl;
  Console::Show();
}

void Console::Back()
{
  char key;

  key = '\b';
  write(STDOUT_FILENO, &key, 1);
  key = ' ';
  write(STDOUT_FILENO, &key, 1);
  key = '\b';
  write(STDOUT_FILENO, &key, 1);
}