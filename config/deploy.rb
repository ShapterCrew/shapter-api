# config valid only for Capistrano 3.1
#lock '3.2.0'

set :default_shell, "bash -l"

set :application, 'shapter_api'
set :repo_url, 'git@github.com:ShapterCrew/shapter-api.git'

set :user, 'ubuntu'
set :ssh_options,{
  forward_agent: true,
  port: 22,
  #verbose: :debug,
  user: fetch(:user),
}

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
 set :deploy_to, '/var/www/shapter_api'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
 set :linked_files, %w{config/mongoid.yml config/initializers/behave_io.rb config/initializers/secret_token.rb config/initializers/aws_credentials.rb}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
 set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle }

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 2 do
      # Your restart mechanism here, for example:
       execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  desc "restart delayed_job daemon"
  after :restart, :clear_cache do
    on roles(:app), in: :groups, limit: 3, wait: 1 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
      within release_path do 
        with rails_env: :production do 
          execute :bundle, :exec, :"bin/delayed_job", :restart
        end
      end
    end
  end

end
