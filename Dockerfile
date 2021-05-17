FROM alpine:3.12
ENV LANG=C.UTF-8 \
    SHELL=/bin/bash PS1="\u@\h:\w \$ "
ARG OPENCV_VERSION=4.5.1
RUN apk update && apk upgrade && \
    apk --no-cache add \
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
  apk --no-cache --virtual=.build-deps add \
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
                  v4l-utils \
  apk --no-cache --virtual .builddeps.edge add \
                  libtbb libtbb-dev openblas openblas-dev \
                  --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/  \
                  && rm -rf /var/cache/apk/* && \
# Python 3 as default
  cd /tmp && \
  curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
  python3 get-pip.py && \
  ln -s /usr/bin/python3 /usr/local/bin/python && \
  ln -s /usr/bin/pip3 /usr/local/bin/pip && \
  rm -rf get-pip.py && \
# Install NumPy
  ln -s /usr/include/locale.h /usr/include/xlocale.h && \
  pip install --no-cache-dir  numpy && \
# Install OpenCV
  mkdir -p /opt && cd /opt && \
  wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
  unzip ${OPENCV_VERSION}.zip && rm ${OPENCV_VERSION}.zip && \
  wget https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip && \
  unzip ${OPENCV_VERSION}.zip && rm ${OPENCV_VERSION}.zip \
  && \
  cd /opt/opencv-${OPENCV_VERSION} && mkdir build && cd build && \
  cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D BUILD_opencv_python3=ON \
    -D BUILD_opencv_python2=OFF \
    -D CMAKE_C_COMPILER=/usr/bin/clang \
    -D CMAKE_CXX_COMPILER=/usr/bin/clang++ \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D INSTALL_C_EXAMPLES=OFF \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D BUILD_EXAMPLES=OFF \
    -D BUILD_DOCS=OFF \
    -D WITH_FFMPEG=ON \
    -D WITH_TBB=ON \
    -D WITH_V4L=ON \
    -D OPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib-${OPENCV_VERSION}/modules \
    -D PYTHON_INCLUDE_DIR=/usr/include/python3.8/ \
    -D PYTHON_LIBRARY=/usr/lib/libpython3.so \
    -D PYTHON3_PACKAGES_PATH=/usr/lib/python3.8/site-packages/ \
    -D PYTHON3_NUMPY_INCLUDE_DIRS=/usr/lib/python3.8/site-packages/numpy/core/include/ \
    -D PYTHON3_EXECUTABLE=/usr/bin/python3 \
    -D PYTHON_EXECUTABLE=/usr/local/bin/python .. && \
  make -j$(nproc) && make install && cd .. && rm -rf build && \
# Make sure it's built properly
  cp -p $(find /usr/local/lib/python3.8/site-packages -name cv2.*.so) \
   /usr/lib/python3.8/site-packages/cv2.so && \
   python -c 'import cv2; print("Python: import cv2 - SUCCESS")' && apk del .build-deps .builddeps.edge