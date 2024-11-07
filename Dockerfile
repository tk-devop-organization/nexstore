# Backend: Rails Application Dockerfile

# Use the official Ruby image from Docker Hub
FROM ruby:3.2.2

# Set environment variables to avoid interactive prompts during installation
ENV LANG C.UTF-8
ENV TZ=UTC

# Install dependencies
# Install dependencies: nodejs, yarn, and other essential libraries
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && \
    apt-get install -y nodejs yarn build-essential libpq-dev

# Set the working directory in the container
WORKDIR /app

# Install Rails dependencies
COPY Gemfile Gemfile.lock ./
RUN gem install bundler:2.5.23
RUN bundle install

# Copy the entire Rails application
COPY . .

# Precompile assets (optional but useful for production)
RUN RAILS_ENV=production bundle exec rake assets:precompile

# Expose the default Rails port
EXPOSE 3000

# Start the Rails server
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
