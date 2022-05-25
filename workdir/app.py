from flask import Flask
from flask import request

app = Flask("PagerMaid-Pyro for Heroku")

@app.route('/')
def home():
    return '<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, shrink-to-fit=no"><meta http-equiv="x-ua-compatible" content="ie=edge"><h1>👋 Hey There<br>This is the PagerMaid-Pyro for Heroku web view</h1>'
