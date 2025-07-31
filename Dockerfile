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
    RAILS_LOG_TO_STDOUT="1" \
    LANG="C.UTF-8"

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

# Install logger gem first to prevent threading issues
RUN gem install logger -v 1.5.0

# Copy Gemfiles first for better caching
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Critical Logger fix
RUN mkdir -p config/initializers && \
    echo "require 'logger'" > config/initializers/00_logger.rb && \
    echo "ActiveSupport::LoggerThreadSafeLevel.include(Logger::Severity) if defined?(ActiveSupport::LoggerThreadSafeLevel)" >> config/initializers/00_logger.rb

# Copy application code
COPY . .

# Precompile bootsnap
RUN bundle exec bootsnap precompile app/ lib/

# Fix line endings and permissions
RUN chmod +x bin/* && \
    sed -i "s/\r$//g" bin/* && \
    sed -i 's/ruby\.exe$/ruby/' bin/*

# Assets precompile with enhanced fallback
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile || \
    (bundle exec rails assets:clobber && \
     bundle exec rails runner "require 'logger'; ActiveSupport::LoggerThreadSafeLevel.include(Logger::Severity)" && \
     SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile)

FROM base

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Create non-root user
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rai# syntax=docker/dockerfile:1
    ARG RUBY_VERSION=3.4.4
    FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base
    
    WORKDIR /rails
    
    # Install base packages
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
        RAILS_LOG_TO_STDOUT="1" \
        LANG="C.UTF-8"
    
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
    
    # Install logger gem first
    RUN gem install logger -v 1.5.0
    
    # Copy Gemfiles
    COPY Gemfile Gemfile.lock ./
    
    # Install gems
    RUN bundle install && \
        rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git
    
    # Logger fix
    RUN mkdir -p config/initializers && \
        echo "require 'logger'" > config/initializers/00_logger.rb && \
        echo "module ActiveSupport; module LoggerThreadSafeLevel; Logger = ::Logger; end; end" >> config/initializers/00_logger.rb && \
        echo "ActiveSupport::LoggerThreadSafeLevel.include(Logger::Severity) if defined?(ActiveSupport::LoggerThreadSafeLevel)" >> config/initializers/00_logger.rb
    
    # Copy application code
    COPY . .
    
    # Precompile bootsnap
    RUN bundle exec bootsnap precompile app/ lib/
    
    # Fix permissions
    RUN chmod +x bin/* && \
        sed -i "s/\r$//g" bin/* && \
        sed -i 's/ruby\.exe$/ruby/' bin/*
    
    # Assets precompile with comprehensive fallback
    RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile || \
        (bundle exec rails assets:clobber && \
         bundle exec rails runner "require 'logger'; module ActiveSupport; module LoggerThreadSafeLevel; Logger = ::Logger; end; end; ActiveSupport::LoggerThreadSafeLevel.include(Logger::Severity)" && \
         SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile)
    
    FROM base
    
    COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
    COPY --from=build /rails /rails
    
    # Create non-root user
    RUN groupadd --system --gid 1000 rails && \
        useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
        chown -R rails:rails db log storage tmp
    USER 1000:1000
    
    HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
        CMD curl -f http://localhost:80/up || exit 1
    
    ENTRYPOINT ["/rails/bin/docker-entrypoint"]
    EXPOSE 80
    CMD ["./bin/thrust", "./bin/rails", "server"]ls db log storage tmp
USER 1000:1000

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:80/up || exit 1

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]