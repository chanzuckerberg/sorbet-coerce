# Contributing to Sorbet Coerce

Thank you for taking the time to contribute to this project!

This project adheres to the Contributor Covenant
[code of conduct](https://github.com/chanzuckerberg/.github/tree/master/CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code. Please report unacceptable behavior
to opensource@chanzuckerberg.com.

This project is licensed under the [MIT license](LICENSE.md).

## Need Help?

If you are trying to integrate Sorbet into your project, consider these venues:

 * **Stack Overflow**: Try the [sorbet](https://stackoverflow.com/questions/tagged/sorbet) tag
 * **Slack**: [the Sorbet community](https://sorbet.org/en/community) includes
   [#discuss](https://sorbet-ruby.slack.com/app_redirect?channel=discuss) and
   [#coerce](https://sorbet-ruby.slack.com/app_redirect?channel=coerce) channels

If you've come here to report an issue, you're in the right place!

## Reporting Bugs and Adding Functionality

We're excited you'd like to contribute to Sorbet Coerce!

When reporting a bug, please include:
 * Steps to reproduce
 * The versions of Ruby, Sorbet, and this gem that you are using
 * A test case, if you are able

**If you believe you have found a security issue, please contact us at security@chanzuckerberg.com**
rather than filing an issue here.

When proposing new functionality, please include test coverage. We're also available in
the Sorbet Slack [#coerce](https://sorbet-ruby.slack.com/app_redirect?channel=coerce) channel
to discuss your idea before you get started, just to make sure everyone is on the same page.

## Local Development

1. Clone `sorbet-coerce` locally:

```sh
❯ git clone https://github.com/chanzuckerberg/sorbet-coerce.git
```

2. Point your project's Gemfile to your local clone:

```
# -- Gemfile --

gem 'sorbet-coerce', path: "~/sorbet-coerce"
```

## Tests

Tests are written using [RSpec](https://rspec.info/). Each pull request is run against
multiple versions of both Ruby and sorbet-coerce. A code coverage report is also generated.

### Running Tests

You can run tests using `bundle exec rspec`.
