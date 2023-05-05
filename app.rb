# file: app.rb
require 'sinatra'
require "sinatra/reloader"
require_relative 'lib/database_connection'
require_relative 'lib/album_repository'
require_relative 'lib/artist_repository'

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/album_repository'
    also_reload 'lib/artist_repository'
  end

  get '/' do
    return "hello from caroline's music library website :-D"
  end

  # ------ ALBUMs routes --------------------

  get '/albums' do
    repo = AlbumRepository.new
    @result_set = repo.all

    return erb(:albums)
  end

  get '/albums/new' do
    return erb(:new_album)
  end
  
  get '/albums/:id' do
    album_repo = AlbumRepository.new
    artist_repo = ArtistRepository.new

    album = album_repo.find(params[:id])

    @album_title = album.title
    @album_release_year = album.release_year
    @artist_name = artist_repo.find(album.artist_id).name

    return erb(:album)

  end

  post '/albums' do
    if invalid_album_request_params? then
      status 400
      return 'Invalid parameters'
    end


    repo = AlbumRepository.new
    new_album = Album.new
    new_album.title = params[:title]
    new_album.release_year = params[:release_year]
    new_album.artist_id = params[:artist_id]
    repo.create(new_album)

  end
  

  delete '/albums/:id' do
    album_id = params[:id]
  
    # Use album_id to delete the corresponding
    # album from the database.
    repo = AlbumRepository.new

    result = repo.delete(album_id)

    return nil

  end

  def invalid_album_request_params?
    params[:title] == nil ||  params[:title].match?(/[^a-zA-Z0-9 ]/) ||  
      params[:release_year] == nil || params[:release_year].match?(/[^a-zA-Z0-9 ]/) ||
      params[:artist_id] == nil || params[:artist_id].match?(/[^a-zA-Z0-9 ]/) 
  end

  # ------ ARTIST routes --------------------

  get '/artists' do
    repo = ArtistRepository.new
    @artists = repo.all
    return erb(:artists)
  end

  get '/artists/new' do
    return erb(:new_artist)
  end

  get '/artists/:id' do
    repo = ArtistRepository.new
    @artist = repo.find(params[:id])
    return erb(:artist)
  end

  post '/artists' do
    if invalid_artist_request_params? then
      status 400
      return 'Invalid parameters'
    end

    repo = ArtistRepository.new
    new_artist = Artist.new

    new_artist.name = params[:name]
    new_artist.genre = params[:genre]

    repo.create(new_artist)

  end

  def invalid_artist_request_params?
    params[:name] == nil || params[:name].match?(/[^a-zA-Z0-9 ]/) ||
      params[:genre] == nil || params[:genre].match?(/[^a-zA-Z0-9 ]/)
  end



end