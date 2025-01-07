# thimble

A simple wiki generator for plaintext files in a single Ruby file. Supports
double-bracket link syntax (`[[my link]]`) and nothing else.

## Installation

Gem TBD. For now, clone the repo and run locally.

## Usage

Example plaintext file, `index.txt`:

```
Links are created via [[double brackets]]. Backlinks are
automatically appended to the bottom of the document.
```

Run the thimble CLI:

```
thimble my-dir/

# Or, specify an outdir
thimble my-dir/ -o site/
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
