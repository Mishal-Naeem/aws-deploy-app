# config valid for current version and patch releases of Capistrano
lock "~> 3.19.1"

set :application, "react-rails-crud-app"
set :repo_url, "git@github.com:Mishal-Naeem/aws-deploy-app.git"
set :deploy_to, "/var/www/#{fetch(:application)}"

set :branch, :master 
set :pty, true
set :linked_files, %w{config/database.yml config/master.key}
set :keep_releases, 5

set :secret_key_base, ENV['SECRET_KEY_BASE'] || 1

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
      execute :gem, "install bundler -v '2.5.14' || true"
    end
  end

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
  desc 'Run assets:precompile'
    task :assets_precompile do
      on roles(:web) do
        within release_path do
          execute "SECRET_KEY_BASE=#{fetch(:secret_key_base)} bundle exec rake assets:precompile"
        end
      end
    end
  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
  after :finishing, 'deploy:cleanup'
end

# namespace :deploy do
#   desc 'Run assets:precompile'
#   task :assets_precompile do
#     on roles(:web) do
#       within release_path do
#         execute "SECRET_KEY_BASE=#{fetch(:secret_key_base)} bundle exec rake assets:precompile"
#       end
#     end
#   end

#   before 'deploy:updated', 'deploy:assets_precompile'
#   desc "Make sure local git is in sync with remote."
#   task :check_revision do
#     on roles(:app) do
#       unless `git rev-parse HEAD` == `git rev-parse origin/master`
#         puts "WARNING: HEAD is not the same as origin/master"
#         puts "Run `git push` to sync changes."
#         exit
#       end
#       execute :gem, "install bundler -v '2.3.3' || true"
#     end
#   end

#   desc 'Run bundle install'
#   task :bundle_install do
#     on roles(:web) do
#       within release_path do
#         execute "bundle install"
#       end
#     end
#   end

#   before 'deploy:updated', 'deploy:check_revision'
#   after 'deploy:check_revision', 'deploy:bundle_install'


#   desc 'Initial Deploy'
#   task :initial do
#     on roles(:app) do
#       before 'deploy:restart', 'puma:start'
#       invoke 'deploy'
#     end
#   end

#   desc 'Restart application'
#   task :restart do
#     on roles(:app), in: :sequence, wait: 5 do
#       invoke 'puma:restart'
#     end
#   end

#   before :starting,     :check_revision
#   # after  :finishing,    :compile_assets
  
#   after  :finishing,    :cleanup
#   after  :finishing,    :restart
# end

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure




# config valid for current version and patch releases of Capistrano
# lock "~> 3.19.1"

# set :application, "react-rails-crud-app"
# set :repo_url, "git@github.com:Mishal-Naeem/aws-deploy-app.git"
# set :deploy_to, "/var/www/#{fetch(:application)}"

# set :branch, :master 
# set :pty, true
# set :linked_files, %w{config/database.yml config/master.key}
# # set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads}
# set :keep_releases, 5

# set :secret_key_base, ENV['SECRET_KEY_BASE'] || 1

# namespace :deploy do
#   desc "Make sure local git is in sync with remote."
#   task :check_revision do
#     on roles(:app) do
#       unless `git rev-parse HEAD` == `git rev-parse origin/master`
#         puts "WARNING: HEAD is not the same as origin/master"
#         puts "Run `git push` to sync changes."
#         exit
#       end
#       execute :gem, "install bundler -v '2.5.14' || true"
#     end
#   end

#   desc 'Upload database.yml and master.key'
#   task :upload_config do
#     on roles(:app) do
#       upload! 'config/database.yml', "#{shared_path}/config/database.yml"
#       upload! 'config/master.key', "#{shared_path}/config/master.key"
#     end
#   end

#   desc 'Run assets:precompile'
#   task :assets_precompile do
#     on roles(:web) do
#       within release_path do
#         execute "SECRET_KEY_BASE=#{fetch(:secret_key_base)} bundle exec rake assets:precompile"
#       end
#     end
#   end

#   before :starting, :check_revision
#   before 'deploy:check:linked_files', 'deploy:upload_config'
#   before 'deploy:updated', 'deploy:assets_precompile'
  
#   desc 'Initial Deploy'
#   task :initial do
#     on roles(:app) do
#       before 'deploy:restart', 'puma:start'
#       invoke 'deploy'
#     end
#   end

#   desc 'Restart application'
#   task :restart do
#     on roles(:app), in: :sequence, wait: 5 do
#       invoke 'puma:restart'
#     end
#   end

#   after :finishing, :cleanup
#   after :finishing, :restart
# end
