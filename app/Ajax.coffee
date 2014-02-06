Ajax =

  send: (url, callback, method, data, sync) ->
    x = new XMLHttpRequest()
    x.open method, url, sync
    x.onreadystatechange = ->
      if x.readyState is 4
        if x.status != 200
          throw new Error("Status #{x.status} from #{method} #{url}")
        else
          callback x.responseText
    if method is 'POST' or method is 'PUT'
      x.setRequestHeader 'Content-type',
        'application/x-www-form-urlencoded'
    x.send data

  join_query: (data) ->
    query = []
    for own key of data
      parts = [encodeURIComponent(key), encodeURIComponent(data[key])]
      query.push parts.join('=')
    query.join('&')

  get: (url, data, callback, sync) ->
    url += '?' + @join_query(data)
    Ajax.send url, callback, 'GET', null, sync

  post: (url, data, callback, sync) ->
    Ajax.send url, callback, 'POST', @join_query(data), sync

  put: (url, data, callback, sync) ->
    Ajax.send url, callback, 'PUT', @join_query(data), sync

module.exports = Ajax
