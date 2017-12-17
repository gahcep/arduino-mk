## Build Arduino-based libraries without IDE

This repository contains all required infrastructure to allow you to build your Arduino projects without actually having an IDE nearby.

You are free to forget about \*.ino files and Arduino IDE, just setup the toolchain, use `main.cpp` as a skeleton and you are free to go.

**NOTE:** only Arduino Nano board were tested (I only have this guy). But the base Makefile should work for any Arduino-based libraries.

#### AVR Toolchain 

In order to be able to **compile** under GCC and upload firmware files you need:

  * `avr-binutils`
  * `avr-gcc`
  * `avr-libc`
  * `avr-dude`

Our installation directory will be **`/usr/local/avr/`** and OS is **`Fedora`**.

**Linux (Fedora) Prerequisites**

```bash
sudo dnf install gmp gmp-devel mpfr mpfr-devel libmpc libmpc-devel flex
```

**avr-binutils**

```bash
wget https://ftp.gnu.org/gnu/binutils/binutils-2.29.tar.bz2
tar -xvjf binutils-2.29.tar.bz2
cd binutils-2.29
mkdir build && cd build
../configure --prefix=/usr/local/avr/ --target=avr --disable-nls
make -j8
sudo make install
```

**avr-gcc**

```bash
wget http://ftpmirror.gnu.org/gcc/gcc-7.1.0/gcc-7.1.0.tar.bz2
tar -xvjf gcc-7.1.0.tar.bz2
cd gcc-7.1.0
mkdir build && cd build
../configure --prefix=/usr/local/avr/ --target=avr --enable-languages=c,c++ --disable-nls --disable-libssp --with-dwarf2  
make -j8
sudo make install
```

**avr-libc**

```bash
wget https://download.savannah.gnu.org/releases/avr-libc/avr-libc-2.0.0.tar.bz2
tar -xvjf avr-libc-2.0.0.tar.bz2
cd avr-libc-2.0.0
mkdir build && cd build
../configure --prefix=/usr/local/avr/ --build=`../config.guess` --host=avr
make -j8
# Note: because `install` target that runs `/bin/sh` can't find `avr-ranlib` no matter what
# (expanding PATH doesn't work), we do `make install` from root
su -h
cd PATH_TO_AVR_LIBC
sudo make install
```

**avr-dude**

```bash
# Note: make sure only flex is installed: no bison/bison-devel is installed
wget https://download.savannah.gnu.org/releases/avrdude/avrdude-6.3.tar.gz
gunzip -c avrdude-6.3.tar.gz | tar xf -
cd avrdude-6.3
mkdir build && cd build
../configure --prefix=/usr/local/avr/
make -j8
sudo make install
```

#### Using Makefile

You can run `make help` in order to get all the information about possible targets and avalable options to change.

In general the flow is as follows (assuming you want to compile with Wire default Arduino library and immediately after upload to the board):

1. Update `main.cpp` file - put your logic in there.

2. Compile project
```bash
make BAUD=57600 PORT=/dev/ttyS0 BRD=AVR_NANO WITH_WIRE=1 all
```

3. Upload the binary to the board
```bash
make upload
```

#### Feedback and Support

Fell free to send me emails, push requests. Also, create issues for missing things. 