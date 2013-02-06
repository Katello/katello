# Foreman integration

Foreman is integrated as a service. Katello is using Foreman API for orchestration. GUI will be recreated in Katello.

Katello is using OAuth for authentication:

*   see http://theforeman.org/projects/foreman/wiki/API_OAuth
*   see https://github.com/Pajk/apipie-rails/blob/master/lib/apipie/client/rest_client_oauth.rb


## Setup

Follow {https://fedorahosted.org/katello/wiki/AdvancedInstallation instructions} how to setup Katello. Foreman will be also installed and configured by `katello-configure`.
*(There may be some issues right now, we are working on it.)*

## Layers

### ForemanApi

`foreman_api` is auto-generated gem from Foreman API documentation using `apipie-rails` gem. It defines methods for each API call structured by resource.

Short example:

    architectures = ForemanApi::Resources::Architecture.new :base_url => 'http://localhost:3000',
                                                            :username => 'admin',
                                                            :password => 'changeme'
    data, response = architectures.index
    data # => [{"architecture"=>{"id"=>5, "name"=>"i386"}},
         #     {"architecture"=>{"id"=>9, "name"=>"ppc"}},
         #     {"architecture"=>{"id"=>14, "name"=>"x86_64"}}]

    data, response = architectures.show :id => 5
    data # => {"architecture"=>{"id"=>5, "name"=>"i386"}}

* see https://github.com/mbacovsky/foreman_api
* see https://github.com/Pajk/apipie-rails

### Resources::Foreman::...

{include:Resources::Foreman}

* see {Resources::Foreman::Architecture}

### Resources::ForemanModel

{include:Resources::AbstractModel}

* see {Resources::AbstractModel}
* see {Resources::ForemanModel}

### Glue::Foreman::(...)

{include:Glue::Foreman}

## Development

### Accessing Foreman UI

Katello is generating random passwords when creating foreman-users. This behavior is turned off in development environment to make debugging easier. Katello is using plain passwords in development for developer to access Foreman UI on behalf of an user (login and password are same for Katello and Foreman).

This can be configured in katello.yml.

    !!!yml
    development:
      foreman:
        random_password: false

### `foreman_api` gem

If you need to update Foreman API documentation do not forget to update ForemanApi.

1.  update API doc in foreman
1.  generate foreman_api gem

        !!!txt
        rake apipie:client[_api] # in foreman repo

    it will be generated in foreman root directory under `foreman_api`
1.  update Katello Gemfile to use the updated `foreman_api` gem

        gem 'foreman_api', :path => '/path/to/foreman/foreman_api'

1.  when you are done with changes
    *   send pull request to {https://github.com/theforeman/foreman Foreman}
    *   ping {https://github.com/mbacovsky @mbacovsky} to update and release `foreman_api` gem


#### Release process

When the PR is merged in in the Foreman upstream,

- pull the latest Foreman develop branch and run

      !!!txt
      rake apipie:client[_api]

in the repo. It will generate fresh foreman API bindings in foreman_api directory

- fork https://github.com/mbacovsky/foreman_api, create new branch and copy content of the generated foreman_api in it
- increase version in lib/foreman_api/version.rb
- commit your updates (be aware not to overwrite the gemspec with the generated template) and file a pull request

If everything is okay and the PR is merged the following steps will be done by me (some day automatically)

- build and release gem

      !!!txt
      rake release

- update the rpm package in our thirdparty repo
- update the rpm specfile contained in foreman_api
- push the updates to the theforeman/foreman_api on GitHub?

### Other Notes

Apipie param validation is enabled in Foreman:

    !!!txt
    $ curl -F a=a http://admin:changeme@localhost:3001/api/architectures
    {"error":{"parameter_name":"architecture","class":"Apipie::ParamMissing",
     "message":"Missing parameter architecture"}}

    $ curl -F architecture[drop]=a http://admin:changeme@localhost:3001/api/architectures
    {"error":{"parameter_name":"name","class":"Apipie::ParamInvalid",
     "message":"Invalid parameter 'name' value nil: Must be String"}}

It usually means that Foreman API documentation has to be updated or wrong parameters are being sent to Foreman.
