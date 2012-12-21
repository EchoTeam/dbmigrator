Rails migration in non-Rails projects.

USAGE
=====

Install Ruby 1.9 and your database adapter (e.g. `gem install pg`) then:

```gem install "dbmigrator"```

This gems allows only migrate the existing database. We turned off db:create and db:drop due to security issues.

To create migration you should use the folling command:

```rake db:migrations:new GROUP=items NAME=add_new_column```

This command creates migration with name `add_new_column` within `items` group.

To migrate items group use the following command:

```rake db:migrate DATABASE_URL=postgres://user:password@host/database GROUP=items```

This command applies migrations within `items` group to database `postgres://user:password@host/database`

dbmigrator uses sql schema format  `ActiveRecord::Base.schema_format = :sql`. In other words we produce pure sql dumps after db:migrate and use this dump in db:setup task

