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

## Credentials

grabbing the credentials hash:

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
# Inject your own environment variables for testing
CF::App::Credentials.new(my_env)
```

## Environment

12 Factor applications read their configuration from the environment. Applications that have not been designed for CF may be expecting configuration to exist in the environment at their own top level key (e.g. `CLOUDINARY_URL`). Rather than modifying an app to read from `VCAP_SERVICES` the `CF::App::Environment` class will set environment variables based on `VCAP_SERVICES` and configuration. 

Example:

```ruby
configuration = [{ 
 "name" => "CLOUDINARY_URL",
 "method" => "name",
 "parameter => "cloudinary",
 "key" => "url"
}]

CF::App::Environment.set!(configuration)


 `echo $CLOUDINARY_URL`

 => "http://example.com"
```

alternatively, given a yaml file `env.yml`

```yaml
- name: TWITTER_OAUTH_TOKEN_SECRET
  method: name
  parameter: 'my-twitter'
  key: 'TWITTER_OAUTH_TOKEN_SECRET'
```

```ruby
CF::App:Environment.set_from_yaml!(env.yml)

 `echo TWITTER_OAUTH_TOKEN_SECRET`

 => "http://example.com"
```

Use with caution: This method will set actual environment variables.
