FROM alpine:3.12

ENV LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash PS1="\u@\h:\w \$ " \
    OPENCV_VERSION=4.5.1

# Add Edge repos
RUN echo -e "\n\
@edgemain http://nl.alpinelinux.org/alpine/edge/main\n\
@edgecomm http://nl.alpinelinux.org/alpine/edge/community\n\
@edgetest http://nl.alpinelinux.org/alpine/edge/testing"\
  >> /etc/apk/repositories

# Install required packages
RUN apk update && apk upgrade && apk --no-cache add \
  bash \
  build-base \
  ca-certificates \
  clang-dev \
  clang \
  cmake \
  coreutils \
  curl \ 
  freetype-dev \
  ffmpeg-dev \
  ffmpeg-libs \
  gcc \
  g++ \
  git \
  gettext \
  lcms2-dev \
  libavc1394-dev \
  libc-dev \
  libffi-dev \
  libjpeg-turbo-dev \
  libpng-dev \
  libressl-dev \
  libtbb@edgecomm \
  libtbb-dev@edgecomm \
  libwebp-dev \
  linux-headers \
  make \
  musl \
  musl-dev \
  openblas@edgecomm \
  openblas-dev@edgecomm \
  openjpeg-dev \
  openjpeg-tools \
  openssl \
  python3 \
  python3-dev \
  tiff-dev \
  unzip \
  zlib-dev \
  v4l-utils \
  libgphoto2 libgphoto2-dev \
  gstreamer gstreamer-dev \
  && rm -rf /var/cache/apk/*

# Python 3 as default
RUN cd /tmp && \
  curl -SL https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
  python3 get-pip.py && \
  # Make Python3 as default
    ln -vfs /usr/bin/python3 /usr/local/bin/python && \
    ln -vfs /usr/bin/pip3 /usr/local/bin/pip && \
    # Fix libpng path
    ln -vfs /usr/include/libpng16 /usr/include/libpng && \
    ln -vfs /usr/include/locale.h /usr/include/xlocale.h && \
    pip3 install -v --no-cache-dir --upgrade pip && \
    pip3 install -v --no-cache-dir numpy && \
    # Download OpenCV source
    cd /tmp && \
    wget https://github.com/opencv/opencv/archive/$OPENCV_VERSION.tar.gz && \
    tar -xvzf $OPENCV_VERSION.tar.gz && \
    rm -vrf $OPENCV_VERSION.tar.gz /tmp/get-pip.py && \
    # Configure
    mkdir -vp /tmp/opencv-$OPENCV_VERSION/build && \
    cd /tmp/opencv-$OPENCV_VERSION/build && \
    cmake \
  # Compiler params
        -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_C_COMPILER=/usr/bin/clang \
        -D CMAKE_CXX_COMPILER=/usr/bin/clang++ \
        -D CMAKE_INSTALL_PREFIX=/usr \
        # No examples
        -D INSTALL_PYTHON_EXAMPLES=NO \
        -D INSTALL_C_EXAMPLES=NO \
        # Support
        -D WITH_IPP=NO \
        -D WITH_1394=YES \
        -D WITH_LIBV4L=YES \
        -D WITH_V4l=YES \
        -D WITH_TBB=YES \
        -D WITH_FFMPEG=YES \
        -D WITH_GPHOTO2=YES \
        -D WITH_GSTREAMER=YES \
        # NO doc test and other bindings
        -D BUILD_DOCS=NO \
        -D BUILD_TESTS=NO \
        -D BUILD_PERF_TESTS=NO \
        -D BUILD_EXAMPLES=NO \
        -D BUILD_opencv_java=NO \
        -D BUILD_opencv_python2=NO \
        -D BUILD_ANDROID_EXAMPLES=NO \
        # Build Python3 bindings only
        -D PYTHON3_LIBRARY=`find /usr -name libpython3.so` \
        -D PYTHON_EXECUTABLE=`which python3` \
        -D PYTHON3_EXECUTABLE=`which python3` \
        -D OPENCV_GENERATE_PKGCONFIG=ON \
        -D BUILD_opencv_python3=YES .. && \
  && make -j`grep -c '^processor' /proc/cpuinfo` && make install && ln -s /usr/local/include/opencv4/opencv2/ /usr/local/include/opencv2 && cd .. && rm -rf build 
  # || cat /opt/opencv-${OPENCV_VERSION}/build/CMakeFiles/CMakeOutput.log

# Make sure it's built properly
# RUN cp -p $(find /usr/local/lib/python3.8/site-packages -name cv2.*.so) \
#    /usr/lib/python3.8/site-packages/cv2.so && \
#    python -c 'import cv2; print("Python: import cv2 - SUCCESS")' || echo $(find / -name cv2.*.so)