FROM ubuntu
ARG VERSION=2.20.0

LABEL maintainer="Kim Wittenburg <codello@wittenburg.kim>" version="$VERSION"

# Install Packages and System Fonts
RUN apt-get update --yes \
    && echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections \
    && apt-get install --yes \
        curl \
        make \
        ttf-mscorefonts-installer \
        fontconfig \
        sudo \
    # Update Fonts
    && apt-get -y purge --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/*

# Download and Install LilyPond
ADD http://lilypond.org/download/binaries/linux-64/lilypond-$VERSION-1.linux-64.sh lilypond.sh
RUN sh lilypond.sh --batch \
    && rm -f lilypond.sh

COPY ./fonts/*/otf ./fonts/*/woff \
    /usr/local/lilypond/usr/share/lilypond/current/fonts/otf/
COPY ./fonts/*/svg/* /usr/local/lilypond/usr/share/lilypond/current/fonts/svg/
COPY ./fonts/*/stylesheet/* /usr/local/lilypond/usr/share/lilypond/current/ly/
COPY ./fonts/*/supplementary-fonts ./fonts/*/supplementary-files/*/*.otf \
    /usr/share/fonts/
    
# Run as non-root user and allow passwordless sudo
RUN useradd --shell /bin/bash lilypond && \
    echo "lilypond ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/lilypond && \
    chmod 0440 /etc/sudoers.d/lilypond && \
    mkdir /ly && \
    chown lilypond:lilypond /ly

USER lilypond
WORKDIR /ly

ENTRYPOINT ["lilypond"]
