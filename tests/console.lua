local ffi = require 'ffi'

local kernel32_h = [[
typedef unsigned long HANDLE;
typedef unsigned long DWORD;
typedef unsigned short WORD;
typedef short SHORT;
typedef bool BOOL;

typedef struct {
	short X;
	short Y;
} COORD;

HANDLE GetStdHandle(DWORD nStdHandle);
BOOL SetConsoleCursorPosition(HANDLE hConsoleOutput, COORD dwCursorPosition);

BOOL WriteConsoleOutputCharacterA(
	HANDLE hConsoleOutput,
	char * lpCharacter,
	DWORD nLength,
	COORD dwWriteCoord,
	DWORD * lpNumberOfCharsWritten
);
BOOL WriteConsoleOutputAttribute(
	HANDLE hConsoleOutput,
	const WORD *lpAttribute,
	DWORD nLength,
	COORD dwWriteCoord,
	DWORD * lpNumberOfAttrsWritten
);

DWORD GetLastError(void);

static const int STD_INPUT_HANDLE    = ((DWORD)-10);
static const int STD_OUTPUT_HANDLE   = ((DWORD)-11);
static const int STD_ERROR_HANDLE    = ((DWORD)-12);
]]

ffi.cdef(kernel32_h)
local kernel32 = ffi.load('kernel32.dll')

local STD_INPUT_HANDLE = kernel32.STD_INPUT_HANDLE
local STD_OUTPUT_HANDLE = kernel32.STD_OUTPUT_HANDLE
local STD_ERROR_HANDLE = kernel32.STD_ERROR_HANDLE

local M = {
	prepare = function()
		local handle = kernel32.GetStdHandle(STD_OUTPUT_HANDLE)

		local out = {
			setPosition = function(x, y)
				local position = ffi.new('COORD', {x or 0, y or 0})
				kernel32.SetConsoleCursorPosition(handle, position)
			end,
			write = function(x, y, char, attr)
				local position = ffi.new('COORD', {x or 0, y or 0})
				local numWritten = ffi.new('DWORD[1]', 0)

				local character = ffi.new('char[1]', string.byte(char, 1, 1) or 0)
				local attribute = ffi.new('WORD[1]', attr or 0)

				assert(kernel32.WriteConsoleOutputAttribute(handle, attribute, 1, position, numWritten) == true)
				assert(kernel32.WriteConsoleOutputCharacterA(handle, character, 1, position, numWritten) == true)
			end,
			getLastError = function()
				return kernel32.GetLastError()
			end,
		}
		return out
	end,
}

return M

