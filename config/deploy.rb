# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'kavau'

set :scm, :git
set :repo_url, 'git@github.com:robbytobby/kavau.git'

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'config/settings.yml', 'app/assets/images/logo.png')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/fonts')

# Default value for default_env is {}
set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do
  after :deploy, :restart, :remove_tmp
  before :restart, :setup_pdf_dirs

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
      #invoke 'delayed_job:restart'
    end
  end

  desc "Remove tmp-dir"
  task :remove_tmp do
    on roles(:app) do
      execute 'rm -r /tmp/kavau'
    end
  end

  desc 'Setup required directories for pdfs'
  task :setup_pdf_dirs do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'setup:pdf_dirs'
        end
      end
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end
