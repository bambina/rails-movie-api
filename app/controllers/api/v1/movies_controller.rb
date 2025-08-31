class Api::V1::MoviesController < Api::BaseController
  before_action :set_movie, only: [ :show, :update, :destroy ]
  before_action :authenticate_user!, only: [ :create, :update, :destroy ]

  def index
    @movies = Movie.page(params[:page]).per(params[:per_page])

    render json: {
      data: @movies,
      meta: {
        current_page: @movies.current_page,
        total_pages: @movies.total_pages,
        total_count: @movies.total_count,
        per_page: @movies.limit_value
      }
    }
  end

  def create
    @movie = Movie.new(movie_params)

    if @movie.save
      render json: { data: @movie }, status: :created
    else
      render json: {
        errors: @movie.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def show
    render json: { data: @movie }
  end

  def update
    if @movie.update(movie_params)
      render json: { data: @movie }, status: :ok
    else
      render json: {
        errors: @movie.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @movie.destroy
    head :no_content
  end

  private

  def movie_params
    params.require(:movie).permit(:title, :description, :release_year)
  end

  def set_movie
    @movie = Movie.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      error: {
        message: "Movie not found"
      }
    }, status: :not_found
  end
end
