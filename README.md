# AKER - SUBMISSION

An application for enabling provenance and receipt of Biomaterial

Installation:

# rake db:drop db:create db:migrate

To initialize the label templates, you need to modify Rails.configuration.pmb_uri to link with the right PrintMyBarcode instance and after that execute the rake task:

# rake label_templates:setup
