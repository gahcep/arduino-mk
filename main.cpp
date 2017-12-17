#include <Arduino.h>

#ifdef USE_LIBRARY_WIRE
#include <Wire.h>
#endif

#ifdef USE_LIBRARY_SPI
#include <SPI.h>
#endif

// Declared weak in Arduino.h to allow user redefinitions.
int atexit(void (* /*func*/ )()) { return 0; }

// Weak empty variant initialization function.
// May be redefined by variant files.
void initVariant() __attribute__((weak));
void initVariant() { }

void setupUSB() __attribute__((weak));
void setupUSB() { }

int main(void)
{
	init();

	initVariant();

	#if defined(USBCON)
	USBDevice.attach();
	#endif

#if 0

	//
	// Your code goes here
	//

#endif

    if (serialEventRun) serialEventRun();

    return 0;
}
