Howto compile Rtmpdump for Android

1) Get the Android ndk (http://developer.android.com/tools/sdk/ndk/index.html) and follow the instructions here (PATH_TO_NDK_INSTALL/../android-ndk-r7/docs/STANDALONE-TOOLCHAIN.html) to create a standalone android toolchain.

2) Download and install Mingw (http://sourceforge.net/projects/mingw/files/MinGW/).

3) Download PolarSSL source from (https://polarssl.org/download) and unzip it to your mingw/msys home directorys.  For me this was C:\MinGW\msys\1.0\home\S74ck3r.  Current builds are made with PolarSSL 1.2.0

If you're going to build with PolarSSL 1.2.0 you will need to download an additional header from (http://nuicode.com/projects/ccv-multi/repository/revisions/129/entry/branches/test/videoInput_GUID/videoInputSrcAndDemos/libs/DShow/Include/strsafe.h?format=raw) and copy it to your
mingw/include folder because it's not included in Mingw.


4) Open Mingw shell, add the path to the standalone android toolchain binaries to the path.  On my system I did this, but it will depend on where you installed
the toolchain.

'export PATH=/c/tmp/android-toolchain/bin:$PATH'

5) CD to the unzipped PolarSSL directory and type;

'make CC=arm-linux-androideabi-gcc APPS='
'make install DESTDIR=/c/tmp/android-toolchain/sysroot'

(Obviously change the install destination directory if your toolchain is in a different location)

6) Get the Rtmpdump source.  The following commands assume you have retrieved it from my repository (https://github.com/S74ck3r/rtmpdump.git). 
You can obviously get the source directly from the official repository.  There is no difference in the actual code (i.e. no added patches or additional functionality)
but I have added a target for android to the makefiles for convenience. 

7) CD to the Rtmpdump source directory and type;

-- Shared library version
'make SYS=android CROSS_COMPILE=arm-linux-androideabi- INC="-I/c/tmp/android-toolchain/sysroot/include" CRYPTO=POLARSSL'
-- Static version
'make SYS=android CROSS_COMPILE=arm-linux-androideabi- INC="-I/c/tmp/android-toolchain/sysroot/include" CRYPTO=POLARSSL SHARED='

(Obviously change this if your toolchain is in a different location, make sure the include path is correct)


8) Done.