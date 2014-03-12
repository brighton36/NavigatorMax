window.ModelAttribute = class
  constructor: (model, value, is_persisted) -> 
    @_model = model
    @_value = value
    @_persisted_value = null
    if is_persisted then @_mark_persisted() else @_mark_unpersisted()
  set: (value) -> 
    if value isnt @_value
      @_is_persisted = false
      @_value = value
  value: -> @_value
  persisted_value: -> @_persisted_value
  is_persisted: -> @_is_persisted
  is_dirty: -> !@is_persisted()
  is_valid: -> 
    if @is_dirty()
      for own key, value of @_model
        return @_model.is_attribute_valid(key) if value is @
      return false # This shouldn't ever be the case
    else
      true
  _mark_unpersisted: -> @_is_persisted = false
  _mark_persisted: -> 
    unless @_is_persisted
      @_is_persisted = true
      @_persisted_value = @_value

window.Model = class
  @add: (model) ->
    @_models ?= []
    @_models.push model
  @find: (attrs) ->
    found = []
    for m in @_models
      if m?
        found.push m if @_all(attrs, (key, value) -> m[key].value() is value)
    found
  @find_first: (attrs) ->
    for m in @_models
      if m?
        return m if @_all(attrs, (key, value) -> m[key].value() is value)
    return nil
  @find_by_id: (id) -> @_models[parseInt(id)]
  @_all: (pairs, is_truth) ->
    for own key, value of pairs
      return false unless is_truth(key, value)
    return true
  id: ->
    i = 0
    for model in @constructor._models
      return i if model is @
      i++
    return null

  constructor: (attributes, is_persisted = false) ->
    @_attributes = []
    for own key, value of attributes
      @_attributes.push key
      @[key] = new ModelAttribute @, value, is_persisted 
    @constructor.add @
  is_valid: ->
    @_are_all_attributes (lbl, attr) -> attr.is_valid()
  is_dirty: ->
    @_is_any_attribute (lbl, attr) -> attr.is_dirty()
  is_persisted: -> !@is_dirty()

  save: ->
    console.log("TODO: save")
    @each_attribute (key, attr) -> attr._mark_persisted()
  destroy: ->
    console.log("TODO: destroy")
    @constructor._models[@id()] = null

  is_attribute_valid: (attr) ->
    if @_validations? and @_validations[attr]
      for against in @_validations[attr]
        return false unless against(@[attr].value()) 
    return true

  each_attribute: (against) ->
    against(key, @[key]) for key in @_attributes

  _are_all_attributes: (against) ->
    for key in @_attributes
      return false unless against(key, @[key]) 
    true
  _is_any_attribute: (against) ->
    for key in @_attributes
      return true if against(key, @[key]) 
    false
  _validate: (attr, against) ->
    @_validations ?= {}
    @_validations[attr] ?= []
    @_validations[attr].push against

