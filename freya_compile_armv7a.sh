#!/bin/bash

CURRENT_PATH=/home/freya
#本脚本所在的目录位置
NDKROOT_PATH=/home/freya/android-ndk-r13
#NDK所在目录

FFMPEG_RTMP_OPTIONS="--enable-protocol=librtmp --enable-protocol=librtmpe --enable-protocol=librtmps --enable-protocol=librtmpt --enable-protocol=librtmpte --enable-librtmp"
#FFMPEG的可选编译参数 用于选择RTMP推流使用的库 默认使用LIBRTMP并支持RTMP RTMPT RTMPE RTMPTE RTMPS协议
#RTMP推流库选择参数:
#要使用LIBRTMP(支持RTMP RTMPT RTMPE RTMPTE RTMPS协议)需要加参数 --enable-protocol=librtmp --enable-protocol=librtmpe --enable-protocol=librtmps --enable-protocol=librtmpt --enable-protocol=librtmpte --enable-librtmp
#要使用FFMPEG NATIVE RTMP(仅支持RTMP协议)需要加参数 --enable-protocol=rtmp
#LIBRTMP与FFMPEG NATIVE RTMP只能选择其中一种 同时加两种参数时会使用LIBRTMP 建议按需要选择

PREBUILT_TOOL_ARMV7A_PATH=$NDKROOT_PATH/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi
#对应ARMV7-A的TOOLCHAIN目录 需要配置到TOOLCHAIN程序文件名共有的前半段
PLATFORM_ARMV7A_PATH=$NDKROOT_PATH/platforms/android-15/arch-arm
#对应ARMV7-A的ANDROID平台目录
PLATFORM_ARMV7A_API=android-15
#对应ARMV7-A的ANDROID API
PLATFORM_NDK_TOOLCHAIN_VERSION=4.9
#对应ARMV7-A的TOOLCHAIN版本

##########################################################配置项到此结束##########################################################


#预处理开始
trap "" INT
export PATH=$PATH:$NDKROOT_PATH
cd $CURRENT_PATH/ffmpeg
sed "s%&& require_pkg_config librtmp librtmp/rtmp.h RTMP_Socket%%" ./configure > ./configure.fix
rm -rf ./configure
mv ./configure.fix ./configure
cd $CURRENT_PATH
chmod -R 777 *
tar -cvf codec_temp.tar ./fdkaac ./ffmpeg ./libyuv ./polarssl ./rtmpdump ./x264
chmod -R 777 ./codec_temp.tar
#打包修正后的源码 在每次编译完成后清除源码并重新解包 避免在不同平台库连续编译时由于临时文件未清除而导致的一些问题
#预处理结束


#编译ARMV7-A库文件开始

#建立临时目录开始
mkdir -p $CURRENT_PATH/temp/armeabi-v7a/include/fdk-aac
mkdir -p $CURRENT_PATH/temp/armeabi-v7a/lib
#建立临时目录结束

#X264编译开始
cd $CURRENT_PATH/x264
./configure --host=arm-linux --enable-pic --enable-static --cross-prefix=$PREBUILT_TOOL_ARMV7A_PATH- --extra-cflags="-fPIC -marm -DX264_VERSION -DANDROID -DHAVE_PTHREAD -DNDEBUG -static -D__ARM_ARCH_7__ -D__ARM_ARCH_7A__ -O3 -march=armv7-a -mfpu=neon -mtune=generic-armv7-a -mfloat-abi=softfp -ftree-vectorize -mvectorize-with-neon-quad -ffast-math" --prefix=$CURRENT_PATH/temp/armeabi-v7a --sysroot=$PLATFORM_ARMV7A_PATH
make install
#X264编译结束

#FDKAAC编译开始
cd $CURRENT_PATH/fdkaac
find $CURRENT_PATH/fdkaac -name "*.h" -type f -exec \cp {} $CURRENT_PATH/temp/armeabi-v7a/include/fdk-aac \;
rm -rf $CURRENT_PATH/fdkaac/Android.mk
rm -rf $CURRENT_PATH/fdkaac/Application.mk
cp $CURRENT_PATH/optimizer/fdkaac/armeabi-v7a/Android.mk $CURRENT_PATH/fdkaac/Android.mk
echo "APP_PLATFORM := $PLATFORM_ARMV7A_API" >> $CURRENT_PATH/fdkaac/Application.mk
echo "APP_OPTIM := release" >> $CURRENT_PATH/fdkaac/Application.mk
echo "APP_ABI := armeabi-v7a" >> $CURRENT_PATH/fdkaac/Application.mk
echo "NDK_TOOLCHAIN_VERSION := $PLATFORM_NDK_TOOLCHAIN_VERSION" >> $CURRENT_PATH/fdkaac/Application.mk
ndk-build APP_BUILD_SCRIPT=$CURRENT_PATH/fdkaac/Android.mk NDK_APPLICATION_MK=$CURRENT_PATH/fdkaac/Application.mk NDK_PROJECT_PATH=$CURRENT_PATH/fdkaac/
cp $CURRENT_PATH/fdkaac/obj/local/armeabi-v7a/libfdk-aac.a $CURRENT_PATH/temp/armeabi-v7a/lib/libfdk-aac.a
#FDKAAC编译结束

#POLARSSL编译开始
cd $CURRENT_PATH/polarssl
rm -rf $CURRENT_PATH/polarssl/include/polarssl/config.h
rm -rf $PLATFORM_ARMV7A_PATH/usr/include/polarssl
rm -rf $PLATFORM_ARMV7A_PATH/usr/lib/libpolarssl.a
mkdir -p $PLATFORM_ARMV7A_PATH/usr/include/polarssl
cp $CURRENT_PATH/optimizer/polarssl/armeabi-v7a/config.h $CURRENT_PATH/polarssl/include/polarssl/config.h
make CC="$PREBUILT_TOOL_ARMV7A_PATH-gcc -fPIC -marm -DANDROID -DNDEBUG -static -O3 -march=armv7-a -mfpu=neon -mtune=generic-armv7-a -mfloat-abi=softfp -ftree-vectorize -mvectorize-with-neon-quad -ffast-math --sysroot=$PLATFORM_ARMV7A_PATH" APPS=
make install DESTDIR="$CURRENT_PATH/temp/armeabi-v7a" CC="$PREBUILT_TOOL_ARMV7A_PATH-gcc -fPIC -marm -DANDROID -DNDEBUG -static -O3 -march=armv7-a -mfpu=neon -mtune=generic-armv7-a -mfloat-abi=softfp -ftree-vectorize -mvectorize-with-neon-quad -ffast-math --sysroot=$PLATFORM_ARMV7A_PATH" APPS=
#POLARSSL编译结束

#LIBRTMP编译开始
cd $CURRENT_PATH/rtmpdump
rm -rf $CURRENT_PATH/rtmpdump/Makefile
rm -rf $CURRENT_PATH/rtmpdump/librtmp/Makefile
mkdir -p $CURRENT_PATH/temp/armeabi-v7a/include/librtmp
cp $CURRENT_PATH/optimizer/rtmpdump/armeabi-v7a/Makefile $CURRENT_PATH/rtmpdump/Makefile
cp $CURRENT_PATH/optimizer/rtmpdump/armeabi-v7a/librtmp/Makefile $CURRENT_PATH/rtmpdump/librtmp/Makefile
cp -R $CURRENT_PATH/temp/armeabi-v7a/include/polarssl $PLATFORM_ARMV7A_PATH/usr/include/
cp -R $CURRENT_PATH/temp/armeabi-v7a/lib/libpolarssl.a $PLATFORM_ARMV7A_PATH/usr/lib/libpolarssl.a
make SYS=android CROSS_COMPILE=arm-linux-androideabi- INC="-I$CURRENT_PATH/temp/armeabi-v7a/include -L$CURRENT_PATH/temp/armeabi-v7a/lib" AR="$PREBUILT_TOOL_ARMV7A_PATH-ar" CC="$PREBUILT_TOOL_ARMV7A_PATH-gcc --sysroot=$PLATFORM_ARMV7A_PATH" CRYPTO=POLARSSL SHARED=
find $CURRENT_PATH/rtmpdump -name "*.h" -type f -exec \cp {} $CURRENT_PATH/temp/armeabi-v7a/include/librtmp \;
cp $CURRENT_PATH/rtmpdump/librtmp/librtmp.a $CURRENT_PATH/temp/armeabi-v7a/lib/librtmp.a
rm -rf $PLATFORM_ARMV7A_PATH/usr/include/polarssl
rm -rf $PLATFORM_ARMV7A_PATH/usr/lib/libpolarssl.a
#LIBRTMP编译结束

#FFMPEG编译开始
cd $CURRENT_PATH/ffmpeg
./configure --disable-indevs --disable-outdevs --disable-filters --disable-muxers --enable-muxer=*264* --enable-muxer=*wav* --enable-muxer=*flv* --disable-demuxers --enable-demuxer=*aac* --enable-demuxer=*264* --enable-demuxer=*flv* --disable-parsers --enable-parser=*aac* --enable-parser=*264* --disable-protocols --disable-encoders --enable-encoder=*libfdk_aac* --enable-encoder=*libx264* --disable-decoders $FFMPEG_RTMP_OPTIONS --enable-libx264 --enable-libfdk-aac --target-os=linux --arch=arm --cpu=armv7-a --enable-cross-compile --cross-prefix=$PREBUILT_TOOL_ARMV7A_PATH- --extra-ldflags="-L$CURRENT_PATH/temp/armeabi-v7a/lib" --extra-cflags="-I$CURRENT_PATH/temp/armeabi-v7a/include -fPIC -marm -DANDROID -DNDEBUG -static -O3 -march=armv7-a -mfpu=neon -mtune=generic-armv7-a -mfloat-abi=softfp -ftree-vectorize -mvectorize-with-neon-quad -ffast-math" --enable-avresample --enable-asm --disable-yasm --enable-static --disable-shared --enable-gpl --enable-version3 --enable-nonfree --enable-neon --disable-ffmpeg --disable-ffplay --disable-ffserver --disable-ffprobe --prefix=$CURRENT_PATH/temp/armeabi-v7a --sysroot=$PLATFORM_ARMV7A_PATH
make install
#FFMPEG编译结束

#LIBYUV编译开始
cd $CURRENT_PATH/libyuv
mkdir -p $CURRENT_PATH/temp/armeabi-v7a/include/libyuv
cp -R $CURRENT_PATH/libyuv/include/*.h $CURRENT_PATH/temp/armeabi-v7a/include
cp -R $CURRENT_PATH/libyuv/include/libyuv $CURRENT_PATH/temp/armeabi-v7a/include
rm -rf $CURRENT_PATH/libyuv/Android.mk
rm -rf $CURRENT_PATH/libyuv/Application.mk
cp $CURRENT_PATH/optimizer/libyuv/armeabi-v7a/Android.mk $CURRENT_PATH/libyuv/Android.mk
echo "APP_PLATFORM := $PLATFORM_ARMV7A_API" >> $CURRENT_PATH/libyuv/Application.mk
echo "APP_OPTIM := release" >> $CURRENT_PATH/libyuv/Application.mk
echo "APP_ABI := armeabi-v7a" >> $CURRENT_PATH/libyuv/Application.mk
echo "NDK_TOOLCHAIN_VERSION := $PLATFORM_NDK_TOOLCHAIN_VERSION" >> $CURRENT_PATH/libyuv/Application.mk
ndk-build APP_BUILD_SCRIPT=$CURRENT_PATH/libyuv/Android.mk NDK_APPLICATION_MK=$CURRENT_PATH/libyuv/Application.mk NDK_PROJECT_PATH=$CURRENT_PATH/libyuv/
cp $CURRENT_PATH/libyuv/obj/local/armeabi-v7a/libyuv.a $CURRENT_PATH/temp/armeabi-v7a/lib/libyuv.a
#LIBYUV编译结束

#导出编译完成的文件
cd $CURRENT_PATH
mkdir -p $CURRENT_PATH/freya_build_finished/armeabi-v7a
rm -rf $CURRENT_PATH/freya_build_finished/armeabi-v7a/include
rm -rf $CURRENT_PATH/freya_build_finished/armeabi-v7a/lib
rm -rf $CURRENT_PATH/temp/armeabi-v7a/include/libavcodec/jni.h
mv $CURRENT_PATH/temp/armeabi-v7a/include $CURRENT_PATH/freya_build_finished/armeabi-v7a
mv $CURRENT_PATH/temp/armeabi-v7a/lib $CURRENT_PATH/freya_build_finished/armeabi-v7a
#导出编译完成的文件

#编译ARMV7-A库文件结束

#清理源代码与临时文件并重新解包
cd $CURRENT_PATH
rm -rf ./fdkaac
rm -rf ./ffmpeg
rm -rf ./libyuv
rm -rf ./polarssl
rm -rf ./rtmpdump
rm -rf ./x264
rm -rf ./temp/*
tar -xvf ./codec_temp.tar
chmod -R 777 *
rm -rf ./codec_temp.tar
#清理源代码与临时文件并重新解包