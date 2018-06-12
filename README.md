# Aker - Reception app

[![Build Status](https://travis-ci.org/sanger/aker-reception-app.svg?branch=devel)](https://travis-ci.org/sanger/aker-reception-app)
[![Maintainability](https://api.codeclimate.com/v1/badges/2417e4884a4aa5af3041/maintainability)](https://codeclimate.com/github/sanger/aker-reception-app/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/2417e4884a4aa5af3041/test_coverage)](https://codeclimate.com/github/sanger/aker-reception-app/test_coverage)

An application for enabling provenance and receipt of Biomaterial.

# Installation
## Dev environment
1. Configure or update ports to services in `development.rb`.
2. Setup DB using `rake db:setup`. Alternatively, use:
  * `rake db:drop db:create db:migrate`
  * Seed DB with `rake db:seed` (first verify that your username has been added to the seed)

### Label templates
To initialize the label templates, you need to modify `Rails.configuration.pmb_uri` to link with the right PrintMyBarcode instance and after that execute the rake task: `rake label_templates:setup`

# Testing
## Requirements
* [PhantomJS](http://phantomjs.org/) - install with `npm install -g phantomjs`

## Running tests
* Before running tests, make sure that the test database has been fully migrated: `bin/rails db:migrate RAILS_ENV=test`
To execute the current tests, run: `bundle exec rspec`
