#!/bin/bash -ex

#echo "TODO: Make sure Postgres.app isn't in PATH"
#brew install postgresql
#sudo env ARCHFLAGS="-arch x86_64" gem install pg -- --with-pg-config=/usr/local/Cellar/postgresql/9.4.5_2/bin/pg_config
#bundle config build.pg --with-pg-config=/usr/local/Cellar/postgresql/9.4.5_2/bin/pg_config
ARCHFLAGS="-arch x86_64" bundle install --path vendor/bundle
