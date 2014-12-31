
module.exports = (mongoose) ->

  # monkeypatch so lean documents include an `id` property
  for method in ['find', 'findOne', 'exec']
    do ->
      oldMethod = mongoose.Query::[method]
      mongoose.Query::[method] = (args...) ->
        return oldMethod.call(@, args...) unless @_mongooseOptions.lean # quick out
        cb = args.pop()
        if typeof cb isnt 'function'
          args.push cb
          oldMethod.apply @, args
        else
          oldMethod.call @, args..., (err, docs) ->
            if Array.isArray(docs) # many
              doc.id ?= doc._id?.toString() for doc in docs
            else if docs?._id?      # one
              docs.id ?= docs._id.toString()
            cb?(err, docs)
  
  # monkeypatch so lean is on by default
  setOptionsWithoutLean = mongoose.Query::setOptions
  setOptionsWithLean = (args...) ->
    setOptionsWithoutLean.apply @, args
    @_mongooseOptions.lean ?= true
    @
  mongoose.Query::setOptions = setOptionsWithLean
  
  # syntactic sugar for fat models
  mongoose.Query::fat = ->
    @lean(false)
    @

