# cf-app-utils

Helper methods for apps running on Cloud Foundry.

## Download

https://rubygems.org/gems/cf-app-utils

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cf-app-utils'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cf-app-utils

## Usage

Require and use the gem in your application:

```ruby
require 'cf-app-utils'
```

You can then grab the credentials hash:

```ruby
# Get credentials for the service instance with the given name
CF::App::Credentials.find_by_service_name('master-db')

# Get credentials for the first service instance with the given tag
CF::App::Credentials.find_by_service_tag('relational')

# Get credentials for all service instances with the given tag
CF::App::Credentials.find_all_by_service_tag('relational')

# Get credentials for all service instances that match all of the given tags
CF::App::Credentials.find_all_by_all_service_tags(['cleardb', 'relational'])

# Get credentials for the first service instance with the given label
CF::App::Credentials.find_by_service_label('cleardb')

# Get credentials for all service instances with the given label
CF::App::Credentials.find_all_by_service_label('cleardb')
```

The keys in the hash are strings. For example, to get the `uri` value you can do:

```ruby
cleardb_url = credentials['uri']
```

```ruby
# Inject your own environment variables
CF::App::Credentials.new(my_env)
```
