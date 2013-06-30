window.DataTableView = class
  constructor: (dom_id) ->
    @dom_id = dom_id
    @_values = {}
  
  values: (values) ->
    @_values = values

  set: (label,value) ->
    @_values[label] = value

  render: () -> 
    $("#{@dom_id} .#{label}").html(value) for label, value of @_values
