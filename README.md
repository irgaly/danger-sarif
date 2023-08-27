# danger-sarif

[Danger](https://github.com/danger/danger) plugin for reporting SARIF file.

## Installation

```shell
$ gem install danger-sarif
```

## Usage

report from SARIF file

```ruby
# Dangerfile
sarif.report 'app/build/reports/lint-results-debug.sarif'
```

report from multiple SARIF files

```ruby
# Dangerfile
Dir['**/build/reports/lint-results-*.sarif'].each do |file|
  sarif.report file
end
```

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Make your changes.
4. Run `bundle exec rake spec` to run the tests.
