/*jslint browser: true */
/*global window, WebSocket, Error*/
(function (window) {
  'use strict';
  var Socket = function Socket(options) {
    this.options = options || {};
    this.topicCallbacks = {};
    this.websocket = null;
    this.init();
  };

  Socket.prototype = {
    init: function init() {
      if (!this.options.uri) {
        this.error('Missing URI');
      }
      this.websocket = new WebSocket(this.options.uri);
      this.websocket.onmessage = this.defaults.onMessage(this);
    },
    error: function error(message, shouldReturn) {
      var err = new Error('Socket: ' + message);
      if (shouldReturn === undefined || shouldReturn !== true) {
        throw err;
      }
      return err;
    },
    defaults: {
      onMessage: function onMessage(that) {
        return function onMessage(e) {
          var obj = JSON.parse(e.data);
          var callback = that.topicCallbacks[obj.event];
          if (callback) {
            callback(obj.data);
          }
        };
      }
    },
    send: function send(event, data) {
      var message = JSON.stringify({
        event: event,
        data: data
      });
      this.websocket.send(message);
    },
    close: function close() {
      this.websocket.close();
    },
    on: function on(topic, callback) {
      this.topicCallbacks[topic] = callback;
      return this;
    },
    onOpen: function (callback) {
      this.websocket.onopen = callback;
      return this;
    },
    onClose: function (callback) {
      this.websocket.onclose = callback;
      return this;
    },
    onError: function (callback) {
      this.websocket.onerror = callback;
      return this;
    },
    onMessage: function (callback) {
      this.websocket.onmessage = callback;
      return this;
    }
  };

  window.Socket = Socket;
}(window));