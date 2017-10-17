# CF Redis Example App [![Build Status](https://travis-ci.org/pivotal-cf/cf-redis-example-app.svg)](https://travis-ci.org/pivotal-cf/cf-redis-example-app)

This app is an example of how you can consume a Cloud Foundry service within an app.

It allows you to set, get and delete Redis key/value pairs using RESTful endpoints.

### Getting Started

#### Using Pivotal Redis service

Install the app by pushing it to your Cloud Foundry and binding with the Pivotal Redis service

Example:

     $ git clone git@github.com:pivotal-cf/cf-redis-example-app.git
     $ cd cf-redis-example-app
     $ cf push redis-example-app --no-start
     $ cf create-service p-redis dedicated-vm redis
     $ cf bind-service redis-example-app redis
     $ cf start redis-example-app
     
#### Using Redis-Labs CUPS

Install the app by pushing it to your Cloud Foundry and binding with a Redis-Labs [CUPS](https://docs.cloudfoundry.org/devguide/services/user-provided.html)

You will need to sign up for [redis-as-a-service](https://redislabs.com/) and then provide the credentials of your redis instance when running cf cups.

Example:

     $ git clone git@github.com:pivotal-cf/cf-redis-example-app.git
     $ cd cf-redis-example-app
     $ cf push redis-example-app --no-start
     $ cf cups redis -p "host, password, port"
     $ cf bind-service redis-example-app redis
     $ cf restage redis-example-app
     $ cf start redis-example-app

### Endpoints

#### PUT /:key

Sets the value stored in Redis at the specified key to a value posted in the 'data' field. Example:

    $ export APP=redis-example-app.my-cloud-foundry.com
    $ curl -X PUT $APP/foo -d 'data=bar'
    success


#### GET /:key

Returns the value stored in Redis at the key specified by the path. Example:

    $ curl -X GET $APP/foo
    bar

#### DELETE /:key

Deletes a Redis key spcified by the path. Example:

    $ curl -X DELETE $APP/foo
    success

#### GET /config/:item

Returns the Redis configuration value at the key specified by the path. Example:

    $ curl -X GET $APP/config/max_clients
    100
