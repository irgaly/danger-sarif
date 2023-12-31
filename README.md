# danger-sarif

[![Gem Version](https://badge.fury.io/rb/danger-sarif.svg)](https://badge.fury.io/rb/danger-sarif)

[Danger](https://github.com/danger/danger) plugin for reporting [SARIF](https://sarifweb.azurewebsites.net/) file.

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

## Options

| option                | description                                                        |
|-----------------------|--------------------------------------------------------------------|
| `sarif.fail_on_error` | Set the behavior that treating error as fail or not. default: true |

```ruby
# Dangerfile
sarif.fail_on_error false
sarif.report '...'
```

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Make your changes.
4. Run `bundle exec rake spec` to run the tests.
