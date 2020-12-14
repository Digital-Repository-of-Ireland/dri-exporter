# Dri::Exporter

Exporters for objects in the DRI repository.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dri-exporter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dri-exporter

## Usage

```
require 'dri/exporter'

Dri::Exporter.config do |c|
  c.user_email = 'user@example.org'  # email address of repository user account
  c.api_token = 'token'              # user account's api access token
  c.output_directory = '/tmp'        # directory to write the BagIt bags
end
```

To specify the objects to export, either pass in an array of object IDs

```
Dri::Exporter.export(object_ids: ['object1','object2'...]
```

Or give the path to a CSV file containing a list of IDs.


```
Dri::Exporter.export(csv: 'ids.csv')

```

By default a column named 'Id' will be used. This header can be changed with a configuration option.

```
  c.csv_header = 'pid'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [Apache 2.0](https://opensource.org/licenses/Apache-2.0).

## Code of Conduct

Everyone interacting in the Dri::Exporter project’s codebases, issue trackers and mailing lists is expected to follow the [code of conduct](https://github.com/Digital-Repository-of-Ireland/dri-exporter/blob/master/CODE_OF_CONDUCT.md).
