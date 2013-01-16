Generates all configuration for all our Amazon Web Services instances.

== Files

Config files are meant to be installed on top of a basic Ubuntu installation.
For instance, the file
`templates/production/web/root/etc/nginx/conf.d/overview.conf.erb` will be
processed into `generated/production/web/root/etc/nginx/conf.d/overview.conf`
and installed to `/etc/nginx/conf.d/overview.conf` on production web instances.

== Scripts

When migrating from one version of configuration files to the next, we:

1. Turn off the running services
2. Delete old configuration files
3. Hard-link new configuration files
4. Turn on the services

We rely upon `templates/production/web/scripts/stop.sh` and
`production/web/scripts/start.sh` to do this.

Both scripts must block until they complete successfully. `stop.sh` should
not assume the services are started (in case the previous version is badly
configured, or the server has a bug); `start.sh` should not assume the services
are stopped.

== Interpolation

Scripts are pre-processed with ERB. Interpolation takes the form
`<%= secrets['postgres-url'] %>`. That's Ruby code in there.

`secrets` are stored in a `secrets.yml`. `config` is stored in a `config.yml`.
We only include sample files in git. Specify the files using environment
variables:

    OVERVIEW_SECRETS=/path/to/secrets.yml \
      OVERVIEW_CONFIG=/path/to/config.yml \
      ./generate.sh

== Relation to `overview-server`

These configuration files are deployed separately from `overview-server`.
However, some configuration options (most notably, `ENV` values) affect
`overview-server` behavior and necessitate a restart of `overview-server`.
Here are some guidelines.

* `start.sh` and `stop.sh` cannot assume `overview-server` is installed.
* `start.sh` and `stop.sh` should restart `overview-server` if it is installed.
* If `overview-server` is to gain a new configuration option, the configuration
  should usually be deployed first. That way, the new version of
  `overview-server` won't crash when it is deployed.
