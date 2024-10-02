# config valid for current version and patch releases of Capistrano
lock "~> 3.19.1"

set :application, "react-rails-crud-app"
set :repo_url, "git@github.com:Mishal-Naeem/aws-deploy-app.git"
set :deploy_to, "/var/www/#{fetch(:application)}"

set :branch, :master 
set :pty, true
set :linked_files, %w{config/database.yml config/master.key}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads}
set :keep_releases, 5

set :secret_key_base, ENV['SECRET_KEY_BASE'] || 'your_default_secret_key_base'

namespace :deploy do
  desc 'Upload database.yml and master.key'
  task :upload_config do
    on roles(:app) do
      upload! 'config/database.yml', "#{shared_path}/config/database.yml"
      upload! 'config/master.key', "#{shared_path}/config/master.key"
    end
  end

  desc 'Run assets:precompile'
  task :assets_precompile do
    on roles(:web) do
      within release_path do
        execute "SECRET_KEY_BASE=#{fetch(:secret_key_base)} bundle exec rake assets:precompile"
      end
    end
  end

  before :starting, :check_revision
  before 'deploy:check:linked_files', 'deploy:upload_config'
  before 'deploy:updated', 'deploy:assets_precompile'
  
  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  after :finishing, :cleanup
  after :finishing, :restart
end
