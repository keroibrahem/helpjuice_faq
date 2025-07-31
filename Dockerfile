# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.1.4
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# تثبيت الحزم الأساسية
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        curl libjemalloc2 libvips postgresql-client libgmp-dev build-essential git libpq-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists/*

# تثبيت bundler
RUN gem install bundler -v 2.3.26

# نسخ ملفات الـ Gemfile لتثبيت الجواهر
COPY Gemfile Gemfile.lock ./

RUN bundle config set deployment 'false' && bundle install

# نسخ باقي ملفات المشروع
COPY . .

# نسخ السكريبت الخاص بالـ entrypoint لتشغيل precompile وقت التشغيل
COPY entrypoint.sh /rails/entrypoint.sh
RUN chmod +x /rails/entrypoint.sh

# استخدام entrypoint.sh كنقطة دخول للحاوية
ENTRYPOINT ["/rails/entrypoint.sh"]

# فتح البورت المناسب (مثلاً 3000 أو 80 حسب سيرفرك)
EXPOSE 3000

# الأمر الافتراضي لتشغيل السيرفر (puma هنا مثال)
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
