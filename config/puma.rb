# config/puma.rb
workers Integer(ENV.fetch("WEB_CONCURRENCY") { 2 })
max_threads = Integer(ENV.fetch("RAILS_MAX_THREADS") { 5 })
min_threads = Integer(ENV.fetch("RAILS_MIN_THREADS") { max_threads })
threads min_threads, max_threads

worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }

pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

plugin :tmp_restart

preload_app!