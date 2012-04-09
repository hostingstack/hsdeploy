# hsdeploy

Deployment tool for the HostingStack open-source PaaS, with special support for multi-stage deploys (e.g. for staging environments).

## Deploying a Ruby on Rails app

    gem install hsdeploy
    hsdeploy add production young-samurai-4@example.org
    hsdeploy production

## Config file

hsdeploy keeps a local config file .hsdeployrc within the top-level sourcecode directory (determined by location of .git directory).

## Legalese

Copyright (c) 2011, 2012 Efficient Cloud Ltd.

Released under the [MIT license](http://www.opensource.org/licenses/mit-license.php).
