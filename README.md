# deploytool

Deployment tool for Platform-as-a-Service providers, with special support for multi-stage deploys (e.g. for staging environments).

## Deploying a Ruby on Rails app

    gem install deployto
    deploy add production young-samurai-4@example.org
    deploy production

## Config file

deploy keeps a local config file .deployrc within the top-level sourcecode directory (determined by location of .git directory).

## Legalese

Copyright 2011, Efficient Cloud Ltd.

Released under the [MIT license](http://www.opensource.org/licenses/mit-license.php).
