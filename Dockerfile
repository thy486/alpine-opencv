FROM alpine:3.12
ENV LANG=C.UTF-8 \
    SHELL=/bin/bash PS1="\u@\h:\w \$ "
ARG OPENCV_VERSION=4.5.2
RUN apk update && apk upgrade && \
    apk add --no-cache \
            bash \
            coreutils \
            moreutils \
            git \
            curl \
            perl \
            openssl \
            openssh \
            nginx \
            python3 && \
  apk add --no-cache --virtual=.build-dep1 \
                  build-base \
                  ca-certificates \
                  clang-dev \
                  clang \
                  cmake \
                  coreutils \
                  freetype-dev \
                  ffmpeg-dev \
                  ffmpeg-libs \
                  gcc \
                  g++ \
                  gettext \
                  lcms2-dev \
                  libavc1394-dev \
                  libc-dev \
                  libffi-dev \
                  libjpeg-turbo-dev \
                  libpng-dev \
                  libressl-dev \
                  libwebp-dev \
                  linux-headers \
                  make \
                  musl \
                  musl-dev \
                  openjpeg-dev \
                  openjpeg-tools \
                  python3-dev \
                  tiff-dev \
                  unzip \
                  zlib-dev \
                  v4l-utils && \
  apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --virtual .build-dep2 \
                  libtbb libtbb-dev openblas openblas-dev && \
                  rm -rf /var/cache/apk/* && \
# Python 3 as default
  cd /tmp && \
  curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
  python3 get-pip.py && \
  ln -s /usr/bin/python3 /usr/local/bin/python && \
  ln -s /usr/bin/pip3 /usr/local/bin/pip && \
  rm -rf get-pip.py && \
# Install NumPy
  ln -s /usr/include/locale.h /usr/include/xlocale.h && \
  pip install --no-cache-dir numpy && \
# Install OpenCV
  mkdir -p /opt && cd /opt && \
  wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
  unzip ${OPENCV_VERSION}.zip && rm ${OPENCV_VERSION}.zip && \
  cd /opt/opencv-${OPENCV_VERSION} && mkdir build && cd build && \
  cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D BUILD_opencv_python3=ON \
    -D BUILD_opencv_python2=NO \
    -D CMAKE_C_COMPILER=/usr/bin/clang \
    -D CMAKE_CXX_COMPILER=/usr/bin/clang++ \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_PYTHON_EXAMPLES=NO \
    -D INSTALL_C_EXAMPLES=NO \
    -D INSTALL_PYTHON_EXAMPLES=NO \
    -D BUILD_EXAMPLES=NO \
    -D BUILD_DOCS=NO \
    -D WITH_FFMPEG=ON \
    -D WITH_TBB=ON \
    -D WITH_V4L=ON \
    -D OPENCV_EXTRA_MODULES_PATH=/opt/opencv-${OPENCV_VERSION}/modules \
    -D PYTHON_EXECUTABLE=/usr/local/bin/python \ .. && \
  make -j$(nproc) && make install && cd .. && rm -rf build && \
# Make sure it's built properly
  apk del .build-dep1 .build-dep2 && rm -rf /opt/* \
  cp -p $(find /usr/local/lib/python3.8/site-packages -name cv2.*.so) \
   /usr/lib/python3.8/site-packages/cv2.so && \
   python -c 'import cv2; print("Python: import cv2 - SUCCESS")' \