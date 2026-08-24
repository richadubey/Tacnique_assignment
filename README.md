# Billetto Rails Test

A Ruby on Rails application that integrates with the Billetto API, persists
events in PostgreSQL, and implements event voting using Rails Event Store.

## Overview

The application:

- Fetches public events from the Billetto API.
- Maps Billetto API responses into the application's `Event` model.
- Synchronizes events into PostgreSQL.
- Supports Billetto API pagination using the `after` cursor.
- Prevents duplicate events using the Billetto event ID.
- Provides an API endpoint for event voting.
- Records votes as `EventUpvoted` and `EventDownvoted` events using Rails Event Store.
- Uses Clerk for authentication.
- Includes automated tests using Minitest.

## Requirements

- Ruby 3.3.6
- Rails 7.2.3
- PostgreSQL
- Bundler

## Setup

### 1. Clone the repository

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd billetto_app
```

### 2. Install dependencies

```bash
bundle install
```

### 3. Configure credentials

The application requires Billetto API credentials and a Clerk secret key.

Edit Rails credentials:

```bash
EDITOR="nano" bin/rails credentials:edit
```

Add the following:

```yaml
billetto:
  api_key: YOUR_BILLETTO_API_KEY
  api_secret: YOUR_BILLETTO_API_SECRET

clerk:
  secret_key: YOUR_CLERK_SECRET_KEY
```

Replace the placeholder values with the credentials provided for your
Billetto and Clerk accounts.

**The `config/master.key` file is intentionally not committed to the
repository.**

### 4. Set up the database

Create the development database:

```bash
bin/rails db:create
```

Run the migrations:

```bash
bin/rails db:migrate
```

### 5. Start the application

```bash
bin/rails server
```

The application will be available at:

```text
http://localhost:3000
```

## Billetto API Integration

The Billetto API integration is separated into three main components.

### `Billetto::Client`

Responsible for communicating with the Billetto API.

It handles:

- API authentication using the Billetto API key and secret.
- Sending the `Api-Keypair` request header.
- Fetching public events.
- JSON response parsing.
- API error handling.
- Pagination using the `after` cursor.

Example:

```ruby
Billetto::Client.new.public_events(limit: 100)
```

### `Billetto::EventMapper`

Transforms the Billetto API event response into attributes required by the
application's `Event` model.

The mapper handles fields such as:

- Billetto event ID
- Title
- Description
- URL
- Image URL
- Start and end time
- Availability
- Price and currency
- Category and subcategory
- Event type
- Organiser
- Location
- Coordinates

### `Billetto::EventSync`

Responsible for synchronizing Billetto events into PostgreSQL.

The synchronization process:

1. Fetches events from Billetto.
2. Maps each API event using `Billetto::EventMapper`.
3. Finds an existing event using `billetto_id`.
4. Creates a new event or updates the existing event.
5. Prevents duplicate records using the unique database index on
   `billetto_id`.

Example:

```ruby
Billetto::EventSync.call(limit: 100)
```

## Pagination

The Billetto API provides pagination information such as:

- `has_more`
- `next_url`

The client supports the `after` cursor to request subsequent pages.

Example:

```ruby
client = Billetto::Client.new

response = client.public_events(limit: 100)

response["has_more"]
response["next_url"]
```

## Event Model

Events are persisted in PostgreSQL using the `Event` model.

The model stores information including:

- `billetto_id`
- `title`
- `description`
- `url`
- `image_url`
- `starts_at`
- `ends_at`
- `available`
- `price_cents`
- `currency`
- `category`
- `subcategory`
- `event_type`
- Organiser information
- Location information
- Latitude and longitude

`billetto_id` has a unique database index to prevent duplicate events.

The model also validates required attributes such as:

- `billetto_id`
- `title`
- `starts_at`
- `ends_at`

## Voting API

Voting is exposed through:

```text
POST /events/:id/vote
```

Supported vote types are:

- `up`
- `down`

Example request:

```json
{
  "vote": "up"
}
```

A successful upvote creates an `EventUpvoted` event.

A successful downvote creates an `EventDownvoted` event.

The voting logic is implemented in the `EventVote` service.

## Authentication

Clerk is used as the authentication provider for voting.

The voting flow is:

```text
Client
  |
  v
Clerk Authentication
  |
  v
EventVotesController
  |
  v
Authenticated User
  |
  v
EventVote
  |
  v
Rails Event Store
```

The Clerk secret key is stored using Rails encrypted credentials and is not
stored directly in the source code.

## Rails Event Store

Rails Event Store is used to record voting actions as domain events.

The application records:

```text
EventUpvoted
EventDownvoted
```

Each vote event contains information identifying:

- The application event
- The user associated with the vote

Events are stored in an event stream associated with the application event.

Rails Event Store is configured in:

```text
config/initializers/event_store.rb
```

## Architecture

```text
                    Billetto API
                         |
                         v
                 Billetto::Client
                         |
                         v
                Billetto::EventSync
                         |
                         v
               Billetto::EventMapper
                         |
                         v
                       Event
                         |
                         v
                    PostgreSQL


                      Vote API
                         |
                         v
                  Clerk Authentication
                         |
                         v
                EventVotesController
                         |
                         v
                     EventVote
                         |
                         v
                Rails Event Store
                    /          \
                   v            v
           EventUpvoted   EventDownvoted
```

## Design Decisions

### Separation of responsibilities

The application separates external API communication, data mapping,
synchronization, and voting into dedicated classes.

Main components include:

```text
Billetto::Client
Billetto::EventMapper
Billetto::EventSync
EventVote
```

This keeps controllers and models focused on their respective
responsibilities.

### Idempotent synchronization

The Billetto event ID is stored as `billetto_id` and has a unique database
index.

`find_or_initialize_by` is used during synchronization so repeated sync
operations update existing events instead of creating duplicates.

### Cursor-based pagination

The Billetto `after` cursor is used to support fetching subsequent pages of
events.

### Event-driven voting

Votes are recorded as domain events using Rails Event Store instead of only
storing a mutable vote count.

This preserves the history of voting actions and provides a foundation for
building derived vote counts later.

### Security

Billetto API credentials and Clerk secrets are stored using Rails encrypted
credentials and should never be committed as plain text.

## Testing

Run the complete test suite with:

```bash
bin/rails test
```

The test suite includes Event model tests covering:

- Valid events
- `billetto_id` uniqueness
- Required `starts_at`
- Required `ends_at`

Current test result:

```text
3 runs, 9 assertions, 0 failures, 0 errors
```

## Useful Commands

Start the Rails server:

```bash
bin/rails server
```

Open the Rails console:

```bash
bin/rails console
```

Create the database:

```bash
bin/rails db:create
```

Run migrations:

```bash
bin/rails db:migrate
```

Check migration status:

```bash
bin/rails db:migrate:status
```

Run tests:

```bash
bin/rails test
```

Check routes:

```bash
bin/rails routes
```

## Project Structure

```text
app/
├── controllers/
│   └── event_votes_controller.rb
├── events/
│   ├── event_upvoted.rb
│   └── event_downvoted.rb
├── integrations/
│   └── billetto/
│       ├── client.rb
│       ├── event_mapper.rb
│       └── event_sync.rb
├── models/
│   └── event.rb
└── services/
    └── event_vote.rb

config/
├── initializers/
│   ├── clerk.rb
│   └── event_store.rb
└── routes.rb

db/
└── migrate/

test/
└── models/
    └── event_test.rb
```

## Scope

The implementation focuses primarily on the backend integration and
architecture:

- Billetto API integration
- Event ingestion and persistence
- Pagination
- Data validation
- Authentication integration
- Event-driven voting
- Rails Event Store
- Automated testing

The frontend is intentionally kept lightweight, with the primary focus on
the backend architecture and integration requirements.