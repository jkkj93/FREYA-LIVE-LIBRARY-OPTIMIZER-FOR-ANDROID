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

PREBUILT_TOOL_MIPS64_PATH=$NDKROOT_PATH/toolchains/mips64el-linux-android-4.9/prebuilt/linux-x86_64/bin/mips64el-linux-android
#对应MIPS64的TOOLCHAIN目录 需要配置到TOOLCHAIN程序文件名共有的前半段
PLATFORM_MIPS64_PATH=$NDKROOT_PATH/platforms/android-21/arch-mips64
#对应MIPS64的ANDROID平台目录 必须配置android-21及以上平台
PLATFORM_MIPS64_API=android-21
#对应MIPS64的ANDROID API
PLATFORM_NDK_TOOLCHAIN_VERSION=4.9
#对应MIPS64的TOOLCHAIN版本

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


#编译MIPS64库文件开始

#建立临时目录开始
mkdir -p $CURRENT_PATH/temp/mips64/include/fdk-aac
mkdir -p $CURRENT_PATH/temp/mips64/lib
#建立临时目录结束

#X264编译开始
cd $CURRENT_PATH/x264
./configure --host=mips64-linux --enable-pic --enable-static --cross-prefix=$PREBUILT_TOOL_MIPS64_PATH- --extra-cflags="-fPIC -DX264_VERSION -DANDROID -DHAVE_PTHREAD -DNDEBUG -static -O3 -march=mips64r6 -mtune=mips64r6 -mabi=64 -mhard-float -mfp64 -mmsa -mmt -mdspr2 -mmcu -ffast-math -ftree-vectorize" --prefix=$CURRENT_PATH/temp/mips64 --sysroot=$PLATFORM_MIPS64_PATH
make install
#X264编译结束

#FDKAAC编译开始
cd $CURRENT_PATH/fdkaac
find $CURRENT_PATH/fdkaac -name "*.h" -type f -exec \cp {} $CURRENT_PATH/temp/mips64/include/fdk-aac \;
rm -rf $CURRENT_PATH/fdkaac/Android.mk
rm -rf $CURRENT_PATH/fdkaac/Application.mk
cp $CURRENT_PATH/optimizer/fdkaac/mips64/Android.mk $CURRENT_PATH/fdkaac/Android.mk
echo "APP_PLATFORM := $PLATFORM_MIPS64_API" >> $CURRENT_PATH/fdkaac/Application.mk
echo "APP_OPTIM := release" >> $CURRENT_PATH/fdkaac/Application.mk
echo "APP_ABI := mips64" >> $CURRENT_PATH/fdkaac/Application.mk
echo "NDK_TOOLCHAIN_VERSION := $PLATFORM_NDK_TOOLCHAIN_VERSION" >> $CURRENT_PATH/fdkaac/Application.mk
ndk-build APP_BUILD_SCRIPT=$CURRENT_PATH/fdkaac/Android.mk NDK_APPLICATION_MK=$CURRENT_PATH/fdkaac/Application.mk NDK_PROJECT_PATH=$CURRENT_PATH/fdkaac/
cp $CURRENT_PATH/fdkaac/obj/local/mips64/libfdk-aac.a $CURRENT_PATH/temp/mips64/lib/libfdk-aac.a
#FDKAAC编译结束

#POLARSSL编译开始
cd $CURRENT_PATH/polarssl
rm -rf $CURRENT_PATH/polarssl/include/polarssl/config.h
rm -rf $PLATFORM_MIPS64_PATH/usr/include/polarssl
rm -rf $PLATFORM_MIPS64_PATH/usr/lib/libpolarssl.a
mkdir -p $PLATFORM_MIPS64_PATH/usr/include/polarssl
cp $CURRENT_PATH/optimizer/polarssl/mips64/config.h $CURRENT_PATH/polarssl/include/polarssl/config.h
make CC="$PREBUILT_TOOL_MIPS64_PATH-gcc -fPIC -DANDROID -DNDEBUG -static -O3 -march=mips64r6 -mtune=mips64r6 -mabi=64 -mhard-float -mfp64 -mmsa -mmt -mdspr2 -mmcu -ffast-math -ftree-vectorize --sysroot=$PLATFORM_MIPS64_PATH" APPS=
make install DESTDIR="$CURRENT_PATH/temp/mips64" CC="$PREBUILT_TOOL_MIPS64_PATH-gcc -fPIC -DANDROID -DNDEBUG -static -O3 -march=mips64r6 -mtune=mips64r6 -mabi=64 -mhard-float -mfp64 -mmsa -mmt -mdspr2 -mmcu -ffast-math -ftree-vectorize --sysroot=$PLATFORM_MIPS64_PATH" APPS=
#POLARSSL编译结束

#LIBRTMP编译开始
cd $CURRENT_PATH/rtmpdump
rm -rf $CURRENT_PATH/rtmpdump/Makefile
rm -rf $CURRENT_PATH/rtmpdump/librtmp/Makefile
mkdir -p $CURRENT_PATH/temp/mips64/include/librtmp
cp $CURRENT_PATH/optimizer/rtmpdump/mips64/Makefile $CURRENT_PATH/rtmpdump/Makefile
cp $CURRENT_PATH/optimizer/rtmpdump/mips64/librtmp/Makefile $CURRENT_PATH/rtmpdump/librtmp/Makefile
cp -R $CURRENT_PATH/temp/mips64/include/polarssl $PLATFORM_MIPS64_PATH/usr/include/
cp -R $CURRENT_PATH/temp/mips64/lib/libpolarssl.a $PLATFORM_MIPS64_PATH/usr/lib/libpolarssl.a
cp -R $CURRENT_PATH/temp/mips64/lib/libpolarssl.a $PLATFORM_MIPS64_PATH/usr/lib64/libpolarssl.a
make SYS=android CROSS_COMPILE=mips64el-linux-android- INC="-I$CURRENT_PATH/temp/mips64/include -L$CURRENT_PATH/temp/mips64/lib" AR="$PREBUILT_TOOL_MIPS64_PATH-ar" CC="$PREBUILT_TOOL_MIPS64_PATH-gcc --sysroot=$PLATFORM_MIPS64_PATH" CRYPTO=POLARSSL SHARED=
find $CURRENT_PATH/rtmpdump -name "*.h" -type f -exec \cp {} $CURRENT_PATH/temp/mips64/include/librtmp \;
cp $CURRENT_PATH/rtmpdump/librtmp/librtmp.a $CURRENT_PATH/temp/mips64/lib/librtmp.a
rm -rf $PLATFORM_MIPS64_PATH/usr/include/polarssl
rm -rf $PLATFORM_MIPS64_PATH/usr/lib/libpolarssl.a
rm -rf $PLATFORM_MIPS64_PATH/usr/lib64/libpolarssl.a
#LIBRTMP编译结束

#FFMPEG编译开始
cd $CURRENT_PATH/ffmpeg
./configure --disable-indevs --disable-outdevs --disable-filters --disable-muxers --enable-muxer=*264* --enable-muxer=*wav* --enable-muxer=*flv* --disable-demuxers --enable-demuxer=*aac* --enable-demuxer=*264* --enable-demuxer=*flv* --disable-parsers --enable-parser=*aac* --enable-parser=*264* --disable-protocols --disable-encoders --enable-encoder=*libfdk_aac* --enable-encoder=*libx264* --disable-decoders $FFMPEG_RTMP_OPTIONS --enable-libx264 --enable-libfdk-aac --target-os=linux --arch=mips64 --cpu=generic --enable-cross-compile --cross-prefix=$PREBUILT_TOOL_MIPS64_PATH- --extra-ldflags="-L$CURRENT_PATH/temp/mips64/lib" --extra-cflags="-I$CURRENT_PATH/temp/mips64/include -fPIC -DANDROID -DNDEBUG -static -O3 -march=mips64r6 -mtune=mips64r6 -mabi=64 -mhard-float -mfp64 -mmsa -mmt -mdspr2 -mmcu -ffast-math -ftree-vectorize" --enable-avresample --enable-asm --disable-yasm --enable-mipsdsp --enable-mipsdspr2 --enable-msa --enable-mipsfpu --enable-mmi --enable-static --disable-shared --enable-gpl --enable-version3 --enable-nonfree --disable-ffmpeg --disable-ffplay --disable-ffserver --disable-ffprobe --prefix=$CURRENT_PATH/temp/mips64 --sysroot=$PLATFORM_MIPS64_PATH
make install
#FFMPEG编译结束

#LIBYUV编译开始
cd $CURRENT_PATH/libyuv
mkdir -p $CURRENT_PATH/temp/mips64/include/libyuv
cp -R $CURRENT_PATH/libyuv/include/*.h $CURRENT_PATH/temp/mips64/include
cp -R $CURRENT_PATH/libyuv/include/libyuv $CURRENT_PATH/temp/mips64/include
rm -rf $CURRENT_PATH/libyuv/Android.mk
rm -rf $CURRENT_PATH/libyuv/Application.mk
cp $CURRENT_PATH/optimizer/libyuv/mips64/Android.mk $CURRENT_PATH/libyuv/Android.mk
echo "APP_PLATFORM := $PLATFORM_MIPS64_API" >> $CURRENT_PATH/libyuv/Application.mk
echo "APP_OPTIM := release" >> $CURRENT_PATH/libyuv/Application.mk
echo "APP_ABI := mips64" >> $CURRENT_PATH/libyuv/Application.mk
echo "NDK_TOOLCHAIN_VERSION := $PLATFORM_NDK_TOOLCHAIN_VERSION" >> $CURRENT_PATH/libyuv/Application.mk
ndk-build APP_BUILD_SCRIPT=$CURRENT_PATH/libyuv/Android.mk NDK_APPLICATION_MK=$CURRENT_PATH/libyuv/Application.mk NDK_PROJECT_PATH=$CURRENT_PATH/libyuv/
cp $CURRENT_PATH/libyuv/obj/local/mips64/libyuv.a $CURRENT_PATH/temp/mips64/lib/libyuv.a
#LIBYUV编译结束

#导出编译完成的文件
cd $CURRENT_PATH
mkdir -p $CURRENT_PATH/freya_build_finished/mips64
rm -rf $CURRENT_PATH/freya_build_finished/mips64/include
rm -rf $CURRENT_PATH/freya_build_finished/mips64/lib
rm -rf $CURRENT_PATH/temp/mips64/include/libavcodec/jni.h
mv $CURRENT_PATH/temp/mips64/include $CURRENT_PATH/freya_build_finished/mips64
mv $CURRENT_PATH/temp/mips64/lib $CURRENT_PATH/freya_build_finished/mips64
#导出编译完成的文件

#编译MIPS64库文件结束

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