# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clean existing data (development only)
if Rails.env.development?
  puts "Cleaning existing data..."
  Watchlist.destroy_all
  Movie.destroy_all
  User.destroy_all

  puts "Resetting primary key sequences..."
  %w[users movies watchlists].each do |table_name|
    ActiveRecord::Base.connection.reset_pk_sequence!(table_name)
  end
end

# Create sample users
puts "Creating users..."
%w[user1 user2 user3].each { |u| User.create!(username: u, password: "111") }
puts "Created #{User.count} users"

# Create sample movies
puts "Creating movies..."
movies_data = [
  {
    title: "The Matrix",
    description: "A computer hacker...",
    release_year: 1999
  },
  {
    title: "Inception",
    description: "A thief who steals...",
    release_year: 2010
  },
  {
    title: "Interstellar",
    description: "A team of explorers...",
    release_year: 2014
  },
  {
    title: "The Dark Knight",
    description: "When the menace known as...",
    release_year: 2008
  }
]
Movie.insert_all(movies_data)
movies = Movie.all.to_a
puts "Created #{movies.count} movies"

# Create sample watchlists
puts "Creating watchlists..."
user1 = users.find { |u| u.username == "user1" }
user2 = users.find { |u| u.username == "user2" }
user1.movies << [ movies[0], movies[1], movies[2] ]  # Matrix, Inception, Interstellar
user2.movies << [ movies[3] ]  # Dark Knight
puts "Created #{Watchlist.count} watchlist entries"

puts "\nSeed data created successfully!"
puts "Users: #{User.count}"
puts "Movies: #{Movie.count}"
puts "Watchlists: #{Watchlist.count}"
