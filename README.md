# Content Performance Manager

`Provide content designers across all of government with the data and tooling they need to measure and improve ‘their’ GOV.UK content.`

This is an app that aggregates metrics from multiple sources to give easy view of content performance measurements.

### Setting up the application

The application contains a [setup script](./bin/setup) that will perform the
steps required to bootstrap the application.

```bash
$ ./bin/setup
```

### Running the application
#### Using the GDS development VM

See the [getting started guide](https://docs.publishing.service.gov.uk/getting-started.html) for instructions about setting up and running your development VM.

In the development VM, go to:

```bash
cd /var/govuk/govuk-puppet/development-vm
```

Then run:

 ```bash
 bowl content-performance-manager
 ```

The application can be accessed from:

http://content-performance-manager.dev.gov.uk

#### From the local machine

The application can be started with:

```bash
$ ./startup.sh
```

In the browser navigate to: http://localhost:3206

### Running the tests
 ```bash
 $ bundle exec rake
 ```

 or you can also use [Guard](https://github.com/guard/guard), see [list commands](https://github.com/guard/guard/wiki/List-of-Guard-Commands)

 ```bash
 $ bundle exec guard
 ```

### Importing data

* [On the local environment](doc/importing_data.md#Local_environment)
* [On GOV.UK environments](doc/importing_data.md#jenkins)

<<<<<<< HEAD
### Importing themes

There are custom rake tasks for backing up and restoring themes:

```
bundle exec rake themes:backup
bundle exec rake themes:restore
```

We decided to check this data into git because themes are vital to the
application and they take a long time to set up.

These tasks will read/write a `themes.sql` file in the top-level directory.
Existing backups are in `backups/` and will need to be copied to use the rake
tasks, e.g. `cp backups/2017-06-11-themes.sql backups.sql`.

### Comparing themes against a CSV

Previously, inventories were exported as CSVs. There is a rake task that
compares one of these CSVs against the content items in a Theme and prints a
report. To run it:

```
bundle exec rake themes:compare[~/Downloads/transport.csv,Transport]
```

The first argument is the path to the CSV export. The second argument is the
name of the theme.


### App development

* [GOVUK-LINT-RUBY](doc/govuk-lint.md)
* [Set up Google Analytics credentials in development](doc/google_analytics_setup.md)


### Using Docker

[Docker] configuration files are included should you wish to develop the
application in a container. A [compose][docker compose] configuration is
included that defines all the services needed to run the application.

Use the [GOV.UK replication scripts] to download a copy of the application data:

```commandline
$ cd /path/to/govuk-puppet/development-vm/replication/
$ ./sync-postgresql.sh -n postgresql-primary-1.backend.integration
```

Set an environmental variable pointing to the PostgreSQL backup. This is then
mounted as a volume on the PostgreSQL container so that the application
database is restored when the container is created. See the
[official PostgreSQL Docker image](https://hub.docker.com/_/postgres/) for more
information.

```commandline
$ echo "DATABASE_BACKUP=/path/to/govuk-puppet/development-vm/replication/backups/postgresql/postgresql-primary-1.backend.integration/latest/content_performance_manager_production_XXXX-XX-XX_XXhXXm.Day.sql.gz" > .env
```

Create and start the containers:

```commandline
$ docker-compose up -d
```

Apply any database migrations created after the database import was taken:

```commandline
$ docker-compose exec app rails db:migrate
```

Launch the application:

```commandline
$ open http://localhost:3000/
```

To run the test suite:

```commandline
$ docker-compose exec app rails db:setup RAILS_ENV=test
$ docker-compose exec app rake
```

[docker]: https://www.docker.com/
[docker compose]: https://docs.docker.com/compose/overview/
[GOV.UK replication scripts]: https://docs.publishing.service.gov.uk/manual/replicate-app-data-locally.html
