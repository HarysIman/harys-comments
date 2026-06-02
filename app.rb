require 'sinatra'
require 'sqlite3'
require 'json'

DB_PATH = ENV.fetch('DB_PATH', '/data/comments.db')

def db
  @db ||= begin
    FileUtils.mkdir_p(File.dirname(DB_PATH))
    conn = SQLite3::Database.new(DB_PATH)
    conn.results_as_hash = true
    conn.execute(<<~SQL)
      CREATE TABLE IF NOT EXISTS comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
    conn
  end
end

before do
  content_type 'application/json'
  headers \
    'Access-Control-Allow-Origin'  => '*',
    'Access-Control-Allow-Methods' => 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers' => 'Content-Type'
end

options '*' do
  200
end

get '/comments' do
  db.execute('SELECT * FROM comments ORDER BY created_at ASC').to_json
end

post '/comments' do
  body = JSON.parse(request.body.read) rescue halt(400, { error: 'Invalid JSON' }.to_json)
  name    = body['name'].to_s.strip
  message = body['message'].to_s.strip

  halt 422, { error: 'Nama dan pesan wajib diisi' }.to_json  if name.empty? || message.empty?
  halt 422, { error: 'Nama terlalu panjang' }.to_json        if name.length > 100
  halt 422, { error: 'Pesan terlalu panjang' }.to_json       if message.length > 1000

  db.execute('INSERT INTO comments (name, message) VALUES (?, ?)', [name, message])
  status 201
  { ok: true }.to_json
end

get '/health' do
  { status: 'ok' }.to_json
end
