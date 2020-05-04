ARG VERSION=2.20.0

########################################################################################
# Build LilyPond on the latest Ubuntu. Unfortunately compiling does not work on alpine.
########################################################################################
FROM ubuntu AS build-basic
ARG VERSION
ARG DEBIAN_FRONTEND=noninteractive

# Install Build Dependencies
RUN apt-get -qq --yes update && \
    # LilyPond Build Dependencies
    # See http://lilypond.org/doc/v2.20/Documentation/topdocs/INSTALL#other
    apt-get -qq --yes install \
        build-essential \
        python-dev \
        autoconf \
        pkg-config \
        bison \
        flex \
        gettext \
        make \
        texlive-base \
        texlive-metapost \
        perl \
        texinfo \
        fontforge \
        t1utils \
        texlive-lang-cyrillic \
        libpango1.0-dev \
        # The following dependencies are required to build guile
        libtool \
        libgmp-dev \
        libreadline-dev \
        # Use curl to download additional resources
        curl

WORKDIR /build
RUN curl -fsSL https://ftp.gnu.org/gnu/guile/guile-1.8.8.tar.gz | tar -xz  && \
    curl -fsSLO http://www.gust.org.pl/projects/e-foundry/tex-gyre/whole/tg2_501otf.zip && \
    unzip -q tg2_501otf.zip && \
    curl -fsSL https://lilypond.org/download/sources/v${VERSION%.*}/lilypond-$VERSION.tar.gz | tar -xz

ENV PATH="/opt/bin:$PATH" PKG_CONFIG_PATH="/opt/lib/pkgconfig:$PKG_CONFIG_PATH"

# Install Guile 1.8.8
WORKDIR /build/guile-1.8.8
RUN ./configure --prefix=/opt --disable-error-on-warning && \
    make -s -j$(($(nproc)+1)) && \
    make -s install

# Install LilyPond
WORKDIR "/build/lilypond-$VERSION"
RUN ./autogen.sh --prefix=/opt --disable-documentation --with-texgyre-dir=/build/tg2_501otf && \
    make -s -j$(($(nproc)+1)) && \
    make -s install


########################################################################################
# Install runtime dependencies and copy the build artifacts from the previous stage.
########################################################################################
FROM ubuntu AS basic
ARG VERSION
LABEL maintainer="Kim Wittenburg <codello@wittenburg.kim>" version="$VERSION"

RUN apt-get -qq --yes update && \
    apt-get -qq --yes install \
        libfontconfig1 \
        libfreetype6 \
        ghostscript \
        libpangoft2-1.0 \
        libltdl7 \
        python-minimal && \
    # Update Fonts
    apt-get -qq --yes purge --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build-basic /opt /opt
ENV PATH="/opt/bin:$PATH" LD_LIBRARY_PATH="/opt/lib:$LD_LIBRARY_PATH"

WORKDIR /ly
ENTRYPOINT ["lilypond"]


########################################################################################
# Install Microsoft fonts in a new ubuntu environment
########################################################################################
FROM ubuntu AS build-fonts

# Install Additional Fonts
WORKDIR /build/msfonts
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
    apt-get -qq --yes update && \
    apt-get -qq --yes install \
        wget \
        ttf-dejavu \
        ttf-mscorefonts-installer && \
    # This fix is taken from here:
    # https://askubuntu.com/questions/1163560/change-mirror-for-ttf-mscorefonts-installer
    awk '/Url/ {sub("downloads[.]sourceforge[.]net/corefonts","cfhcable.dl.sourceforge.net/project/corefonts/the%20fonts/final",$2); system("wget "$2)}' /usr/share/package-data-downloads/ttf-mscorefonts-installer && \
    /usr/lib/msttcorefonts/update-ms-fonts $(pwd)/*.exe


########################################################################################
# Copy fonts into the final image.
########################################################################################
FROM basic AS fonts
ARG VERSION

COPY --from=build-fonts /usr/share/fonts /usr/share/fonts
COPY ./fonts/*/supplementary-fonts/*.otf ./fonts/*/supplementary-files/*/*.otf /usr/share/fonts/opentype/
COPY ./fonts/*/supplementary-fonts/*.ttf ./fonts/*/supplementary-files/*/*.ttf /usr/share/fonts/truetype/
COPY ./fonts/*/stylesheet/* "/opt/share/lilypond/$VERSION/ly/"
COPY ./fonts/*/otf ./fonts/*/woff "/opt/share/lilypond/$VERSION/fonts/otf/"
COPY ./fonts/*/svg/* "/opt/share/lilypond/$VERSION/fonts/svg/"


########################################################################################
# The shell image is useful in CI and other non-interactive environments where you might
# want to execute more than one lilypond command.
########################################################################################
FROM fonts AS shell
RUN apt-get -qq --yes update && \
    apt-get -qq --yes install \
        make \
        jq \
        unzip \
        curl \
        ca-certificates && \
    apt-get -qq --yes purge --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT []