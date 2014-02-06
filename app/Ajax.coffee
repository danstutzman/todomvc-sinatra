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
    if method is 'POST'
      x.setRequestHeader 'Content-type',
        'application/x-www-form-urlencoded'
    x.send data

  get: (url, data, callback, sync) ->
    query = []
    for own key of data
      parts = [encodeURIComponent(key), encodeURIComponent(data[key])]
      query.push parts.join('=')
    url += '?' + query.join('&') unless query.length == 0
    Ajax.send url, callback, 'GET', null, sync

  post: (url, data, callback, sync) ->
    query = []
    for own key of data
      parts = [encodeURIComponent(key), encodeURIComponent(data[key])]
      query.push parts.join('=')
    Ajax.send url, callback, 'POST', query.join('&'), sync

module.exports = Ajax
