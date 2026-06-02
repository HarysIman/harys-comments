FROM ruby:3.3-slim

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY app.rb ./

ENV DB_PATH=/data/comments.db

EXPOSE 3000
CMD ["bundle", "exec", "ruby", "app.rb", "-o", "0.0.0.0", "-p", "3000"]
