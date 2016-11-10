# FREYA-LIVE-LIBRARY-OPTIMIZER-FOR-ANDROID
FREYA LIVE LIBRARY OPTIMIZER FOR ANDROID是一套RTMP直播推流常用库的编译简化/优化工具(面向安卓设备)，简单配置后能一键完成库文件的编译与优化(FFMPEG+X264+FDKAAC+LIBRTMP/FFMPEG NATIVE RTMP+LIBYUV)
</br>
</br>
针对ARM、ARMV7-A、ARM64-V8A、X86、X86_64、MIPS、MIPS64全平台极致优化。参阅了大量技术文档确定优化选项，并经过了实机测试，是目前最好的RTMP推流库编译简化及优化工具
</br>
</br>
更新日期：2016.11.10    版本：1.0.1
</br>
</br>
一、需准备的编译环境
</br>
</br>
    1.操作系统：LINUX X64
</br>
    (推荐UBUNTU-12.04.5-DESKTOP-AMD64或以上版本)
</br>
</br>
    2.NDK版本：R13或以上版本
</br>
    (本工具目前采用GCC编译所有库文件，因此NDK中必须包含GCC编译器。而从NDK R13开始谷歌停止了对GCC的更新，转用CLANG作为默认编译器，且在CLANG编译器稳定后有移除GCC的计划，但就目前而言还是GCC更有优势，在GCC被正式移除后我会开发对应CLANG的编译脚本)
</br>
</br>
    3.编译X86/X86_64库文件需要安装：YASM 1.3.0或以上版本
</br>
</br>
二、编译脚本与库文件的对应关系
</br>
</br>
    1.freya_compile_arm.sh用于编译ARM库文件
</br>
</br>
    2.freya_compile_armv7a.sh用于编译ARMV7-A库文件
</br>
</br>
    3.freya_compile_arm64v8a.sh用于编译ARM64-V8A库文件
</br>
</br>
    4.freya_compile_x86.sh用于编译X86库文件
</br>
</br>
    5.freya_compile_x86_64.sh用于编译X86_64库文件
</br>
</br>
    6.freya_compile_mips.sh用于编译MIPS库文件
</br>
</br>
    7.freya_compile_mips64.sh用于编译MIPS64库文件
</br>
</br>
三、如何使用本工具
</br>
</br>
    1.按照第二部分所述对应关系，找到需要使用的编译脚本，并为脚本中需要配置的变量赋值
</br>
</br>
    2.找到CURRENT_PATH变量，配置本脚本所在的目录位置
</br>
</br>
    3.找到NDKROOT_PATH变量，配置NDK所在目录位置
</br>
</br>
    4.FFMPEG_RTMP_OPTIONS变量可以配置使用LIBRTMP(RTMPDUMP)还是FFMPEG NATIVE RTMP作为RTMP推流库，默认使用LIBRTMP(RTMPDUMP)
</br>
</br>
    5.PREBUILT_TOOL_\*\_PATH变量可以配置对应各平台的TOOLCHAIN目录与程序名，需要配置到TOOLCHAIN程序文件名共有的前半段，一般无需修改(\*代表ARM、ARMV7A、ARM64V8A、X86、X86_64、MIPS、MIPS64)
</br>
</br>
    6.PLATFORM_\*\_PATH变量可以配置对应各平台的ANDROID API目录(\*代表ARM、ARMV7A、ARM64V8A、X86、X86_64、MIPS、MIPS64)
</br>
</br>
    7.PLATFORM_\*\_API变量可以配置对应各平台的ANDROID API级别(必须与PLATFORM_\*\_PATH相对应，\*代表ARM、ARMV7A、ARM64V8A、X86、X86_64、MIPS、MIPS64)
</br>
</br>
    8.PLATFORM_NDK_TOOLCHAIN_VERSION变量可以配置对应各平台的TOOLCHAIN版本，默认为4.9，一般无需修改
</br>
</br>
    9.对于X86/X86_64平台而言，必须使用YASM_\*\_PATH变量指出YASM编译器的所在位置(\*代表X86、X86_64)
</br>
</br>
    10.脚本中对于以上变量的配置均有详细注释，在配置时可以参考
</br>
</br>
    11.配置完成后使用root用户运行对应各平台的编译脚本即可，编译完成后在freya_build_finished目录会生成相应的库文件
</br>
</br>
    12.如果freya_build_finished/平台名/lib目录中生成如下.a文件，则编译成功：
</br>
    FFMPEG：libavcodec.a、libavdevice.a、libavfilter.a、libavformat.a、libavresample.a、libavutil.a、libpostproc.a、libswresample.a、libswscale.a
</br>
    X264：libx264.a
</br>
    FDKAAC：libfdk-aac.a
</br>
    LIBRTMP(RTMPDUMP)：librtmp.a
</br>
    POLARSSL：libpolarssl.a
</br>
    LIBYUV：libyuv.a
</br>
</br>
    13.用户可以自行替换ffmpeg、x264、fdkaac、rtmpdump、polarssl、libyuv目录下的文件进行组件版本更换
</br>
</br>
四、当前源码版本
</br>
</br>
    1.FFMPEG 3.2 RELEASE
</br>
</br>
    2.X264 2016.11.09 STABLE
</br>
</br>
    3.FDKAAC 0.1.4 2016.11.09 FROM MSTORSJO
</br>
</br>
    4.LIBRTMP(RTMPDUMP) 2.4
</br>
</br>
    5.POLARSSL 1.2.19
</br>
</br>
    6.LIBYUV REV 1634
</br>
</br>
    会定期更新FFMPEG、FDKAAC、X264、LIBYUV的版本，并进行编译与实机推流测试，一般2-3个月更新一次
</br>
    由于官方已经停止了LIBRTMP(RTMPDUMP)的维护，因此LIBRTMP(RTMPDUMP)、POLARSSL一般不会更新，除非官方再次更新
</br>
</br>
五、优化方案
</br>
</br>
    本编译脚本针对ARM、ARMV7-A、ARM64-V8A、X86、X86_64、MIPS、MIPS64全平台极致优化。参阅了大量技术文档确定优化选项，具体优化方案如下
</br>
</br>
    1.ARM优化方案：
</br>
    FFMPEG： VFP+针对ARMV5TE的CPU调优
</br>
    X264： VFP+多核多线程优化+针对ARMV5TE的CPU调优
</br>
    FDKAAC： VFP+针对ARMV5TE的CPU调优
</br>
    LIBRTMP： 针对ARMV5TE的CPU调优
</br>
    POLARSSL： 汇编优化+针对ARMV5TE的CPU调优
</br>
    LIBYUV： VFP+针对ARMV5TE的CPU调优
</br>
</br>
    2.ARMV7-A优化方案：
</br>
    FFMPEG： NEON指令集+VFPV3+针对ARMV7-A的CPU调优
</br>
    X264： NEON指令集+VFPV3+多核多线程优化+针对ARMV7-A的CPU调优
</br>
    FDKAAC： NEON指令集+VFPV3+针对ARMV7-A的CPU调优
</br>
    LIBRTMP： 针对ARMV7-A的CPU调优
</br>
    POLARSSL： 汇编优化+针对ARMV7-A的CPU调优
</br>
    LIBYUV： NEON指令集+VFPV3+针对ARMV7-A的CPU调优
</br>
</br>
    3.ARM64-V8A优化方案：
</br>
    FFMPEG： NEON指令集+VFPV4+针对ARM64-V8A的CPU调优
</br>
    X264： NEON指令集+VFPV4+多核多线程优化+针对ARM64-V8A的CPU调优
</br>
    FDKAAC： NEON指令集+VFPV4+针对ARM64-V8A的CPU调优
</br>
    LIBRTMP： 针对ARM64-V8A的CPU调优
</br>
    POLARSSL： 汇编优化+针对ARM64-V8A的CPU调优
</br>
    LIBYUV： NEON指令集+VFPV4+针对ARM64-V8A的CPU调优
</br>
</br>
    4.X86/X86_64优化方案：
</br>
    FFMPEG： SSSE3指令集+汇编优化+针对ATOM的CPU调优
</br>
    X264： SSSE3指令集+汇编优化+多核多线程优化+针对ATOM的CPU调优
</br>
    FDKAAC： 针对ATOM的CPU调优
</br>
    LIBRTMP： 针对ATOM的CPU调优
</br>
    POLARSSL： 汇编优化+SSE2指令集+针对ATOM的CPU调优
</br>
    LIBYUV： SSSE3指令集+针对ATOM的CPU调优
</br>
</br>
    5.MIPS优化方案：
</br>
    FFMPEG： DSP R2+MSA+MIPS FPU+针对MIPS32R2的CPU调优
</br>
    X264： DSP R2+MSA+MIPS FPU+多核多线程优化+针对MIPS32R2的CPU调优
</br>
    FDKAAC： DSP R2+MSA+MIPS FPU+针对MIPS32R2的CPU调优
</br>
    LIBRTMP： 针对MIPS32R2的CPU调优
</br>
    POLARSSL： 汇编优化+针对MIPS32R2的CPU调优
</br>
    LIBYUV： DSP R2+MSA+MIPS FPU+针对MIPS32R2的CPU调优
</br>
</br>
    6.MIPS64优化方案：
</br>
    FFMPEG： DSP R2+MSA+MIPS FPU+针对MIPS64R6的CPU调优
</br>
    X264： DSP R2+MSA+MIPS FPU+多核多线程优化+针对MIPS64R6的CPU调优
</br>
    FDKAAC： DSP R2+MSA+MIPS FPU+针对MIPS64R6的CPU调优
</br>
    LIBRTMP： 针对MIPS64R6的CPU调优
</br>
    POLARSSL： 汇编优化+针对MIPS64R6的CPU调优
</br>
    LIBYUV： DSP R2+MSA+MIPS FPU+针对MIPS64R6的CPU调优
</br>
</br>
六、为何选用此套组件作为直播推流方案
</br>
</br>
    1.为何选择X264作为H264编码器
</br>
    目前流行的开源H264编码器主要有：X264与OPENH264
</br>
    X264作为H264编码器，主要有以下优势：
</br>
    (1)X264(SUPERFAST模式)与OPENH264速度、画质持平，X264(ULTRAFAST模式)比OPENH264快20%-30%，X264能适合更多低端设备推流，在高端设备上也能通过调节参数获得更好的性能与画质表现
</br>
    (2)X264编码器拥有更丰富的调节选项，OPENH264可调的选项很少
</br>
    (3)X264支持BASELINE、MAIN、HIGH三种PROFILE，OPENH264仅支持BASELINE。在高端设备上通过提高PROFILE的等级(会增加CPU的计算量)，在同画质下可节省带宽。
</br>
</br>
    2.为何选择FDKAAC作为AAC编码器
</br>
    FDKAAC作为AAC编码器，主要有以下优势：
</br>
    (1)FDKAAC是目前音质最好的AAC编码器。从FFMPEG 3.0开始，FFMPEG的NATIVE AAC编码器虽有大幅改进(已经优于除FDKAAC外的其他AAC编码器)，但仍落后于FDKAAC
</br>
    (2)FDKAAC有很好的性能表现
</br>
    (3)FDKAAC是目前唯一支持HE的AAC编码器。高端设备使用HE模式(会增加CPU的计算量)，在服务器支持的情况下，同音质下可节省带宽
</br>
</br>
    3.为何选择LIBRTMP(RTMPDUMP)/FFMPEG NATIVE RTMP作为RTMP推流库
</br>
    LIBRTMP(RTMPDUMP)作为推流库，主要有以下优势：
</br>
    (1)LIBRTMP(RTMPDUMP)支持全RTMP协议(RTMP RTMPT RTMPE RTMPTE RTMPS)推流，FFMPEG新版本目前虽然也支持全RTMP协议，但兼容性不如LIBRTMP(RTMPDUMP)
</br>
</br>
    FFMPEG NATIVE RTMP作为推流库，主要有以下优势：
</br>
    (1)FFMPEG NATIVE RTMP仍有官方维护，可获得来自官方的代码更新。而LIBRTMP(RTMPDUMP)缺少官方维护
</br>
</br>
    4.为何选择POLARSSL作为SSL库
</br>
    (1)使用POLARSSL可以让LIBRTMP(RTMPDUMP)支持RTMPT RTMPE RTMPTE RTMPS协议
</br>
    (2)POLARSSL支持汇编优化+SSE2指令集优化
</br>
    (3)POLARSSL比OPENSSL更小巧
</br>
</br>
    5.为何选择LIBYUV作为视频操作/转换库
</br>
    LIBYUV作为视频操作/转换库，主要有以下优势：
</br>
    (1)LIBYUV支持NEON优化(ARMV7-A/ARM64-V8A)，SSE2/SSSE3/AVX2优化(X86/X86_64)，DSP R2优化(MIPS32/MIPS64)，性能远超FFMPEG自带的LIBSWSCALE
</br>
</br>
作者:jkkj93
