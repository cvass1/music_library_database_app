require "spec_helper"
require "rack/test"
require_relative '../../app'

def reset_test_database_tables
  seed_sql = File.read('spec/seeds/albums_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)

  seed_sql = File.read('spec/seeds/artists_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)
end

describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  before(:each) do 
    reset_test_database_tables
  end

  # ------ ALBUMs routes --------------------------------

  context "for the ALBUMs routes: " do
    it 'lists all the albums' do
      response = get('/albums')

      expect(response.status).to eq 200
      expect(response.body).to include '<h1>Albums</h1>'
      expect(response.body).to include '<a href="/albums/1">Doolittle</a>'
      expect(response.body).to include 'Surfer Rosa'
      expect(response.body).to include 'Waterloo'
      expect(response.body).to include 'Here Comes the Sun'
      expect(response.body).to include 'Ring Ring'



    end

    it 'retreives album ID 1 the from the db' do
      response = get('/albums/1')

      expect(response.status).to eq 200
      expect(response.body).to include '<h1>Doolittle</h1>'
      expect(response.body).to include 'Release year: 1989'
      expect(response.body).to include 'Artist: Pixies'
    end

      it 'retreives album ID 2 from the db' do
      response = get('/albums/2')

      expect(response.status).to eq 200
      expect(response.body).to include '<h1>Surfer Rosa</h1>'
      expect(response.body).to include 'Release year: 1988'
      expect(response.body).to include 'Artist: Pixies'
    end

    it 'creates a new album via a form' do
      response = get('/albums/new')
      expect(response.status).to eq 200
      expect(response.body).to include '<h1>Add an album</h1>'
      expect(response.body).to include ' <form action="/albums" method="POST">'

    end

    it 'validates the parameters for POST /albums' do
      response = post('/albums', 
        invalid_title:'Voyage',
        an_invalid_param:'2022',
        another_invalid_param:'2')
      expect(response.status).to eq 400
      

    end

    it 'creates a new album' do
      response = post('/albums', 
        title:'Voyage',
        release_year:'2022',
        artist_id:'2')
      expect(response.status).to eq 200


      repo = AlbumRepository.new
      expect(repo.find(13).title).to eq 'Voyage'
      expect(repo.find(13).release_year).to eq '2022'
      expect(repo.find(13).artist_id).to eq 2
    end


    it 'uses album_id to delete the corresponding album from the database.' do
      request = delete('/albums/1')
      expect(request.status).to eq 200

      response = get('/albums/1')
      expect(response.status).to eq 500  

    end
  end

  # ------ ARTIST routes -------------------------------------------------------

  context 'for the ARTIST routes' do
    it "gets a list of all the artists" do
      response = get('/artists')
      expect(response.status).to eq(200)
      expect(response.body).to include('<a href="/artists/1"> Pixies </a>')
      expect(response.body).to include('<a href="/artists/2"> ABBA </a>')
    end

    it 'retreives artist ID 1 the from the db' do
      response = get('/artists/1')

      expect(response.status).to eq 200
      expect(response.body).to include '<h1>Pixies</h1>'
      expect(response.body).to include 'Genre: Rock'
    end

    it 'creates a new artist via a form' do
      response = get('/artists/new')
      expect(response.status).to eq 200
      expect(response.body).to include '<h1>Add an artist</h1>'
      expect(response.body).to include ' <form action="/artists" method="POST">'

    end

    it 'validates the parameters for POST /artists' do
      response = post('/artists', 
        invalid_name:'Something',
        an_invalid_param:'rocky')
      expect(response.status).to eq 400
      

    end

    it 'creates a new artist' do
      response = post('/artists',
      name: 'Wild nothing',
      genre:'Indie')

      expect(response.status).to eq 200

      repo=ArtistRepository.new
      expect(repo.find(5).name).to eq 'Wild nothing'
      expect(repo.find(5).genre).to eq 'Indie'

    end

  end
  
end
