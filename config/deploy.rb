# config valid for current version and patch releases of Capistrano
lock "~> 3.19.1"

set :application, "react-rails-crud-app"
set :repo_url, "git@github.com:Mishal-Naeem/aws-deploy-app.git"
set :deploy_to, "/var/www/#{fetch(:application)}"

set :branch, :master 
set :pty, true
set :linked_files, %w{config/database.yml config/master.key}
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "public/uploads"

# Number of releases to keep on the server
set :keep_releases, 5
# Ruby version
set :rbenv_ruby, '3.1.0' # Adjust according to your setup

# Nginx and Puma tasks
namespace :deploy do
  namespace :check do
    before :linked_files, :set_master_key do
      on roles(:app), in: :sequence, wait: 10 do
        unless test("[ -f #{shared_path}/config/master.key ]")
          upload! 'config/master.key', "#{shared_path}/config/master.key"
        end
      end
    end
  end

  desc 'Restart application'
  task :restart do
    invoke 'puma:restart'
  end

  after :publishing, :restart
end  