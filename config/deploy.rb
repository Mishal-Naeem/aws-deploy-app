# config valid for current version and patch releases of Capistrano
lock "~> 3.19.1"

set :application, "react-rails-crud-app"
set :repo_url, "git@github.com:Mishal-Naeem/aws-deploy-app.git"

set :deploy_to, '/home/deploy/myapp'
set :puma_bind, 'tcp://0.0.0.0:9292'

append :linked_files, 'config/database.yml', 'config/master.key'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'public/system', 'public/uploads'

set :keep_releases, 5

namespace :deploy do
  desc 'Upload database.yml to shared/config'
  task :upload_database_yml do
    on roles(:app) do
      upload! 'config/database.yml', "#{shared_path}/config/database.yml"
    end
  end
  before 'deploy:check:linked_files', 'deploy:upload_database_yml'

  after :publishing, :restart do
    invoke 'puma:restart'
  end
end
