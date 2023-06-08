# Aldo Shoes Store Inventory Management

This Rails application provides real-time inventory management for Aldo Shoes Stores. When the inventory level for a specific shoe model is too low in one store, users can request a transfer of inventory from another store that has a high inventory.

## Architecture overview:

### Backend

- Ruby on Rails: Rails acts as the main application server. It's responsible for handling HTTP requests, managing the database via ActiveRecord (which uses PostgreSQL), and also for serving the GraphQL API.

- GraphQL: The application uses GraphQL for its API to handle data exchanges between the client and the server.

  - GraphQL Mutations: Two types of mutations are used in this application: `UpdateStoreInventory` and `TransferInventory`. The first one updates the inventory of a shoe model in a store, and the second transfers inventory from one store to another when the inventory of a shoe model is too low (you can also visit the graphiql explorer at http://localhost:3000/graphiql once the project is running)

- ActionCable: Rails' ActionCable is used to provide real-time updates to the client via WebSockets. This allows the inventory data to be updated in real-time on the client-side whenever it changes on the server.

- Redis: Redis is used as the backend for ActionCable. It manages the WebSocket connections and messages.

### Frontend

- ERB (Embedded Ruby): ERB is used to generate HTML views on the server side. It allows you to embed Ruby code within HTML templates.

- JavaScript: JavaScript is used on the client side to handle WebSocket messages and update the DOM in real-time

- CSS: CSS is used for basic styling of the HTML elements.

### Other Components

- Inventory Server: This is a standalone Ruby script that simulates an external inventory system. It randomly updates the inventory of different shoe models and sends these updates via WebSockets.

- Inventory Message Handler: This is another standalone Ruby script. It listens to the inventory updates sent by the Inventory Server and then makes GraphQL requests to the Rails app to update the inventory.

## Environment

- Ruby 3.2.2
- Rails 7.0.5

## Installation

To install and run the application, follow the steps below:

1. Download the repository to your local machine.

2. Open a terminal and navigate to the directory where the project is located.

3. Install all the required gems with Bundler:

```shell
bundle install
```

4. Start Postgres

5. Create and migrate the database:

```shell
rails db:create
rails db:migrate
```

6. In a new terminal window, launch the inventory server:

```shell
websocketd --port=8080 ruby inventory_server.rb
```

7. In another new terminal window, start Redis:

```shell
redis-server
```

8. In yet another new terminal window, start the Rails server:

```shell
rails s
```

9. In the last new terminal window, start the standalone Ruby file that will listen to the WebSocket server and forward the messages to the Rails application through a GraphQL mutation (UpdateStoreInventory):

```shell
ruby lib/handle_inventory_message.rb
```

10. Now, you can open your web browser and go to http://localhost:3000/store_inventory.
    You should see the inventory being updated live. If the inventory for a shoe model is too low, you can click the "Request inventory" button to trigger a transfer of inventory from a store with higher inventory for that specific model.

## Limitations:

- No authentification or permission management
- Scalablity: may not scale well if we've got too many websocket connections
- Simple thresholds: a shoe can be a lot more popular than another, so a low threshold for one may be too low for another more popular shoe model
- Inventory transfer has been simplified for the exercise, for a real inventory transfer the flow would be significantly more complex

## Next steps:

- Docker (!) to streamline the environment configuration
- Append new store/model live as well (right now we have to refresh the whole page to make the new records appear)
- Fully integrate sorbet and add missing signatures
- More test coverage
- Better error handling
- Ability to transfer excess inventory to another store
- Ability to choose how much inventory, and from which store, when requesting more inventory
