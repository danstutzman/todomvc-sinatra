Utils =
  pluralize: (count, word) ->
    if count is 1
      word
    else
      word + 's'

module.exports = Utils
