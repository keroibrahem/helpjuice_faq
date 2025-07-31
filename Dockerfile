# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.4.4
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Install base packages (including logger dependencies)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libjemalloc2 \
    libvips \
    postgresql-client \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_VERSION="2.3.26" \
    RAILS_LOG_TO_STDOUT="1"

FROM base AS build

# Install build dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libpq-dev \
    libyaml-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install specific bundler version first
RUN gem install bundler -v 2.3.26

# Copy Gemfiles first for better caching
COPY Gemfile Gemfile.lock ./

# Install gems with correct bundler version
RUN bundle _2.3.26_ install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Temporary logger fix
RUN mkdir -p config/initializers && \
    echo "require 'logger'" > config/initializers/00_logger.rb && \
    echo "Logger ||= ::Logger" >> config/initializers/00_logger.rb

# Copy application code
COPY . .

# Precompile bootsnap
RUN bundle exec bootsnap precompile app/ lib/

# Fix line endings and permissions
RUN chmod +x bin/* && \
    sed -i "s/\r$//g" bin/* && \
    sed -i 's/ruby\.exe$/ruby/' bin/*

# Assets precompile with fallback
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile || \
    (bundle exec rails assets:clobber && \
     SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile)

FROM base

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]