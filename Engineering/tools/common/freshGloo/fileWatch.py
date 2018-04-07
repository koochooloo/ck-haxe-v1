###############################################################################
#
# The MIT License (MIT)
#
# Copyright (c) Crossbar.io Technologies GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
###############################################################################

import sys
import time
import logging

from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

from twisted.python import log
from twisted.internet import reactor

from autobahn.twisted.websocket import WebSocketServerProtocol, \
    WebSocketServerFactory

class FileWatchEventHandler(FileSystemEventHandler):

    def __init__(self, server):
        FileSystemEventHandler.__init__(self)
        self._server = server

    def on_modified(self, event):
        FileSystemEventHandler.on_modified(self, event)
        self._server.onChangeDetected(event.src_path)


class FileWatchServerProtocol(WebSocketServerProtocol):

    activeServer = None

    def checkForChanges(self):
        time.sleep(1)
        event_handler = FileWatchEventHandler(self)
        self._observer = Observer()
        if(FileWatchServerProtocol.activeServer != None):
            self._path = FileWatchServerProtocol.activeServer.getWatchPath()
        else:
            self._path = "."
        self._observer.schedule(event_handler, self._path, recursive=True)
        self._observer.start()

    def onConnect(self, request):
        print("Client connecting: {0}".format(request.peer))

    def onOpen(self):
        print("WebSocket connection open.")
        self.checkForChanges()

    def onClose(self, wasClean, code, reason):
        print("WebSocket connection closed: {0}".format(reason))
        self._observer.stop()
        self._observer.join()

    def onChangeDetected(self, changedFile):
        logString = "PLACEHOLDER"
        if(FileWatchServerProtocol.activeServer != None):
            logString = FileWatchServerProtocol.activeServer.getOnChangedMessage(changedFile)
        else:
            logString = u"NO ACTIVE SERVER"
            print(logString)
        self.sendMessage(logString.encode('utf8'))

class FileWatchServer():

    def __init__(self, directory, host, port):
        self._directory = directory
        self._host = host
        self._port = port

        self._factory = WebSocketServerFactory(u"ws://" + host + ":" + str(port))
        FileWatchServerProtocol.activeServer = self
        self._factory.protocol = FileWatchServerProtocol

    def start(self):
        log.startLogging(sys.stdout)

        reactor.listenTCP(self._port, self._factory)
        reactor.run()

    def getWatchPath(self):
        return self._directory

    def getOnChangedMessage(self, changedFile):
        logString = u"File Watch: change in file detected: " + changedFile
        print(logString)

if __name__ == '__main__':

    serverDir = sys.argv[1] if len(sys.argv) > 1 else '.'
    serverHost = sys.argv[2] if len(sys.argv) > 2 else '127.0.0.1'
    serverPort = sys.argv[3] if len(sys.argv) > 3 else 9001

    server = FileWatchServer(serverDir, serverHost, serverPort)
    server.start()
