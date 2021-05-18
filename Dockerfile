FROM alpine:3.12
ENV LANG=C.UTF-8 \
    SHELL=/bin/bash PS1="\u@\h:\w \$ " \
    PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig \
    LD_LIBRARY_PATH=/usr/local/lib64/:/usr/local/include/
ARG OPENCV_VERSION=4.5.1
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
                  eigen \
                  eigen-dev \
                  libgphoto2 \
                  libgphoto2-dev \
                  gst-plugins-base \
                  gst-plugins-base-dev \
                  gstreamer \
                  gstreamer-dev \
                  v4l-utils && \
  apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --virtual .build-dep2 \
                  libtbb libtbb-dev openblas openblas-dev && \
# Python 3 as default
  cd /tmp && \
  curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
  python3 get-pip.py && \
  ln -s /usr/bin/python3 /usr/local/bin/python && \
  ln -s /usr/bin/pip3 /usr/local/bin/pip && \
  rm -rf get-pip.py && \
  ln -vfs /usr/include/libpng16 /usr/include/libpng && \
  ln -vfs /usr/include/locale.h /usr/include/xlocale.h && \
  # Install NumPy
  pip install --no-cache-dir numpy && \
# Install OpenCV
  mkdir -p /opt && cd /opt && \
  wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
  unzip ${OPENCV_VERSION}.zip && rm ${OPENCV_VERSION}.zip && \
  cd /opt/opencv-${OPENCV_VERSION} && mkdir build && cd build && \
  cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D BUILD_opencv_python2=OFF \
    -D CMAKE_C_COMPILER=/usr/bin/clang \
    -D CMAKE_CXX_COMPILER=/usr/bin/clang++ \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D EIGEN_INCLUDE_PATH=/usr/include/eigen3 \
    -D PYTHON3_LIBRARY=`find /usr -name libpython3.so` \
    -D OPENCV_ENABLE_NONFREE=OFF \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D INSTALL_C_EXAMPLES=OFF \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D BUILD_EXAMPLES=OFF \
    -D BUILD_DOCS=OFF \
    -D WITH_GPHOTO2=ON \
    -D WITH_GSTREAMER=ON \
    -D WITH_EIGEN=ON \
    -D WITH_FFMPEG=ON \
    -D WITH_TBB=ON \
    -D WITH_V4L=ON \
    # -D OPENCV_EXTRA_MODULES_PATH=/opt/opencv-${OPENCV_VERSION}/modules \
    -D PYTHON_EXECUTABLE=/usr/local/bin/python .. && \
  make -j$(nproc) && make install && ln -s /usr/local/include/opencv4/opencv2/ /usr/local/include/opencv2  && rm -rf /opt/*  && \
# Make sure it's built properly
  apk del --purge .build-dep1 .build-dep2 && rm -rf /var/cache/apk/* && \
  pip uninstall setuptools wheel \
  # cp -p $(find /usr/local/lib/python3.8/site-packages -name cv2.*.so) \
  #  /usr/lib/python3.8/site-packages/cv2.so
  #  python -c 'import cv2; print("Python: import cv2 - SUCCESS")' \