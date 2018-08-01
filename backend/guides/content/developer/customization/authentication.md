---
title: "Custom Authentication"
section: customization
---

## Overview

This guide covers using a custom authentication setup with Spree, such
as one provided by your own application. This is ideal in situations
where you want to handle the sign-in or sign-up flow of your application
uniquely, outside the realms of what would be possible with Spree. After
reading this guide, you will be familiar with:

-   Setting up Spree to work with your custom authentication

## Background

Traditionally, applications that use Spree have needed to use the
`Spree::User` model that came with the `spree_auth` component of Spree.
With the advent of 1.2, this is no longer a restriction. The
`spree_auth` component of Spree has been removed and is now purely
opt-in. If you have an application that has used the `spree_auth`
component in the past and you wish to continue doing so, you will need
to add this extra line to your `Gemfile`:

```ruby
gem 'spree_auth_devise'
```

By having this authentication component outside of Spree, applications
that wish to use their own authentication may do so, and applications
that have previously used `spree_auth`'s functionality may continue
doing so by using this gem.

### The User Model

This guide assumes that you have a pre-existing model inside your
application that represents the users of your application already. This
model could be provided by gems such as
[Devise](https://github.com/plataformatec/devise) or
[Sorcery](https://github.com/NoamB/sorcery). This guide also assumes
that the application that this `User` model exists in is already a Spree
application.

This model **does not** need to be called `User`, but for the purposes
of this guide the model we will be referring to **will** be called
`User`. If your model is called something else, do some mental
substitution wherever you see `User`.

#### Initial Setup

To begin using your custom `User` class, you must first edit Spree's
initializer located at `config/initializers/spree.rb` by changing this
line:

```ruby
Spree.user_class = "Spree::User"
```

To this:

```ruby
Spree.user_class = "User"
```

Next, you need to run the custom user generator for Spree which will
create two files. The first is a migration that will add the necessary
Spree fields to your users table, and the second is an extension that
lives at `lib/spree/authentication_helpers.rb` to the
`Spree::Core::AuthenticationHelpers` module inside of Spree.

Run this generator with this command:

```bash
$ bundle exec rails g spree:custom_user User
```

This will tell the generator that you want to use the `User` class as
the class that represents users in Spree. Run the new migration by
running this:

```bash
$ bundle exec rake db:migrate
```

Next you will need to define some methods to tell Spree where to find
your application's authentication routes.

#### Authentication Helpers

There are some authentication helpers of Spree's that you will need to
possibly override. The file at `lib/spree/authentication_helpers.rb`
contains the following code to help you do that:

```ruby
module Spree
  module AuthenticationHelpers
    def self.included(receiver)
      receiver.send :helper_method, :spree_login_path
      receiver.send :helper_method, :spree_signup_path
      receiver.send :helper_method, :spree_logout_path
      receiver.send :helper_method, :spree_current_user
    end

    def spree_current_user
      current_user
    end

    def spree_login_path
      main_app.login_path
    end

    def spree_signup_path
      main_app.signup_path
    end

    def spree_logout_path
      main_app.logout_path
    end
  end
end
```

In your `ApplicationController` add those lines:

```ruby
include Spree::AuthenticationHelpers
include Spree::Core::ControllerHelpers::Auth
include Spree::Core::ControllerHelpers::Common
include Spree::Core::ControllerHelpers::Order
include Spree::Core::ControllerHelpers::Store
helper 'spree/base'
```

Each of the methods defined in this module return values that are the
most common in Rails applications today, but you may need to customize
them. In order, they are:

* `spree_current_user` Used to tell Spree what the current user
of a request is.
* `spree_login_path` The location of the login/sign in form in
your application.
* `spree_signup_path` The location of the sign up form in your
application.
* `spree_logout_path` The location of the logout feature of your
application.

***
URLs inside the `spree_login_path`, `spree_signup_path` and
`spree_logout_path` methods **must** have `main_app` prefixed if they
are inside your application. This is because Spree will otherwise
attempt to route to a `login_path`, `signup_path` or `logout_path`
inside of itself, which does not exist. By prefixing with `main_app`,
you tell it to look at the application's routes.
***

You will need to define the `login_path`, `signup_path` and
`logout_path` routes yourself, by using code like this inside your
application's `config/routes.rb` if you're using Devise:

```ruby
devise_for :users
devise_scope :user do
  get '/login', to: "devise/sessions#new"
  get '/signup', to: "devise/registrations#new"
  delete '/logout', to: "devise/sessions#destroy"
end
```

Of course, this code will be different if you're not using Devise.
Simply do not use the `devise_scope` method and change the controllers
and actions for these routes.

You can also customize the `spree_login_path`, `spree_signup_path`
and `spree_logout_path` methods inside
`lib/spree/authentication_helpers.rb` to use the routing helper methods
already provided by the authentication setup you have, if you wish.

***
Any modifications made to `lib/spree/authentication_helpers.rb`
while the server is running will require a restart, as wth any other
modification to other files in `lib`.
***

## The User Model

In your User Model you have to add:

```ruby
include Spree::UserMethods
include Spree::UserAddress
include Spree::UserPaymentSource
```
The first of these methods are the ones added for the `has_and_belongs_to_many` association
called "spree_roles". This association will retrieve all the roles that
a user has for Spree.

The second of these is the `spree_orders` association. This will return
all orders associated with the user in Spree. There's also a
`last_incomplete_spree_order` method which will return the last
incomplete spree order for the user. This is used internal to Spree to
persist order data across a user's login sessions.

The third and fourth associations are for address information for a
user. When a user places an order, the address information for that
order will be linked to that user so that it is available for subsequent
orders.

The next method is one called `has_spree_role?` which can be used to
check if a user has a specific role. This method is used internally to
Spree to check if the user is authorized to perform specific actions,
such as accessing the admin section. Admin users of your system should
be assigned the Spree admin role, like this:

```ruby
user = User.find_by(email: "master@example.com")
user.spree_roles << Spree::Role.find_or_create_by(name: "admin")
```

To test that this has worked, use the `has_spree_role?` method, like
this:

```ruby
user.has_spree_role?("admin")
```

If this returns `true`, then the user has admin permissions within
Spree.

Finally, if you are using the API component of Spree, there are more
methods added. The first is the `spree_api_key` getter and setter
methods, used for the API key that is used with Spree. The next two
methods are `generate_spree_api_key!` and `clear_spree_api_key`
which will generate and clear the Spree API key respectively.

## Login link

To make the login link appear on Spree pages, you will need to use a
Deface override. Create a new file at
`app/overrides/auth_login_bar.rb` and put this content inside it:

```ruby
Deface::Override.new(virtual_path: "spree/shared/_nav_bar",
  name: "auth_login_bar",
  insert_before: "li#search-bar",
  partial: "spree/shared/login_bar",
  disabled: false,
  original: 'eb3fa668cd98b6a1c75c36420ef1b238a1fc55ad')
```

This override references a partial called "spree/shared/login_bar".
This will live in a new partial called
`app/views/spree/shared/_login_bar.html.erb` in your application. You
may choose to call this file something different, the name is not
important. This file will then contain this code:

```erb
<%% if spree_current_user %>
  <li>
    <%%= link_to Spree.t(:logout), spree_logout_path, method: :delete %>
  </li>
<%% else %>
  <li>
    <%%= link_to Spree.t(:login), spree_login_path %>
  </li>
  <li>
    <%%= link_to Spree.t(:signup), spree_signup_path %>
  </li>
<%% end %>
```

This will then use the URL helpers you have defined in
`lib/spree/authentication_helpers.rb` to define three links, one to
allow users to logout, one to allow them to login, and one to allow them
to signup. These links will be visible on all customer-facing pages of
Spree.

## Signup promotion

In Spree, there is a promotion that acts on the user signup which will
not work correctly automatically when you're not using the standard
authentication method with Spree. To fix this, you will need to trigger
this event after a user has successfully signed up in your application
by setting a session variable after successful signup in whatever
controller deals with user signup:

```ruby
session[:spree_user_signup] = true
```

This line will cause the Spree event notifiers to be notified of this
event and to apply any promotions to an order that are triggered once a
user signs up.
