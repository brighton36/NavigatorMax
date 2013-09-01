window.DataTableView = class
  constructor: (dom_id) ->
    @table = $($(dom_id)[0])
    @_values = {}
  
  values: (values) ->
    @_values = values

  set: (label,value) ->
    @_values[label] = value

  render: () -> 
    @table.find(".#{label}").html(value) for label, value of @_values

  add_row: (header, cell_classes) ->
    cell_classes = [] unless cell_classes?
    td_html = ''
    td_html += "<td class=\"#{cell_class}\"></td>" for cell_class in cell_classes
    @table.find('tbody:last').append("<tr><th>#{header}</th>"+td_html+"</tr>");
    
