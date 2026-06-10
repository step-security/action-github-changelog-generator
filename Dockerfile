FROM ruby:3.4-alpine@sha256:8a962e98ec8b999097accdf3bdc564c7a5f67360f4d418c0074e7fa49b148185 AS builder

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk add --no-cache git

WORKDIR /
COPY Gemfile Gemfile
RUN apk add --no-cache \
  --virtual .gem-installdeps \
  build-base \
  && bundle config set --local system 'true' \
  && bundle install \
  && rm Gemfile Gemfile.lock \
  && rm -rf "$GEM_HOME"/cache \
  && apk del .gem-installdeps

FROM ruby:3.4-alpine@sha256:8a962e98ec8b999097accdf3bdc564c7a5f67360f4d418c0074e7fa49b148185

RUN apk add --no-cache \
  git \
  bash \
  curl \
  jq

COPY --from=builder /usr/local/bundle /usr/local/bundle

ENV SRC_PATH /usr/local/src/your-app
RUN mkdir -p "${SRC_PATH}"

VOLUME [ "$SRC_PATH" ]
WORKDIR $SRC_PATH

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
