
port = 4000
url = "http://localhost:#{port}"

server.listen(port)

validCredentials = {token: "sometoken!"}
invalidCridentials = {token: "bad token"}

describe 'socket.io-auth', ->
  socket = null

  beforeEach ->
    socket = io(url, {'force new connection': true})
    socket.on 'error', (error) ->
      console.log 'error', error

  afterEach ->
    socket.disconnect()

  context 'before authentication', ->
    it 'matks socket as unauthenticated', ->
      expect(socket.authenticated).to.not.be.ok

    it 'dose not sent messages to sockets', (done) ->
      socket.on 'pong', ->
        done(new Erro 'got message while unauthorized')
      timeout 500, done

    it 'disconnects unauthenticated sockets', (done) ->
      socket.on 'disconnect', ->
        done()

  context 'on authentication', ->
    context 'with valid cridentials', ->
      it 'authenticates and emits authenticated signal', (done) ->
        socket.on 'authenticated', ->
          done()
        socket.emit 'authenticate', validCredentials

    context 'with invalid cridentials', ->
      it 'disconnects the socket', (done) ->
        socket.on 'disconnect', ->
          done()
        socket.emit 'authenticate', invalidCridentials

  context 'after authentication', ->
    it 'handel all signals normaly', (done) ->
      socket.emit 'authenticate', {token: 'sometoken!'}
      socket.on 'pong', (data) ->
        if data == 'test message'
          done()
      socket.emit 'ping', 'test message'
