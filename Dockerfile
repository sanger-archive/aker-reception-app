# aker-submission-gui
# Use ruby 2.3.1
FROM ruby:2.3.1

# Update package list and install required packages
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs nodejs-legacy npm

# Install phantomjs - required for tests
# https://www.npmjs.com/package/phantomjs-prebuilt
RUN npm install -g phantomjs-prebuilt

# Create the working directory
# https://docs.docker.com/engine/reference/builder/#workdir
WORKDIR /code

# Add the Gemfile and .lock file
ADD Gemfile /code/Gemfile
ADD Gemfile.lock /code/Gemfile.lock

# Install bundler
# http://bundler.io/
RUN gem install bundler

# Install gems required by project
# We do not need the gems of the deployment group
RUN bundle install --without deployment

# Add the wait-for-it file to utils
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /utils/wait-for-it.sh
RUN chmod u+x /utils/wait-for-it.sh

# Add the docker-entrypoint file to utils
ADD https://raw.githubusercontent.com/pjvv/docker-entrypoint/master/docker-entrypoint.sh /utils/docker-entrypoint.sh
RUN chmod u+x /utils/docker-entrypoint.sh

# Add all remaining contents to the image
ADD . /code
