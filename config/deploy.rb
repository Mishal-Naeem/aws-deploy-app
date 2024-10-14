# config valid for current version and patch releases of Capistrano
lock "~> 3.19.1"

set :application, "react-rails-crud-app"
set :repo_url, "git@github.com:Mishal-Naeem/aws-deploy-app.git"
set :user,     'deploy'

set :deploy_to, '/home/deploy/myapp'
set :puma_bind, 'tcp://0.0.0.0:9292'
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(/home/ads/Downloads/connecthub.pem) }
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_socket, "#{shared_path}/tmp/sockets/puma.sock"
set :puma_workers, 2
append :linked_files, 'config/database.yml', 'config/master.key'
#append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'public/system', 'public/uploads'

set :keep_releases, 5

namespace :puma do
  desc 'Start Puma'
  task :start do
    on roles(:app) do
      within release_path do
        execute :bundle, 'exec puma -C config/puma.rb -e production'
      end
    end
  end


  after 'deploy:publishing', 'puma:start'

  desc 'Restart Puma'
  task :restart do
    on roles(:app) do
      if test("[ -f #{fetch(:puma_pid)} ]")
        execute "kill -USR1 $(cat #{fetch(:puma_pid)})"
      else
        warn "Puma is not running, starting it instead."
        invoke 'puma:start'
      end
    end
  end
end

namespace :deploy do
  desc 'Upload database.yml to shared/config'
  task :upload_database_yml do
    on roles(:app) do
      upload! 'config/database.yml', "#{shared_path}/config/database.yml"
    end
  end
  before 'deploy:check:linked_files', 'deploy:upload_database_yml'

  namespace :db do
    desc 'Create the database'
    task :create do
      on roles(:db) do
        within release_path do
          execute :rake, 'db:create RAILS_ENV=production'
        end
      end
    end
  
    desc 'Run migrations'
    task :migrate do
      on roles(:db) do
        within release_path do
          execute :rake, 'db:migrate RAILS_ENV=production'
        end
      end
    end
  
    desc 'Seed the database'
    task :seed do
      on roles(:db) do
        within release_path do
          execute :rake, 'db:seed RAILS_ENV=production'
        end
      end
    end
  end
  before 'deploy:migrate', 'db:create'

  after :publishing, :restart do
    invoke 'puma:restart'
  end
end
