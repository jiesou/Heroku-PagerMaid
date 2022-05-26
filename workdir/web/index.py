from os import environ
import wsgiserver

def application(env, start_response):
    start_response('200 OK', [('Content-Type', 'text/plain')])
    return [b'This is the PagerMaid-Pyro for Heroku web view']

try:
    web_port = int(environ.get('PORT'))
except:
    web_port = 80

print("启动 Web 仪表盘 . . . 端口{:d}".format(web_port))

server = wsgiserver.WSGIServer(application, host='0.0.0.0', port=web_port)
server.start()
