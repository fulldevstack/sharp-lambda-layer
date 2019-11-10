FROM lambci/lambda:build-nodejs10.x

ARG AWS_REGION
ARG LAYER_NAME
ARG ZIP_FILE_NAME
ARG LD_LIBRARY_PATH=/var/task/lib
ARG PKG_CONFIG_PATH=/var/task/lib/pkgconfig
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH} \
    PKG_CONFIG_PATH=${PKG_CONFIG_PATH}

# Instal Build Dependencies
RUN yum install -y \
  wget \
  yum-utils \
  rpmdevtools \
  glib2-devel \
  pango-devel \
  libjpeg-turbo-devel \
  giflib-devel \
  poppler-glib-devel \
  librsvg2-devel \
  libgsf-devel \
  libtiff-devel \
  libpng-devel \
  zlib-devel  \
  && mkdir -p /var/task/lib \
  && mkdir -p /var/task/nodejs

## Install Vips Dependencies
WORKDIR /tmp
RUN yumdownloader \
      glib2.x86_64 \
      libjpeg-turbo.x86_64 \
      pango.x86_64 \
      giflib.x86_64 \
      poppler-glib.x86_64 \
      freetype.x86_64 \
      librsvg.x86_64 \
      libgsf.x86_64 \
      libtiff.x86_64 \
      libpng.x86_64 \
      ## Second Additions
      libz.x86_64 \
      libexpat.x86_64 \
      libfontconfig.x86_64 \
      libxml2.x86_64 \
      librsvg-2.x86_64 \
      libgdk_pixbuf-2.0.x86_64 \
      libcairo.x86_64 \
      libstdc++.x86_64 \
      libm.x86_64 \
      libc.x86_64 \
      libgcc_s.x86_64 \
      libjbig.x86_64 \
      libdl.x86_64 \
      libpcre.x86_64 \
      libpthread.x86_64 \
      libthai.x86_64 \
      libharfbuzz.x86_64 \
      libbz2.x86_64 \
      liblzma.x86_64 \
      libSM.x86_64 \
      libICE.x86_64 \
      libX11.x86_64 \
      libcroco-0.6.x86_64 \
      libpoppler.x86_64 \
      liblcms2.x86_64 \
      libopenjpeg.x86_64 \
      libffi.x86_64 \
      libselinux.x86_64 \
      libresolv.x86_64 \
      libmount.x86_64 \
      libpixman-1.x86_64 \
      libEGL.x86_64 \
      libxcb-shm.x86_64 \
      libxcb.x86_64 \
      libxcb-render.x86_64 \
      libXrender.x86_64 \
      libXext.x86_64 \
      libGL.x86_64 \
      librt.x86_64 \
      libgraphite2.x86_64 \
      libuuid.x86_64 \
      libblkid.x86_64 \
      libGLdispatch.x86_64 \
      libXau.x86_64 \
      libGLX.x86_64 \
    && rpmdev-extract *rpm \
    && cp /usr/lib64/libz.so.1  \
          /usr/lib64/libexpat.so.1 \
          /usr/lib64/libfontconfig.so.1 \
          /usr/lib64/librsvg-2.so.2 \
          /usr/lib64/libgdk_pixbuf-2.0.so.0 \
          /usr/lib64/libcairo.so.2 \
          /usr/lib64/libm.so.6 \
          /usr/lib64/libc.so.6 \
          /usr/lib64/libgcc_s.so.1 \
          /usr/lib64/libjbig.so.2.0 \
          /usr/lib64/libdl.so.2 \
          /usr/lib64/libpcre.so.1 \
          /usr/lib64/libpthread.so.0 \
          /usr/lib64/libharfbuzz.so.0 \
          /usr/lib64/libbz2.so.1 \
          /usr/lib64/liblzma.so.5 \
          /usr/lib64/libcroco-0.6.so.3 \
          /usr/lib64/libpoppler.so.46 \
          /usr/lib64/liblcms2.so.2 \
          /usr/lib64/libopenjpeg.so.1 \
          /usr/lib64/libresolv.so.2 \
          /usr/lib64/libpixman-1.so.0 \
          /usr/lib64/libEGL.so.1 \
          /usr/lib64/libGL.so.1 \
          /usr/lib64/librt.so.1 \
          /usr/lib64/ld-linux-x86-64.so.2 \
          /usr/lib64/libgraphite2.so.3 \
          /usr/lib64/libGLdispatch.so.0 \
          /usr/lib64/libGLX.so.0 \
          /var/task/lib \
    && find ./*/usr/lib64/ -type f -exec cp {} /var/task/lib \;

## Instal VIPS
ARG VIPS_VERSION=8.8.0
ARG VIPS_URL=https://github.com/libvips/libvips/releases/download
RUN wget -qO- ${VIPS_URL}/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz | tar -xzv -C . \
  && cd vips-${VIPS_VERSION} \
  && ./configure \
    --prefix=/var/task \
    --with-giflib-libraries=/var/task/lib \
    --with-tiff-libraries=/var/task/lib \
    --with-jpeg-libraries=/var/task/lib \
  && make \
  && make install \
  && ldconfig

## Create zip bundle
WORKDIR /var/task
COPY package.json ./nodejs/
RUN cd nodejs \
  && npm i \
  && rm package.json \
  && cd ../ \
  && ls -a /var/task/lib \
  && zip -9qyr ${ZIP_FILE_NAME} nodejs lib

CMD aws --region ${AWS_REGION} lambda publish-layer-version --layer-name ${LAYER_NAME} --zip-file fileb://${ZIP_FILE_NAME}






