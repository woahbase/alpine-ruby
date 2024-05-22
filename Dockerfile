# syntax=docker/dockerfile:1
#
ARG IMAGEBASE=frommakefile
#
FROM ${IMAGEBASE}
#
ENV \
    LANG=C.UTF-8 \
    GEM_HOME=/usr/local/bundle \
    BUNDLE_SILENCE_ROOT_WARNING=1
#
RUN set -xe \
    && apk add --no-cache --purge -uU --virtual .build-deps \
        libc-dev \
        libffi-dev \
        linux-headers \
        build-base \
    && apk add --no-cache --purge -uU \
        ca-certificates \
        git \
        tzdata \
        ruby \
        ruby-bigdecimal \
        ruby-dev \
        ruby-libs \
        # ruby-bundler \
        # ruby-irb \
        # ruby-rake \
    && mkdir -p "$GEM_HOME" && chmod 1777 "$GEM_HOME" \
    && echo 'gem: --no-document' > /etc/gemrc \
    && echo 'install: --no-document' >> /etc/gemrc \
    && echo 'update: --no-document' >> /etc/gemrc \
# Install and upgrade packages
    && gem update --system \
    && gem install bundler irb json rake \
    && gem cleanup \
    && apk del --purge .build-deps ruby-dev \
    && rm -rf /usr/lib/ruby/gems/*/cache/* \
    && rm -rf /var/cache/apk/* /tmp/*
#
ENV \
    BUNDLE_APP_CONFIG="$GEM_HOME" \
    PATH=$GEM_HOME/bin:$PATH
#
COPY root/ /
#
ENTRYPOINT ["/usershell"]
#
CMD ["ruby", "--version"]
