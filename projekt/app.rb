require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

get('/') do
    slim(:index)
end

get('/plans/') do
    slim(:plans)
end

post('/plans') do

end

get('/showlogin') do
    slim(:login)
end

get('/register') do
  slim(:register)
end

post('/login') do
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    pwdigest = result["pwdigest"]
    id = result["id"]
    if BCrypt::Password.new(pwdigest) == password
      session[:id] = id
      redirect('/plans/')
    else
      "FEEEl"
    end
  
  
  end
  

post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]

    if (password == password_confirm)
        #lägg till användare
        password_digest = BCrypt::Password.create(password)
        db = SQLite3::Database.new('db/databas.db')
        db.execute("INSERT INTO users (username,pwdigest) VALUES (?,?)",username,password_digest)
        redirect("/plans/")
    else
        "the passwords don't match"
    end
end