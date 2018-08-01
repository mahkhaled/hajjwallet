---
title: "Deploying to Ubuntu"
section: deployment
---

## Overview

This guide will walk you through configuring and deploying your Spree
application to an environment on Ubuntu 13.04.

This guide assumes an absolutely clean-slate Ubuntu 13.04 Server install, and
covers setting up the following things:

* A user for the application
* Operating system dependencies required for Ruby, Rails and Spree
* Ruby 2.3.0
* Rails 5.0.2
* PostgreSQL
* Unicorn + nginx (with SSL)
* Seed data for your store

## Initial Server Setup

The first thing you will need on your server is a user account on the server
which will be responsible for providing a container for your application's
install.

### A user account

***
For the purposes of this guide, the user's account on the system will be
called "spree", but you may choose to call it whatever you wish.
***

To set up this new user, run these commands on the server:

```bash
$ useradd -d /home/spree -m -s /bin/bash spree
$ passwd spree
```

Set a new password for the user and remember it, as you will require it in just a moment.

### Key-based authentication

The next thing to set up is secure key-based authentication on the server. This
will involve setting up a private key on your system, copying over the related
public key to the server, asserting that you can now login without providing a
password, and then disabling password authentication on the server to increase
security.

On the remote server, set up an `.ssh` directory to contain the new public key
for a user by running these commands:

```bash
$ mkdir /home/spree/.ssh
$ chown spree:spree /home/spree/.ssh
$ chmod 700 /home/spree/.ssh
```

This directory is used to authenticate key-based authentication when using SSH.

On your local machine, generate a private key using `ssh-keygen` like this:

```bash
$ ssh-keygen -t rsa
```

Set the filename to be [your home directory]/.ssh/spree_rsa.

You can choose to enter a password if you wish. All that would mean is that you would need to provide that password to use the key.

***
If you already have a private key, you can use that one.
***

Once you've finished generating this key, you will need to copy the public
version of this key over to the new server. To do this, run this command:

```bash
$ scp ~/.ssh/spree_rsa.pub spree@[your server's address]:~/.ssh/authorized_keys
```

The password you will need to enter here is the password for the user account on
the remote server.

Once you've set this up, you will then be able to use key-based authentication
to connect to the server:

```bash
$ ssh spree@[your server's address] -i [your home directory]/.ssh/spree_rsa
```

To save having to use the `-i` option here, you can place the following lines
inside `.ssh/config` on your local machine:

    Host [your server's address]
      IdentityFile ~/.ssh/spree_rsa

You should now follow the same steps for the `root` user on your server as well,
so that you can authenticate with the same key to access both the deployment
user and root accounts. You may choose to use a completely different key if you
wish.

Once you have verified -- by connecting via SSH to the remote server -- that
both accounts work without password authentication, you can now disable
password-based authentication.

To disable password-based authentication, you will need to uncomment this line
within `/etc/ssh/ssh_config` and change the "yes" value to "no":

    #PasswordAuthentication yes

It should be this when you're done:

    PasswordAuthentication no

Then you will need to restart the SSH daemon on the server, by running this
command:

```bash
$ service ssh restart
```

After this, if you attempt to run `ssh spree@localhost` from within the server
itself, it will return "Permission denied (publickey)", indicating that it has
not attempted to authenticate with a password, but instead with a publickey,
which the server does not have configured.

Now that the user is set up on your system and access to it and root's account
are locked down a bit tighter, it's time to set up Ruby.

## Operating System Dependencies and Ruby

To install Ruby, you are going to use the "RVM":http://rvm.io tool. This tool
provides a simple way of installing a version of Ruby onto your server.

To install it, run these commands:

```bash
$ curl -L https://get.rvm.io | bash -s stable
$ . ~/.bashrc
```

Next, you will need to install the operating system dependencies required for
Ruby. Run this command to install the dependencies:

```bash
rvm requirements
```

You will also need to install a JavaScript runtime. You can install the `nodejs`
package from `apt-get`:

```bash
$ apt-get install -y nodejs
```

Or, you can put a dependency for `therubyracer` gem into your `Gemfile`:

```ruby
group :production do
 gem 'therubyracer'
end
```

You will also need the `imagemagick` package, which is used to handle image
manipulation which is used when you upload product images in your store:

```bash
$ apt-get install -y imagemagick
```

Once these dependencies are installed, switch back into the `spree` user and
install Ruby 2.3.0 by running this command:

```bash
$ rvm install 2.3.0
```

This command will take a couple of minutes to finish running.

Once it's finished running, run this command to make that version of Ruby the
default for this user:

```bash
$ rvm use 2.3.0 --default
```

Ensure that this version of Ruby is really the new default by running this
command:

```bash
ruby -v
```

It should output something similar to this:

```bash
ruby 2.3.0p0 (2013-12-25 revision 44422) [x86_64-linux]
```

You now have a version of Ruby correctly configured on your server.

### Deploying to the server

The next step is to put your Spree application onto the server. To do this, you
will use the deployment tool called
[Capistrano](https://github.com/capistrano/capistrano/wiki). The instructions below describe how to do this using Capistrano version 2.x. If you wish to use version 3.x or higher, you should consult the documentation at [http://capistranorb.com](http://capistranorb.com).

First add the capistrano gem to the Gemfile located in the directory containing your Spree application:

```ruby
group :development do
 gem 'capistrano', '~> 2.0'
end
```
and to install the gem run the following command from that directory:
```bash
$ bundle install
```
In the same directory, run this command to set up a Capistrano deploy configuration:

```bash
$ capify .
```

This command will create two files: a `Capfile` and a `config/deploy.rb`. The
`config/deploy.rb` file is where you will be configuring how Capistrano chooses
to deploy your application. Open this file now and you will see the following
lines (comments removed):

```ruby
set :application, "set your application name here"
set :repository,  "set your repository location here"

set :scm, :subversion
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "your web-server here" # Your HTTP server, Apache/etc
role :app, "your app-server here" # This may be the same as your `Web` server
role :db,  "your primary db-server here", primary: true # This is where Rails migrations will run
role :db,  "your slave db-server here"
```

The contents of this file tell Capistrano about the deployment of your
application.

The `application` variable tells Capistrano the name of your application, and
the `repository` variable tells it where it can find the source of your
application. The `scm` variable tells Capistrano the type of source control
system you're using. If you're using Spree, there's a high chance that's going
to be `:git`, so change that over now. Change the `application` and `repository`
now to accurately reflect your application.

The next batch of things to configure in this file are the different "roles".
These tell Capistrano which servers play which roles within your server
architecture. Within this guide, you've been working with a single server and
will continue to do so. Therefore, these roles should look like this:

```ruby
server = "[your server's address]"
role :web, server
role :app, server
role :db,  server, primary: true
```

After this, you will need to tell Capistrano the account name to use for
deploying to your server. In this guide, we've used "spree" so far, but you may
have chosen to use something different. To tell Capistrano the user to use, put
this line inside your `config/deploy.rb`:

```ruby
set :user, "spree"
```

You will also need to tell it the path to deploy at. By default in Capistrano,
this path is `/u/apps/[application_name]`. There is probably no `/u/` directory on the
server, so that won't work for you immediately. You already have a
self-contained user account on the server, so deploying the application to that
user's home directory would make better sense. Add this line to
`config/deploy.rb` to do that:

```ruby
set :deploy_to, "/home/spree/#{application}"
```

You will also need to tell Capistrano to never use sudo, since you're going to
be operating as a user without sudo permission:

```ruby
set :use_sudo, false
```

Along with this, you will also need to tell it to use the `bash` shell, as you
will need access to the commands for gems such as `bundler`, which are provided
by RVM.

```ruby
default_run_options[:shell] = '/bin/bash --login'
```

And because all the Rails-specific commands are going to need to run on the
production environment, it'd be a great idea to add this to the configuration as
well:

```ruby
default_environment["RAILS_ENV"] = 'production'
```

With that configuration, your `config/deploy.rb` should look like this:

```ruby
set :application, "[name]"
set :repository,  "[repository]"
set :scm, :git
server = "[your server's address]"

role :web, server
role :app, server
role :db,  server, primary: true # This is where Rails migrations will run

set :user, "spree"

set :deploy_to, "/home/spree/#{application}"
set :use_sudo, false

default_run_options[:shell] = '/bin/bash --login'
default_environment["RAILS_ENV"] = 'production'
```

To set up the server for Capistrano, run `cap deploy:setup`. This will create
the required Capistrano directories for your application inside
`/home/spree/[name]`.

You will need to add another two lines to the top of this file as well so that
the application's gem dependencies are installed onto the server with Bundler,
and the assets are precompiled. These two lines are this:

```ruby
require "bundler/capistrano"
load "deploy/assets"
```

To attempt to deploy the actual application to the server, run `cap deploy`. If
the `repository` option points to GitHub, this will fail because the server has
never verified GitHub's host key.

    [[your server's address]] executing command
    ** [[your server's address] :: err] Host key verification failed.
    ** [[your server's address] :: err] fatal: The remote end hung up unexpectedly

To verify this, run this command:

```bash
$ ssh github.com
```

This will ask you to verify that GitHub's RSA key fingerprint is
`16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48`. If that's correct, type "yes"
to the prompt and GitHub's host key will now be verified.

When you run `cap deploy` again, you'll see this error:

    [[your server's address]] executing command
    ** [[your server's address] :: err] Permission denied (publickey).
    ** [[your server's address] :: err] fatal: The remote end hung up unexpectedly

This means that your application does not have a deploy key setup for it on
GitHub. To set up a deploy key for the application, run this command as the
"spree" user on the server:

```bash
$ ssh-keygen -t rsa
```

!!!
Do not enter a password for this key. Otherwise you will need to use it
every time you deploy.
!!!

Run `cat ~/.ssh/id_rsa.pub` on the server to get the deploy key. Go to your
application's repository on GitHub and go to "Settings", then "Deploy Keys" and
enter the whole key into the form there, giving it a memorable name if you ever
need it again.

When you run `cap deploy` again, Capistrano will clone your application's code
from GitHub to your server into a directory such as `/home/spree/[application's
name]/releases/[timestamp]`. Inside this directory -- because you're requiring
the `bundler/capistrano` tasks at the top of the `config/deploy.rb` file --
Capistrano will run `bundle install` with a couple of options, pointing Bundler
at the application's gemfile and placing the gems into a shared directory at
`/home/spree/[application]/shared/bundle`. This is so that every release of your
application can use the same bundle. This `bundle install` command will also not
install the development and test dependencies for your application, as you won't
need them on your production server.

The `cap deploy` command this time will also run an asset precompilation step,
thanks to the `deploy/assets` loading at the top of `config/deploy.rb`. This
step will compile the assets to the `public/assets` directory in the current
release's directory.

The next step is to set up a database server for the data for your Rails app.

## Setting up a database server

The database server we will be using in this guide will be the
"PostgreSQL":http://postgresql.org database server. Once this is setup, you will
be able to tell capistrano to run the migrations on your application, creating
the necessary tables for your Spree store.

To install PostgreSQL, run this command:

```bash
$ apt-get install -y postgresql
```

You will also need to install its development headers, which the `pg` gem will
use to connect to the database:

```bash
$ apt-get install -y libpq-dev
```

Once those two packages are installed, you will need to create a new database
for your application to use. This database should have the same name as the
server's deploy user account, which in this guide has been "spree" so far. Yours
could be different. To set up this database, run this command as `root`:

```bash
$ sudo -u postgres createdb spree
$ sudo -u postgres createuser spree
```

To get your application to connect to this database, you will need to set up a
`database.yml` file on the server. This file needs to be kept on the server in a
common location where it can be copied over into the latest deployed version of
the application, and so you should place it at `/home/spree/[application's
name]/shared/config/database.yml`. Inside this file, put this content:

```yaml
production:
  adapter: postgresql
  database: spree
  ```

If you're not already using the PostgreSQL adapter on your application, as
specified by `gem 'pg'` in your `Gemfile`, you'll need to add this gem to your
`Gemfile` now, inside a `production` group:

```ruby
group :production do
  gem 'pg'
end
```

***
If you need to add this gem, you will need to run `bundle install` on your
server and commit/push your `Gemfile` and `Gemfile.lock` to Git.
***

!!!
You should always develop and deploy on the same database adapter! If you don't,
you may run into incompatibility issues between your development and deployment
setups which can be difficult to track down.
!!!

Now when you run `cap deploy`, you will need Capistrano to automatically copy
over the `database.yml` file from the shared directory into the current deploy
path. To make Capistrano do this, put these lines into `config/deploy.rb` for
your application:

```ruby
task :symlink_database_yml do
  run "rm #{release_path}/config/database.yml"
  run "ln -sfn #{shared_path}/config/database.yml #{release_path}/config/database.yml"
end
after "bundle:install", "symlink_database_yml"
```

After `bundle install` has finished running on the server, Capistrano will now
copy over the `config/database.yml` into the current path. In order for
Capistrano to deploy *and* run your migrations, you will need to run `cap deploy`
and then `cap deploy:migrate`. Run those commands now. You should see
the migrations run on the server.

The next step is to set up the web server to serve requests for your
application.

## Setting up a web server

The web server you'll be using here will be the Unicorn web server which will
run the Rails application instances, and then those instances will have an nginx
frontend which will serve the requests coming from the people who are visiting
your store.

### Setting up Unicorn

To set up unicorn for your application, add the `unicorn` gem to your `Gemfile`,
inside the `production` group:

```ruby
group :production do
  gem 'pg'
  gem 'unicorn'
end
```

Unicorn requires some configuration in order to work, which belongs in
`config/unicorn.rb`. This is the content required for Unicorn:

```ruby
# config/unicorn.rb
# Set environment to development unless something else is specified
env = ENV["RAILS_ENV"] || "development"

# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete documentation.
worker_processes 4

# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy
listen "/tmp/[application's name].socket", backlog: 64

# Preload our app for more speed
preload_app true

# nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 30

pid "/tmp/unicorn.[application's name].pid"

# Production specific settings
if env == "production"
  # Help ensure your application will always spawn in the symlinked
  # "current" directory that Capistrano sets up.
  working_directory "/home/spree/[application's name]/current"

  # feel free to point this anywhere accessible on the filesystem user 'spree'
  shared_path = "/home/spree/[application's name]/shared"

  stderr_path "#{shared_path}/log/unicorn.stderr.log"
  stdout_path "#{shared_path}/log/unicorn.stdout.log"
end

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "/tmp/unicorn.[application's name].pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  # the following is *required* for Rails + "preload_app true"
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end
```

Remember to replace `[application's name]` above with your actual application
name. Run `bundle install` and commit and push your `Gemfile`, `Gemfile.lock`
and `config/unicorn.rb` files to Git.

Next, you will need to add tasks to Capistrano to ensure that the Unicorn
workers are restarted after a `cap deploy`. To do this, put these lines into
your `config/deploy.rb`:

```ruby
namespace :unicorn do
  desc "Zero-downtime restart of Unicorn"
  task :restart, except: { no_release: true } do
    run "kill -s USR2 `cat /tmp/unicorn.[application's name].pid`"
  end

  desc "Start unicorn"
  task :start, except: { no_release: true } do
    run "cd #{current_path} ; bundle exec unicorn_rails -c config/unicorn.rb -D"
  end

  desc "Stop unicorn"
  task :stop, except: { no_release: true } do
    run "kill -s QUIT `cat /tmp/unicorn.[application's name].pid`"
  end
end

after "deploy:restart", "unicorn:restart"
```

Commit your `config/deploy.rb` to Git, push the changes to GitHub and run `cap
deploy` again to ensure the latest code is available on your server. This will
include the `unicorn` gem which will be vital for the next step: setting up
nginx and getting it to serve requests from your application.

### Setting up nginx

To install nginx, run this command as `root`:

```bash
$ apt-get install nginx
```

Once this command is installed, you will then need to configure nginx to serve
requests from your unicorn workers. To do this, put this content inside
`/etc/nginx/nginx.conf`:

    user spree;

    # Change this depending on your hardware
    worker_processes 4;
    pid /var/run/nginx.pid;

    events {
      worker_connections 1024;
      multi_accept on;
     }

    http {
      types_hash_bucket_size 512;
      types_hash_max_size 2048;

      sendfile on;
      tcp_nopush on;
      tcp_nodelay off;

      include /etc/nginx/mime.types;
      default_type application/octet-stream;

      access_log /var/log/nginx/access.log;
      error_log /var/log/nginx/error.log;

      gzip on;
      gzip_disable "msie6";

      gzip_proxied any;
      gzip_min_length 500;
      gzip_types text/plain text/css application/json application/x-javascript
        text/xml application/xml application/xml+rss text/javascript;

      ## # Virtual Host Configs ##
      include /etc/nginx/conf.d/*.conf;
      include /etc/nginx/sites-enabled/*;
    }

This file sets up nginx-specific settings. You will need another file to tell
nginx where your application is. Create another file at
`/etc/nginx/sites-enabled/[your application's name]`, and fill it with this
content:

    upstream [your server's address] {
      # fail_timeout=0 means we always retry an upstream even if it failed
      # to return a good HTTP response (in case the Unicorn master nukes a
      # single worker for timing out).
      server unix:/tmp/[your application's name].socket fail_timeout=0;
    }

    server {
      # if you're running multiple servers, instead of "default" you should
      # put your main domain name here
      listen 80 default;

      # you could put a list of other domain names this application answers
      server_name [your server's address];

      root /home/spree/[your application's name]/current/public;
      access_log /var/log/nginx/[your server's address]_access.log;
      rewrite_log on;

      location / {
        #all requests are sent to the UNIX socket
        proxy_pass http://[your server's address];
        proxy_redirect off;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        client_max_body_size 10m;
        client_body_buffer_size 128k;

        proxy_connect_timeout 90;
        proxy_send_timeout 90;
        proxy_read_timeout 90;

        proxy_buffer_size 4k;
        proxy_buffers 4 32k;
        proxy_busy_buffers_size 64k;
        proxy_temp_file_write_size 64k;
      }

      # if the request is for a static resource, nginx should serve it directly
      # and add a far future expires header to it, making the browser
      # cache the resource and navigate faster over the website
      location ~ ^/(system|assets|spree)/  {
        root /home/spree/[application's name]/current/public;
        expires max;
        break;
      }
    }

***
The final `location` block here tells nginx to serve asset requests for three
separate paths from the `public` directory: `system`, `assets` and `spree`.

The `system` directory is where Paperclip typically would store assets. Spree's
assets are located separately, under `spree`.

The `assets` directory will contain the other assets for your application from
the [asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html).
***

With these settings in place, you can start up nginx by running `service nginx
start` as root on the remote server. Next, you can start the unicorn processes
by running `cap unicorn:start` from your local machine. Once these are running,
you will be able to access your site at [your server's address]. You should see
your store's homepage here if everything is correctly set up.

### Setting up SSL

***
This part of the guide assumes you have the relevant SSL certificate files
(a file ending in `.crt`, and another in `.key`) already and just need to know
where to put them.
***

The `*.crt` file belongs in `/etc/ssl/certs`, and the `*.key` file belongs in
`/etc/ssl/private`. Put these files there now.

To get nginx to work with SSL, you will need to edit
`/etc/nginx/sites-enabled/[application's name]` and inside the `server {` block,
put these lines:

    listen 443 ssl;

    ssl_certificate /etc/ssl/certs/[your certificate's name].crt;
    ssl_certificate_key /etc/ssl/private/[your key's name].key;

Take this time to ensure that you definitely have this line inside this file as
well:

    proxy_set_header X-Forwarded-Proto $scheme;

Without this line, you would get a redirect loop when you attempted to sign in
to your Spree store.

That is all the SSL configuration you will need for your server. To verify that
it works, attempt to visit the login page for your application, or the admin
area.

## Loading seed data

Now with the database and web servers set up for your Spree store correctly, the
final thing you will need is seed data. This data contains things such as
countries, states, zones, zone members and an admin role.

To install this data, run this command on the server, inside the current
directory:

```bash
RAILS_ENV=production bundle exec rake db:seed
```

If you have `spree_auth_devise` installed, this command will also prompt you for
a username and password for your admin user. If you're not using
`spree_auth_devise`, then you will need to set up a new user account manually in
the console and assign it the admin role, like this:

```ruby
user = User.create!(email: "email@example.com", password: "topsekret")
user.spree_roles << Spree::Role.find_by(name: "admin")
user.save!
```

Note that your `User` model may require additional attributes before it can be
created.

Once you have the data seeded by the `rake db:seed` command, you will need to
log into the admin interface and create a shipping method and a payment method
so that orders can be delivered and paid for.

### Symlinking images

***
You don't need to follow the steps in this section if you're using S3 or another
cloud hosting provider. This section is only necessary for local file storage.
***

The final step in configuring the server is symlinking the images so that on
subsequent deploys they don't disappear. To do this, you can create a new `spree`
directory within the `shared` directory by using this command:

```bash
mkdir -p /home/spree/[application's name]/shared/spree
```

This is the directory where all the uploads for the application will live. This
directory should be symlinked over to the application upon every deployment, and
to do that you can add this content to your `config/deploy.rb`:

```ruby
namespace :images do
  task :symlink, except: { no_release: true } do
    run "rm -rf #{release_path}/public/spree"
    run "ln -nfs #{shared_path}/spree #{release_path}/public/spree"
  end
end
after "bundle:install", "images:symlink"
```

Now upon every deploy, Capistrano will symlink the `spree` directory in the `shared`
directory into the current version of the app so that the product images are
persisted across releases.
