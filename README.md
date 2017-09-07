# AKER - SUBMISSION

An application for enabling provenance and receipt of Biomaterial

# Installation
## Dev environment
1. Configure ports to services in `development.rb`.
2. Setup DB using `rake db:drop db:create db:migrate`
3. Seed DB with `rade db:seed` (first verify that your username has been added to the seed)

### Label templates
To initialize the label templates, you need to modify `Rails.configuration.pmb_uri` to link with the right PrintMyBarcode instance and after that execute the rake task: `rake label_templates:setup`

# Testing
## Requirements
* [PhantomJS](http://phantomjs.org/) - install with `npm install -g phantomjs`
