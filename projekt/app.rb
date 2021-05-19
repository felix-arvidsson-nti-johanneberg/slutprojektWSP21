require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
#require_relative './model.rb'

enable :sessions

#include Model

get('/') do
    slim(:index)
end

get('/plans/') do
  id = session[:id].to_i
  db = SQLite3::Database.new('db/databas.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM personal_plans WHERE user_id = ?",id)
  slim(:plans,locals:{plans:result})


end

get('/groups/') do
  id = sessions[:id].to_i
  db = SQLite3::Database.new('db/databas.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users_groups_rel WHERE user_id = ?",id)
  slim(:groups,locals:{groups:result})
end

get('/groups/new') do
  slim(:gnew)
end

post('/groups') do
  groupname = params[:groupname]

  db = SQLite3::Database.new('db/databas.db')
  db.execute("INSERT INTO groups (groupname) VALUES (?)",groupname)
  redirect('/groups/')
end

post('/join') do
  groupname = params[:groupname]
  id = session[:id].to_i
  db = SQLite3::Database.new('db/databas.db')
  group_id = db.execute("SELECT id FROM groups WHERE groupname = ?",groupname)
  db.execute("INSERT INTO users_groups_rel (group_id, user_id) VALUES (?,?)",group_id,id)
  redirect('/groups/')
end

get('/plans/new') do
  slim(:new)
end

post('/plans') do
  content = params[:content]
  id = session[:id].to_i

  db = SQLite3::Database.new('db/databas.db')
  db.execute("INSERT INTO personal_plans (content, user_id) VALUES (?,?)",content,id)
  redirect('/plans/')
end

get('/plans/:id/edit') do
  
  id = params[:id].to_i
  db = SQLite3::Database.new('db/databas.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM personal_plans WHERE id = ?", id).first
  slim(:edit,locals:{result:result})
end

post("/plans/:id/update") do
  id = params[:id].to_i
  content = params[:content]
  db = SQLite3::Database.new('db/databas.db')
  db.execute("UPDATE personal_plans SET content = ? WHERE id = ?", content, id)
  redirect('/plans/')
end

post('/plans/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new('db/databas.db')
  db.execute("DELETE FROM personal_plans WHERE id = ?", id)
  redirect to('/plans/')
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
      "De lösenorden matchar inte"
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
        redirect("/")
    else
        "the passwords don't match"
    end
end