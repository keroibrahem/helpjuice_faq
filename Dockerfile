

ARG RUBY_VERSION=3.1.4
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# تثبيت الحزم الأساسية
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        curl \
        libjemalloc2 \
        libvips \
        postgresql-client \
        libgmp-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# تثبيت mutex_m (مطلوب في بعض النسخ)
RUN gem install mutex_m

# إعداد متغيرات البيئة العامة
ARG RAILS_MASTER_KEY
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_VERSION="2.3.26" \
    RAILS_LOG_TO_STDOUT="1" \
    LANG="C.UTF-8" \
    RAILS_MASTER_KEY=$RAILS_MASTER_KEY

# =============================
FROM base AS build

# تثبيت حزم البناء المطلوبة
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        build-essential \
        git \
        libpq-dev \
        libyaml-dev \
        pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# تثبيت bundler والإضافات المطلوبة
RUN gem install bundler -v 2.3.26 && \
    gem install bigdecimal -v 3.1.4 && \
    gem install logger -v 1.5.0

# نسخ ملفات الجيم (للاستفادة من الـ cache)
COPY Gemfile Gemfile.lock ./

# تثبيت الـ gems
RUN bundle _2.3.26_ config set --local deployment 'false' && \
    bundle _2.3.26_ install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# إضافة Logger يدوياً (في بعض الإصدارات بيحصل conflict)
RUN mkdir -p config/initializers && \
    echo "require 'logger'" > config/initializers/00_logger.rb && \
    echo "module ActiveSupport; module LoggerThreadSafeLevel; end; end" >> config/initializers/00_logger.rb && \
    echo "ActiveSupport::LoggerThreadSafeLevel.include(Logger::Severity)" >> config/initializers/00_logger.rb

# نسخ التطبيق بالكامل
COPY . .

# تجهيز bootsnap
RUN bundle exec bootsnap precompile app/ lib/

# تعديل الصلاحيات ومعالجة line endings
RUN chmod +x bin/* && \
    sed -i "s/\r$//g" bin/* && \
    sed -i 's/ruby\.exe$/ruby/' bin/*

# تجميع الأصول مع fallback لو فشل أول مرة
RUN bundle exec rails assets:precompile || \
    (bundle exec rails assets:clobber && \
     bundle exec rails runner "require 'mutex_m'; require 'bigdecimal';" && \
     SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile)

# =============================
FROM base

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# إنشاء مستخدم عادي
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp

USER 1000:1000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:80/up || exit 1

# إعدادات الدخول
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
