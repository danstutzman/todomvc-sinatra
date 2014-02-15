Deferred = require('deferred').Deferred
if typeof(window) != 'undefined'
  XMLHttpRequest = window.XMLHttpRequest
else
  XMLHttpRequest = require('xmlhttprequest').XMLHttpRequest

TIMEOUT_MILLIS = 2000

Ajax =
  send: (method, url, data) ->
    canceled = false
    x = new XMLHttpRequest()
    x.open method, url, true # true for async
    x.onreadystatechange = ->
      if x.readyState is 4
        return if canceled
        clearTimeout(timeout)
        if x.status != 200
          deferred.reject(new Error("Status #{x.status} from #{method} #{url}"))
        else
          deferred.resolve(x.responseText)
    if method is 'POST' or method is 'PUT'
      x.setRequestHeader 'Content-type',
        'application/x-www-form-urlencoded'
    x.send data
    deferred = new Deferred()
    outOfTime = ->
      canceled = true
      x.abort()
      deferred.reject(new Error("Timeout after #{TIMEOUT_MILLIS} ms"))
    timeout = setTimeout(outOfTime, TIMEOUT_MILLIS)
    deferred.promise

  join_query: (data) ->
    query = []
    for own key of data
      parts = [encodeURIComponent(key), encodeURIComponent(data[key])]
      query.push parts.join('=')
    query.join('&')

  get: (url, data) ->
    data = @join_query(data) unless typeof(data) == 'string'
    url += '?' + data unless data == ''
    Ajax.send 'GET', url, null

  post: (url, data) ->
    data = @join_query(data) unless typeof(data) == 'string'
    Ajax.send 'POST', url, data

  put: (url, data) ->
    data = @join_query(data) unless typeof(data) == 'string'
    Ajax.send 'PUT', url, data

  delete: (url, data) ->
    data = @join_query(data) unless typeof(data) == 'string'
    Ajax.send 'DELETE', url, data

module.exports = Ajax
