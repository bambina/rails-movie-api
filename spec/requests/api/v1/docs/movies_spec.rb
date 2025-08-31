require 'swagger_helper'

RSpec.describe 'api/v1/movies', type: :request do
  path '/api/v1/movies' do
    get 'List movies' do
      tags 'Movies'
      description 'Retrieve all movies'
      produces 'application/json'

      parameter '$ref': '#/components/parameters/page'
      parameter '$ref': '#/components/parameters/per_page'

      response 200, 'OK' do
        schema ApiSchemas::V1.movies_index_response
        let(:page) { 1 }
        let(:per_page) { 2 }
        before { create_list(:movie, 5) }
        run_test!
      end

      response 500, 'Internal server error' do
        schema ApiSchemas::V1.internal_server_error
        it 'documents 500 error only' do
          # no request — used only for OpenAPI docs
        end
      end
    end

    post 'Create a movie' do
      tags 'Movies'
      description 'Create a new movie'
      consumes 'application/json'
      produces 'application/json'
      security [ { bearerAuth: [] } ]

      parameter name: :movie, in: :body, required: true, schema: ApiSchemas::V1.movie_request

      include_context 'with authenticated user'

      response 201, 'Created' do
        schema ApiSchemas::V1.movie_response
        let(:movie) { { movie: attributes_for(:movie) } }
        run_test!
      end

      response 422, 'Invalid request' do
        schema ApiSchemas::V1.unprocessable_entity_response
        let(:movie) { { movie: { title: '', description: 'Invalid movie without title' } } }
        run_test!
      end

      response 500, 'Internal server error' do
        schema ApiSchemas::V1.internal_server_error
        it 'documents 500 error only' do
          # no request — used only for OpenAPI docs
        end
      end
    end
  end

  path '/api/v1/movies/{id}' do
    get 'Get movie by ID' do
      tags 'Movies'
      description 'Retrieve a specific movie by ID'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, description: 'Movie ID'

      response 200, 'Movie found' do
        schema ApiSchemas::V1.movie_response
        let(:movie) { create(:movie) }
        let(:id) { movie.id }
        run_test!
      end

      response 404, 'Movie not found' do
        schema ApiSchemas::V1.not_found_error
        let(:id) { 99999 }
        run_test!
      end

      response 500, 'Internal server error' do
        schema ApiSchemas::V1.internal_server_error
        it 'documents 500 error only' do
          # no request — used only for OpenAPI docs
        end
      end
    end

    delete 'Delete movie by ID' do
      tags 'Movies'
      description 'Delete a specific movie by ID'
      produces 'application/json'
      security [ { bearerAuth: [] } ]

      parameter name: :id, in: :path, type: :integer, description: 'Movie ID'

      include_context 'with authenticated user'

      response 204, 'Movie deleted successfully' do
        let(:movie) { create(:movie) }
        let(:id) { movie.id }
        run_test!
      end

      response 404, 'Movie not found' do
        schema ApiSchemas::V1.not_found_error
        let(:id) { 99999 }
        run_test!
      end

      response 500, 'Internal server error' do
        schema ApiSchemas::V1.internal_server_error
        it 'documents 500 error only' do
          # no request — used only for OpenAPI docs
        end
      end
    end

    patch 'Update movie (partial update)' do
      tags 'Movies'
      description 'Partially update movie information'
      consumes 'application/json'
      produces 'application/json'
      security [ { bearerAuth: [] } ]

      parameter name: :id, in: :path, type: :integer, description: 'Movie ID'
      parameter name: :movie, in: :body, required: true, schema: ApiSchemas::V1.movie_patch_request

      include_context 'with authenticated user'

      response 200, 'Movie updated successfully' do
        schema ApiSchemas::V1.movie_response
        let(:existing_movie) { create(:movie) }
        let(:id) { existing_movie.id }
        let(:movie) { { movie: { title: 'Partially Updated Title' } } }
        run_test!
      end

      response 404, 'Movie not found' do
        schema ApiSchemas::V1.not_found_error
        let(:id) { 99999 }
        let(:movie) { { movie: { title: 'New Title' } } }
        run_test!
      end

      response 422, 'Invalid request' do
        schema ApiSchemas::V1.unprocessable_entity_response
        let(:existing_movie) { create(:movie) }
        let(:id) { existing_movie.id }
        let(:movie) { { movie: { title: '' } } }
        run_test!
      end

      response 500, 'Internal server error' do
        schema ApiSchemas::V1.internal_server_error
        it 'documents 500 error only' do
          # no request — used only for OpenAPI docs
        end
      end
    end

    put 'Update movie (full update)' do
      tags 'Movies'
      description 'Fully update movie information'
      consumes 'application/json'
      produces 'application/json'
      security [ { bearerAuth: [] } ]

      parameter name: :id, in: :path, type: :integer, description: 'Movie ID'
      parameter name: :movie, in: :body, required: true, schema: ApiSchemas::V1.movie_request

      include_context 'with authenticated user'

      response 200, 'Movie updated successfully' do
        schema ApiSchemas::V1.movie_response
        let(:existing_movie) { create(:movie) }
        let(:id) { existing_movie.id }
        let(:movie) { { movie: { title: 'Updated Title', description: 'Updated description' } } }
        run_test!
      end

      response 404, 'Movie not found' do
        schema ApiSchemas::V1.not_found_error
        let(:id) { 99999 }
        let(:movie) { { movie: attributes_for(:movie) } }
        run_test!
      end

      response 422, 'Invalid request' do
        schema ApiSchemas::V1.unprocessable_entity_response
        let(:existing_movie) { create(:movie) }
        let(:id) { existing_movie.id }
        let(:movie) { { movie: { title: '' } } }
        run_test!
      end

      response 500, 'Internal server error' do
        schema ApiSchemas::V1.internal_server_error
        it 'documents 500 error only' do
          # no request — used only for OpenAPI docs
        end
      end
    end
  end
end
