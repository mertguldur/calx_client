# CalX Client

[![Build
Status](https://travis-ci.org/mertguldur/calx_client.svg?branch=master)](https://travis-ci.org/mertguldur/calx_client)
[![Coverage
Status](https://coveralls.io/repos/github/mertguldur/calx_client/badge.svg?branch=master)](https://coveralls.io/github/mertguldur/calx_client?branch=master)

Ruby API client to access CalX events.

## Installation

```ruby
gem 'calx_client'
```

## Create a client

```ruby
client = CalX::Client.new(access_id, secret_key)
```

## User access authorization

Every client needs to obtain user authorization in order to access event data.

```ruby
response = client.authorize(user_api_id)
```

## Event API

#### Retrieve the events on a date

```ruby
events = client.events(user_api_id, date: date)
```

#### Retrieve an event

```ruby
event = client.event(event_id)
```

#### Create an event

```ruby
event = client.create_event(user_api_id, event_params)
```

#### Update an event

```ruby
event = client.update_event(event_id, event_params)
```

#### Delete an event

```ruby
client.delete_event(event_id)
```
