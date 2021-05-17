FROM alpine:3.12

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash PS1="\u@\h:\w \$ " \
    OPENCV_VERSION=4.5.2

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
  openblas@edgecomm \
  openblas-dev@edgecomm \
  openjpeg-dev \
  openssl \
  python3 \
  python3-dev \
  tiff-dev \
  unzip \
  zlib-dev

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
RUN mkdir /opt && cd /opt && \
  wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
  unzip ${OPENCV_VERSION}.zip && rm ${OPENCV_VERSION}.zip && \
  wget https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip && \
  unzip ${OPENCV_VERSION}.zip && rm ${OPENCV_VERSION}.zip \
  && \
  cd /opt/opencv-${OPENCV_VERSION} && mkdir build && cd build && \
  cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_C_COMPILER=/usr/bin/clang \
    -D CMAKE_CXX_COMPILER=/usr/bin/clang++ \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D INSTALL_C_EXAMPLES=OFF \
    -D WITH_FFMPEG=ON \
    -D WITH_TBB=ON \
    -D OPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib-${OPENCV_VERSION}/modules \
    -D PYTHON_EXECUTABLE=/usr/local/bin/python \
    .. \
  && \
  make -j$(nproc) && make install && cd .. && rm -rf build \
  && \
  cp -p $(find /usr/local/lib/python3.8/dist-packages -name cv2.*.so) \
   /usr/lib/python3.8/site-packages/cv2.so && \
   python -c 'import cv2; print("Python: import cv2 - SUCCESS")'
