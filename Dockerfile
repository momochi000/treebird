FROM ruby:3.3.0
RUN apt-get update -qq && apt-get install -y graphviz
RUN mkdir /app
WORKDIR /app

RUN gem install bundler
COPY treebird/Gemfile Gemfile
COPY treebird/Gemfile.lock Gemfile.lock
RUN bundle install

COPY . /app
EXPOSE 3000
CMD bundle exec rails s -p $PORT -b 0.0.0.0
