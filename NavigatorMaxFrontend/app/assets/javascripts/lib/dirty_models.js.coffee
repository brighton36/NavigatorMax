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
    if @_models?
      for m in @_models
        found.push m if @_all(attrs, (key, value) -> m[key].value() is value)
    found
  @find_first: (attrs) ->
    if @_models?
      for m in @_models
        return m if @_all(attrs, (key, value) -> m[key].value() is value)
    return nil
  @find_by_id: (id) -> 
    if @_models?
      for m in @_models
        return m if m.id() is parseInt(id) 
    return nil
  @_all: (pairs, is_truth) ->
    return false unless pairs?
    for own key, value of pairs
      return false unless is_truth(key, value)
    return true
  @_generate_id: -> 
    @_id_incrementer ?= 0
    @_id_incrementer++
  @_register_id: (persisted_id) -> 
    @_id_incrementer ?= 0
    @_id_incrementer = persisted_id + 1 if persisted_id >= @_id_incrementer
  @_destroy: (id) ->
    ret = false
    for m, i in @_models
      if m.id() is parseInt(id) 
        @_models.splice(i,1) 
        ret = true
        break
    return ret

  constructor: (attributes, is_persisted = false) ->
    # First take care of the id assignments:
    if attributes.hasOwnProperty('id') and attributes['id'] isnt NaN
      @_id = parseInt attributes['id']
      @constructor._register_id @_id
      delete attributes['id']
    else
      @_id = @constructor._generate_id()

    # Now take care of the attributes:
    @_attributes = []
    for own key, value of attributes
      @_attributes.push key
      @[key] = new ModelAttribute @, value, is_persisted 
    @constructor.add @
    @_is_new = if is_persisted then false else true
  id: -> @_id
  is_valid: ->
    @_are_all_attributes (lbl, attr) -> attr.is_valid()
  is_dirty: ->
    @_is_any_attribute (lbl, attr) -> attr.is_dirty()
  is_new: -> @_is_new
  is_persisted: -> !@is_dirty()
  to_json: ->
    ret = { id: @id() }
    ret[key] = @[key].value() for key in @_attributes
    ret
  save: ->
    @_is_new = false
    # Note: at the moment, it's the inherited model's job to persist
    @each_attribute (key, attr) -> attr._mark_persisted()
  destroy: ->
    # Note: at the moment, it's the inherited model's job to destroy
    @constructor._destroy(@id())

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

