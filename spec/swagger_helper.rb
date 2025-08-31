# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Movie API',
        version: 'v1',
        description: 'A REST API for managing movies and watchlists with JWT authentication'
      },
      paths: {},
      servers: [
        {
          url: '/', # NOTE: Use '/' to make it work in both dev and prod
          description: 'Default server (works for both dev and prod)'
        }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: :JWT,
            description: 'Enter your JWT token (no "Bearer " prefix).'
          },
          cookieAuth: {
            type: :apiKey,
            in: :cookie,
            name: 'refresh_token'
          }
        },
        schemas: {
          movie: {
            type: :object,
            properties: {
              id: {
                type: :integer,
                example: 1
              },
              title: {
                type: :string,
                example: 'The Matrix'
              },
              description: {
                type: :string,
                nullable: true,
                example: 'A computer hacker learns about....'
              },
              release_year: {
                type: :integer,
                nullable: true,
                example: 1999
              },
              created_at: {
                type: :string,
                format: 'date-time',
                example: '2023-01-01T00:00:00Z'
              },
              updated_at: {
                type: :string,
                format: 'date-time',
                example: '2023-01-02T00:00:00Z'
              }
            },
            required: [ 'id', 'title', 'created_at', 'updated_at' ]
          },
          pagination_metadata: {
            type: :object,
            properties: {
              current_page: { type: :integer, example: 1 },
              total_pages:  { type: :integer, example: 3 },
              total_count:  { type: :integer, example: 50 },
              per_page:     { type: :integer, example: 10 }
            },
            required: [ 'current_page', 'total_pages', 'total_count', 'per_page' ]
          }
        },
        parameters: {
          page: {
            name: :page,
            in: :query,
            schema: { type: :integer },
            description: 'Page number (default: 1)',
            required: false,
            example: 1
          },
          per_page: {
            name: :per_page,
            in: :query,
            schema: { type: :integer },
            description: "Items per page (default: #{Kaminari.config.default_per_page}, max: #{Kaminari.config.max_per_page})",
            required: false,
            example: Kaminari.config.default_per_page
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
