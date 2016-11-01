#include <iostream>
#include <cstdarg>
#include <Windows.h>
#include "Console.h"

#define MAX_EDIT_LINE 32768

static HANDLE hOUT;
static HANDLE hIN;

static DWORD dMode;
static WORD wAttrib;
static CONSOLE_CURSOR_INFO cursorInfo;

static size_t cursor;
static std::string buffer;

bool Console::Init() {
	CONSOLE_CURSOR_INFO curs;
	CONSOLE_SCREEN_BUFFER_INFO info;

	hIN = GetStdHandle(STD_INPUT_HANDLE);
	if (hIN == INVALID_HANDLE_VALUE) {
		return false;
  }

	hOUT = GetStdHandle(STD_OUTPUT_HANDLE);
	if (hOUT == INVALID_HANDLE_VALUE) {
		return false;
  }

	GetConsoleMode(hIN, &dMode);
	SetConsoleMode(hIN, dMode & ~ENABLE_MOUSE_INPUT);

	FlushConsoleInputBuffer(hIN);

	GetConsoleScreenBufferInfo(hOUT, &info);
	wAttrib = info.wAttributes;

	GetConsoleCursorInfo(hOUT, &cursorInfo);
  curs.dwSize = 1;
  curs.bVisible = FALSE;
	SetConsoleCursorInfo(hOUT, &curs);

  cursor = 0;
  buffer.clear();
  return true;
}

bool Console::Update(std::string &input) {
  INPUT_RECORD *buff;
  DWORD count;
  DWORD events;
  char key;
  int newline = -1;
  int i;

  input.clear();
  if (!GetNumberOfConsoleInputEvents(hIN, &events)) {
    return true;
  }

  if (events < 1) {
    return true;
  }

  buff = new INPUT_RECORD[events];
  if (!ReadConsoleInput(hIN, buff, events, &count)) {
    delete[] buff;
    return true;
  }

  if (count < 1) {
    delete[] buff;
    return true;
  }

  FlushConsoleInputBuffer(hIN);

  for (i = 0; i < count; i++) {
    if (buff[i].EventType != KEY_EVENT) {
      continue;
    }

    if (!buff[i].Event.KeyEvent.bKeyDown) {
      continue;
    }

    key = buff[i].Event.KeyEvent.wVirtualKeyCode;

    if (key == VK_RETURN) {
      newline = i;
      break;
    } else if (key == VK_BACK) {
      buffer.erase(--cursor, 1);
    }

    char c = buff[i].Event.KeyEvent.uChar.AsciiChar;

    if (c) {
      cursor++;
      buffer.append(1, c);
    }
  }

  delete[] buff;
  Console::Show();

  if (newline < 0) {
    return true;
  }
  newline = 0;

  if (!buffer.length())
  {
    std::cout << std::endl;
    return true;
  }

  std::cout << buffer.c_str() << std::endl;

  input = buffer;
  cursor = 0;
  buffer.clear();
  return true;
}

void Console::Cleanup() {
  SetConsoleMode(hIN, dMode);
  SetConsoleCursorInfo(hOUT, &cursorInfo);
  CloseHandle(hOUT);
  CloseHandle(hIN);
}

void Console::Reset(int num) {
  Console::Init();
}

void Console::Show() {
  int i;
  CONSOLE_SCREEN_BUFFER_INFO binfo;
  COORD writeSize = { MAX_EDIT_LINE, 1 };
  COORD writePos = { 0, 0 };
  SMALL_RECT writeArea = { 0, 0, 0, 0 };
  CHAR_INFO line[MAX_EDIT_LINE];

  GetConsoleScreenBufferInfo(hOUT, &binfo);

  if (binfo.dwCursorPosition.X != 0) {
    return;
  }

  writeArea.Left = 0;
  writeArea.Top = binfo.dwCursorPosition.Y;
  writeArea.Bottom = binfo.dwCursorPosition.Y;
  writeArea.Right = MAX_EDIT_LINE;

  for (i = 0; i < MAX_EDIT_LINE; i++) {
    if (i < buffer.length())
      line[i].Char.AsciiChar = buffer.at(i);
    else
      line[i].Char.AsciiChar = ' ';

    line[i].Attributes = wAttrib;
  }

  if (buffer.length() > binfo.srWindow.Right) {
    WriteConsoleOutput(hOUT, line + (buffer.length() - binfo.srWindow.Right),
      writeSize, writePos, &writeArea);
  } else {
    WriteConsoleOutput(hOUT, line, writeSize, writePos, &writeArea);
  }
}

void Console::Hide() {
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

  std::cout << string << std::endl;
  Console::Show();
}

void Console::Back() {
}