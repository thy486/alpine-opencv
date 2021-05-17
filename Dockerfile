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
  v4l-utils

# Python 3 as default
RUN cd /tmp && \
  curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
  python3 get-pip.py && \
  ln -s /usr/bin/python3 /usr/local/bin/python && \
  ln -s /usr/bin/pip3 /usr/local/bin/pip && \
  rm -rf get-pip.py

# Install NumPy
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h && \
  pip install numpy==1.18.0

# Install OpenCV
RUN mkdir -p /opt && cd /opt && \
  wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
  unzip ${OPENCV_VERSION}.zip && rm ${OPENCV_VERSION}.zip && \
  wget https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip && \
  unzip ${OPENCV_VERSION}.zip && rm ${OPENCV_VERSION}.zip \
  && \
  cd /opt/opencv-${OPENCV_VERSION} && mkdir build && cd build && \
  cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D BUILD_opencv_python3=ON \
    -D CMAKE_C_COMPILER=/usr/bin/clang \
    -D CMAKE_CXX_COMPILER=/usr/bin/clang++ \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D INSTALL_C_EXAMPLES=ON \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D BUILD_EXAMPLES=OFF \
    -D WITH_FFMPEG=ON \
    -D WITH_TBB=ON \
    -D WITH_V4L=ON \
    -D OPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib-${OPENCV_VERSION}/modules \
    -D PYTHON_EXECUTABLE=/usr/local/bin/python \
    .. \
  && make -j$(nproc) && make install && cd .. && rm -rf build 
  # || cat /opt/opencv-${OPENCV_VERSION}/build/CMakeFiles/CMakeOutput.log

# Make sure it's built properly
RUN cp -p $(find /usr/local/lib/python3.8/site-packages -name cv2.*.so) \
   /usr/lib/python3.8/site-packages/cv2.so && \
   python -c 'import cv2; print("Python: import cv2 - SUCCESS")' || echo $(find / -name cv2.*.so)