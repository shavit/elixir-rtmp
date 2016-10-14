import socket

server = socket.socket()
server.bind((socket.gethostbyname('localhost'), 3000))
server.listen(2)
while True:
    i = 0
    connection, address = server.accept()
    print('---> Receive a connection from {}'.format(address))
    # Read the data
    # while True:
    #     data = connection.recv(512)
    #     i += 1
    #     print('---> Reading bytes {}'.format(i))
    #     if not data:
    #         break
    # Send response when finish reading
    connection.send('HTTP/1.0 200 OK'.encode('utf-8'))
    connection.send('Content-Type: text/html'.encode('utf-8'))
    connection.send(bytes())
    connection.sendall('It worked'.encode('utf-8'))
    connection.sendall('It worked 2'.encode('utf-8'))
    connection.close()


if __name__ == '__main__':
    print('---> Starting server on localhost:3000')
