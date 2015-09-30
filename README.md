# Sas2Yaml

This gem installs a CLI program, `sas2yaml` which will (attempt) to read in a SAS input statement and turn it into a [YAML](http://yaml.org/) file with the name of each variable along with its position in a fixed-width file, length, and type (assuming that information is available).

This gem was developed in order to decipher the fixed-width file structure of SEER Medicare SAS input statement files and works (fairly) well in processing those files.  Your mileage almost certainly will vary.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sas2yaml'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sas2yaml

## Usage

```
sas2yaml file1.sas file2.sas ...
```

For each file listed, a lot of output will hit your screen, the program will hopefully not bomb out, and you'll end up with files named "file1.yml" and "file2.yml" (from the example above).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Thanks
- [Outcomes Insights, Inc.](http://outins.com/)
  - Many thanks for allowing me to release a portion of my work as Open Source Software!
- [Ruby](https://www.ruby-lang.org/en/)
  - For being such an awesome language that it can pretend to be another (and much more awful) language **cough** *SAS* **cough**.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sas2yaml.

