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
 set :linked_files, %w{config/mongoid.yml config/initializers/secret_token.rb config/initializers/aws_credentials.rb}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
 set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle }

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
  after :restart, :start_delayed_job_deamon do
    on roles(delayed_job_roles) do
      within release_path do 
        with rails_env: fetch(:rails_env) do 
          execute :bundle, :exec, :'bin/delayed_job', args, :restart
        end
      end
    end
    #on roles(:web), in: :groups, limit: 3, wait: 10 do
    #  # Here we can do anything such as:
    #  # within release_path do
    #  #   execute :rake, 'cache:clear'
    #  # end
    #end
  end

end
