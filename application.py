import os
import time
from flask import Flask, render_template, redirect, url_for, flash
from flask_login import LoginManager, login_user, current_user, logout_user
from flask_socketio import SocketIO, join_room, leave_room, send
from passlib.hash import pbkdf2_sha256

from wtform_fields import *
from db import db
from models import User

# ----------------------
# Configure app
# ----------------------
app = Flask(__name__)
app.secret_key = os.environ.get('SECRET')
app.config['WTF_CSRF_SECRET_KEY'] = "b'f\xfa\x8b{X\x8b\x9eM\x83l\x19\xad\x84\x08\xaa"
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# ----------------------
# Initialize extensions
# ----------------------
db.init_app(app)  # attach db to app

login = LoginManager(app)
login.init_app(app)

socketio = SocketIO(app, manage_session=False)

# ----------------------
# User loader
# ----------------------
@login.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# ----------------------
# Predefined rooms
# ----------------------
ROOMS = ["lounge", "news", "games", "coding"]

# ----------------------
# Routes
# ----------------------
@app.route("/", methods=['GET', 'POST'])
def index():
    reg_form = RegistrationForm()
    if reg_form.validate_on_submit():
        username = reg_form.username.data
        password = reg_form.password.data
        hashed_pswd = pbkdf2_sha256.hash(password)
        user = User(username=username, hashed_pswd=hashed_pswd)
        db.session.add(user)
        db.session.commit()
        flash('Registered successfully. Please login.', 'success')
        return redirect(url_for('login'))
    return render_template("index.html", form=reg_form)

@app.route("/login", methods=['GET', 'POST'])
def login():
    login_form = LoginForm()
    if login_form.validate_on_submit():
        user_object = User.query.filter_by(username=login_form.username.data).first()
        if user_object:
            login_user(user_object)
            return redirect(url_for('chat'))
        else:
            flash('Invalid username', 'danger')
    return render_template("login.html", form=login_form)

@app.route("/logout")
def logout():
    logout_user()
    flash('You have logged out successfully', 'success')
    return redirect(url_for('login'))

@app.route("/chat")
def chat():
    if not current_user.is_authenticated:
        flash('Please login', 'danger')
        return redirect(url_for('login'))
    return render_template("chat.html", username=current_user.username, rooms=ROOMS)

# ----------------------
# Error handler
# ----------------------
@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404

# ----------------------
# SocketIO events
# ----------------------
@socketio.on('incoming-msg')
def on_message(data):
    msg = data["msg"]
    username = data["username"]
    room = data["room"]
    time_stamp = time.strftime('%b-%d %I:%M%p', time.localtime())
    send({"username": username, "msg": msg, "time_stamp": time_stamp}, room=room)

@socketio.on('join')
def on_join(data):
    username = data["username"]
    room = data["room"]
    join_room(room)
    send({"msg": f"{username} has joined the {room} room."}, room=room)

@socketio.on('leave')
def on_leave(data):
    username = data['username']
    room = data['room']
    leave_room(room)
    send({"msg": f"{username} has left the room"}, room=room)

# ----------------------
# Main
# ----------------------
if __name__ == "__main__":
    with app.app_context():
        db.create_all()
    socketio.run(app, debug=True, host="0.0.0.0", port=5000)

