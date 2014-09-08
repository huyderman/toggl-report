Toggl-Report
===========================================================================

This is a simple tool created to export from [Toggl](http://www.toggl.com)
a weekly summary report of total hours spent per task each day. It was
created for personal use, and is only intended to cover a single use-case;
mine.
 
Installation
---------------------------------------------------------------------------

To install dependencies, it's recommended to use [Bundler](http://bundler.io/).

    $ gem install bundler
    $ bundle install
    
Usage
---------------------------------------------------------------------------

To use the report generator, you'll need a Toggl API token. It can be
generated on the [profile page](https://www.toggl.com/app/profile).
This token must be added as the environment variable `TOGGL_TOKEN`.
Alternatively you can add a [`.env`](https://github.com/bkeepers/dotenv) file:

    TOGGL_TOKEN=<token>

You can then generate a report for a week by executing:

    $ bundle exec bin/togg-report week <WEEK> [YEAR]
    
