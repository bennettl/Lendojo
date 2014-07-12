source 'https://rubygems.org'
ruby '2.0.0'
#ruby-gemset=railstutorial_rails_4_0

gem 'rails', '4.1.0'
gem 'bcrypt-ruby', '3.1.2'
gem "autoprefixer-rails"
gem "sass-rails", "~> 4.0.3"
gem 'uglifier', '2.1.1'
gem 'coffee-rails', '4.0.1'
gem 'jquery-rails', '3.0.4'
gem 'turbolinks', '1.1.1'
gem 'jbuilder', '1.0.2'

# Style
gem 'bootstrap-sass', '~> 3.1.1.1'
gem 'font-awesome-rails', '~> 4.1.0.0'

# Populate DB for Testing
gem 'faker', '1.2.0'

# User Authentication/Session system
gem 'devise', '~> 3.2.4'

# Pagination
gem 'will_paginate', '3.0.4'
gem 'bootstrap-will_paginate', '0.0.9'

# Reputation system
gem 'activerecord-reputation-system', github: 'NARKOZ/activerecord-reputation-system', branch: 'rails4'

# Maps/Geocoder
# gem 'underscore-rails', '~> 1.6.0'
# gem 'gmaps4rails', '~> 2.1.2'
gem 'geocoder', '~> 1.2.2'

# Date picker
gem 'momentjs-rails', '~> 2.5.0'
gem 'bootstrap3-datetimepicker-rails', '~> 3.0.0'

# File Attachment
gem "paperclip", :git => "git://github.com/thoughtbot/paperclip.git"

# Payment Network
gem 'stripe', '~> 1.14.0'

# Authentication
gem 'omniauth', '~> 1.2.1'
gem 'omniauth-facebook', '~> 1.6.0'
gem 'omniauth-twitter', '~> 1.0.1'
gem 'omniauth-google-oauth2', '~> 0.2.4'

# Saving image from omniauth - paperclip
gem 'open_uri_redirections'

# Swagger 
gem 'swagger-docs', '~> 0.1.8'

# HTML Emails
gem 'roadie', '~> 3.0.0'
gem 'roadie-rails', '~> 1.0.2'

group :development, :test do
  gem 'sqlite3', '1.3.8'
  gem 'rspec-rails', '2.13.1'
  gem 'hirb', '0.7.1'
  gem 'annotate', ">=2.6.0"
end

group :test do
  gem 'selenium-webdriver', '2.35.1'
  gem 'capybara', '2.1.0'
end

group :doc do
  gem 'sdoc', '0.3.20', require: false
end

group :production do
  gem 'pg', '0.15.1'
  gem 'rails_12factor', '0.0.2'
end