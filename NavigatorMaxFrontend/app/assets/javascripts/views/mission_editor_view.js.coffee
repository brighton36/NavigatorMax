window.MissionEditorView = class
  DEFAULT_INPUT_ATTRS = {type: 'text', class: 'input-medium', value: ''}

  constructor: (options) ->
    @missions = []

    @select_missions_el = options.select_missions
    @select_missions_el.find('li>a').click @_on_form_mission_select if @select_missions_el.find('li>a')

    @save_mission_el = options.save_mission
    @delete_mission_el = options.delete_mission
    @run_mission_el = options.run_mission

    @save_mission_el.click @_on_form_save if @save_mission_el?
    @delete_mission_el.click @_on_form_delete if @delete_mission_el?
    @run_mission_el.click @_on_form_run if @run_mission_el?

    @form_container = $(options.form_container)

    # On select fires when a new mission is selected:
    @on_select => 
      @delete_mission_el.removeClass('disabled') if @delete_mission_el
      @_update_form_state()

    # On change fires if an input changes:
    @on_change => 
      @_update_form_state()
      @_update_selected_mission_option()

    @on_create =>
      # Register the Mission in the option drop-down:
      opt = @_append_mission_option @selected_mission.title.value(), @selected_mission.id()
      $(opt).find('a').append @_option_asterisk()

    @on_change_attr 'title', (old_title, new_title) =>
      # This will adjust the title in the drop-down select:
      mission_anc = @_find_mission_select_option(@selected_mission.id())
      $(mission_anc).html(new_title) if mission_anc?
      @_update_selected_mission_option()

  _append_mission_option: (label, id) ->
    new_option_html = @_select_option label, id
    new_option = $(new_option_html).insertBefore @select_missions_el.find('ul li.divider')
    $(new_option).click @_on_form_mission_select
    return new_option

  # This handles the star/unstarring of the mission in the select option, to indicate
  # persistance state
  _update_selected_mission_option: ->
    select_option_el = $(@_find_mission_select_option(@selected_mission.id()))
    if @selected_mission.is_persisted()
      select_option_el.find('i').remove()
    else
      if select_option_el.find('i').length is 0
        select_option_el.append('<i class="icon-asterisk"></i>' )

  # This handles the buttons and select option changes when the form state changes:
  # Keeps things dry to consolidate this for various events
  _update_form_state: ->
    # For any attribute, we need to disable save if the record is invalid
    if @save_mission_el?
      if @selected_mission.is_valid() and @selected_mission.is_dirty()
        @save_mission_el.removeClass('disabled')
      else
        @save_mission_el.addClass('disabled')

    if @run_mission_el
      if @selected_mission.is_persisted()
        @run_mission_el.removeClass('disabled')
      else
        @run_mission_el.addClass('disabled')

  # This is intended to be a trigger for the load event having been executed:
  missions_updated: ->
    for mission in MissionModel.find({}) 
      @_append_mission_option mission.title.value(), mission.id() 

  select_mission: (mission) ->
    @selected_mission = mission

    @_form_input 'title', mission.title.value()
    @_form_input 'center_lat', mission.center_lat.value(), class: 'input-mini'
    @_form_input 'center_lon', mission.center_lon.value(), class: 'input-mini'
    @_form_input 'zoom', mission.zoom.value(), class: 'input-mini', \
      type: 'number', min: 0, max: 21
    loop_options = {type: 'checkbox'}
    loop_options.checked = true if mission.is_looping.value()
    @_form_input 'is_looping', 1, loop_options

    @_form_value 'created_at', @_date_to_s(mission.created_at.value())
    @_form_value 'distance', "#{mission.distance()} Miles"
    
    # Highlight any errors on this record:
    @selected_mission.each_attribute (key, attr) =>
      td_el = @form_container.find(".#{key}")
      if attr.is_valid()
        $(td_el).removeClass('error')
      else
        $(td_el).addClass('error')

    # And focus to the first element:
    @form_container.find('input:first').focus() 

  save_complete: -> @save_mission_el.removeClass('active')
  destroy_complete: -> @delete_mission_el.removeClass('active')

  on_change_attr: (attr, fire) ->
    @_on_change_attr ?= {}
    @_on_change_attr[attr] ?= []
    @_on_change_attr[attr].push fire
  on_dirty: (fire) ->
    @_on_dirty ?= []
    @_on_dirty.push fire
  on_create: (fire) ->
    @_on_create ?= []
    @_on_create.push fire
  on_select: (fire) ->
    @_on_select ?= []
    @_on_select.push fire
  on_change: (fire) ->
    @_on_change ?= []
    @_on_change.push fire
  on_delete: (fire) ->
    @_on_delete ?= []
    @_on_delete.push fire

  _on_form_mission_select: (e) =>
    e.preventDefault()
    mission_anc = $(e.target)
    if mission_anc.html() is 'Create New'
      new_mission = new MissionModel 
      @missions.push new_mission
      @select_mission new_mission
      @_fire_event_chain(@_on_create)
    else 
      mission = MissionModel.find_by_id(mission_anc.attr('data-mission-id'))
      @select_mission mission if mission? 
    @_fire_event_chain(@_on_select)

  _on_form_save: (e) =>
    e.preventDefault()
    unless $(e.target).hasClass('disabled')
      $(e.target).addClass('active')
      @selected_mission.save()
      @save_mission_el.addClass('disabled') if @save_mission_el
      @_update_selected_mission_option()

  _on_form_run: (e) =>
    e.preventDefault()
    unless $(e.target).hasClass('disabled')
      $(e.target).addClass('active')
      # TODO: What the hell do we do in the gui?
      @selected_mission.run()
  _on_form_delete: (e) =>
    e.preventDefault()
    unless $(e.target).hasClass('disabled')
      mission_title = @selected_mission.title.value()
      if confirm("Are you sure you wish to delete \"#{mission_title}\"")
        $(e.target).addClass('active')
        mission_id = @selected_mission.id()
        @selected_mission.destroy()
        @selected_mission = null

        # Remove this mission from the option group:
        mission_el = @_find_mission_select_option mission_id
        $(mission_el).parent('li').remove()

        # And 'reset' the form to its defaults:
        # NOTE: This probably needs to have an event registered
        @form_container.find('td').html('<span class="muted">(None)</span>')
        for el in [@save_mission_el, @delete_mission_el, @run_mission_el]
          el.addClass('disabled')
        @_fire_event_chain(@_on_delete)
  _on_form_input_change: (e) =>
    e.preventDefault()
    name_parts = /^[^\[]+\[(.*)\]$/.exec($(e.target).attr('name'))

    changed_attr = name_parts[1] if name_parts?
    if changed_attr? and @selected_mission.hasOwnProperty(changed_attr)
      record_was_dirty = @selected_mission.is_dirty()

      new_html_value = switch $(e.target).attr('type')
        when 'checkbox'
          $(e.target).attr('checked') == 'checked'
        else
          $(e.target).val()
      old_value = @selected_mission[changed_attr].value()

      @selected_mission[changed_attr].set(new_html_value)
      new_value = @selected_mission[changed_attr].value()

      el_parent = $(e.target).parent('td')

      if @selected_mission[changed_attr].is_valid()
        el_parent.removeClass('error')
      else 
        el_parent.addClass('error')
      
      if old_value isnt new_value
        @fire_on_change()
        @_fire_on_change_attr changed_attr, old_value, new_value

      @_fire_event_chain @_on_dirty if !record_was_dirty and @selected_mission[changed_attr].is_dirty()

  fire_on_change: ->
    @_fire_event_chain @_on_change

  _find_mission_select_option: (mission_id) ->
    els = $("a[data-mission-id=\"#{mission_id}\"]") 
    if els.length is 1 then els[0] else null
  _date_to_s: (date) ->
    [date.getMonth()+1, date.getDate(), date.getFullYear()].join('/') + ' at ' + \
    [date.getHours(), date.getMinutes()].join(':') + ' EST'
  _form_input: (attr, value, attribs = {}) ->
    input_attrs = $.extend({}, attribs, {name:"mission[#{attr}]", value: value})
    td_html = @form_container.find(".#{attr}").html(@_input(input_attrs))
    td_html.find('input').change @_on_form_input_change
  _form_value: (attr, value) ->
    @form_container.find(".#{attr}").html(value)
  _input: (attribs = {}) ->
    elprops = $.extend({}, DEFAULT_INPUT_ATTRS, attribs)
    "<input "+$.map( elprops, (val,attr) -> "#{attr}=\"#{val}\"").join(' ')+" />"
  _select_option: (title, mission_id) ->
    "<li><a href=\"#\" tabindex=\"-1\" data-mission-id=\"#{mission_id}\">#{title}</a></li>"
  _option_asterisk: ->
    '<i class="icon-asterisk"></i>' 
  _fire_on_change_attr: (attr, old_value, new_value) ->
    if @_on_change_attr? and @_on_change_attr[attr]
      fire(old_value, new_value) for fire in @_on_change_attr[attr]
  _fire_event_chain: (chain) ->
    if chain?
      fire() for fire in chain

window.WaypointEditorView = class
  EMPTY_WAYPOINT = {lat: null, lon: null}

  constructor: (options) ->
    @selected_index = null

    @mission_view = options.mission_view
    @map_view = options.map_view
    @form_container = options.form_container
    @select_waypoints_el = options.select_waypoints
    if @select_waypoints_el
      @select_waypoints_el.click (e) -> e.preventDefault()
      @select_waypoints_el.find('li>a').click @_on_form_waypoint_select if @select_waypoints_el.find('li>a')
    
    @delete_waypoint_el = options.delete_waypoint

    @delete_waypoint_el.click @_on_form_delete if @delete_waypoint_el?

    @mission_view.on_select =>
      @_update_form_state()
      @_clear_waypoints_select()
      # Ensure our option list is enabled:
      if @mission_view.selected_mission?
        @select_waypoints_el.find('a.btn').removeClass('disabled')
        # Now populate the waypoints:
        @_repopulate_waypoints_from_selected_mission()

    @mission_view.on_delete =>
      @selected_index = null
      @_clear_waypoints_select()
      @_update_form_state()

  _repopulate_waypoints_from_selected_mission: ->
    waypoints = @mission_view.selected_mission.waypoints.value()
    @_append_waypoint i for waypoint, i in waypoints

  _clear_waypoints_select: ->
    # Remove the waypoints from the option group:
    @select_waypoints_el.find('li.divider').prevAll().remove()

  _on_form_waypoint_select: (e) =>
    e.preventDefault()
    waypoint_anc = $(e.target)
    if waypoint_anc.html() is 'Create New'
      waypoints = @mission_view.selected_mission.waypoints.value()
      waypoints.push $.extend({}, EMPTY_WAYPOINT )
      @mission_view.selected_mission.waypoints.set(waypoints)
      @selected_index = waypoints.length - 1
      @_append_waypoint @selected_index
      @_update_form_state()
      @mission_view.fire_on_change()
    else 
      @selected_index = parseInt(waypoint_anc.attr('data-waypoint-id'))
      @_update_form_state()

  _update_form_state: ->
    if @selected_index?
      waypoints = @mission_view.selected_mission.waypoints.value()
      waypoint = waypoints[@selected_index]
      prior_waypoint = waypoints[@selected_index-1]

      distance_in_m = null
      if prior_waypoint? && prior_waypoint.lat? && prior_waypoint.lon? && waypoint.lat? && waypoint.lon?
        distance_in_m = parseInt( @latlon_distance_in_km(prior_waypoint.lat, 
          prior_waypoint.lon, waypoint.lat, waypoint.lon) * 1000)

      @_form_value 'offset', @selected_index
      @_form_value 'lat', waypoint.lat
      @_form_value 'lon', waypoint.lon
      @_form_value 'choose_location', \
        "<button class=\"btn btn-mini\" type=\"button\">Select</button>"
      @_form_value 'length', (if distance_in_m then "#{distance_in_m} m" else "N/A")
      @delete_waypoint_el.removeClass 'disabled'

      @form_container.find('.choose_location button').click @_on_select_location
      @form_container.find('.choose_location button').removeClass('disabled');
    else
      @form_container.find('td').html('<span class="muted">(None)</span>')
      @delete_waypoint_el.addClass('disabled')
      if @mission_view.selected_mission?
        @select_waypoints_el.find('a.btn').removeClass('disabled')
      else
        @select_waypoints_el.find('a.btn').addClass('disabled')

  _on_select_location: (e) =>
    $('html').css 'cursor', 'pointer'
    $(e.target).addClass('disabled');

    $(@map_view.dom_id()).bind 'click.waypoint_select', @_on_pick_location

  _on_pick_location: (e) =>
    $(@map_view.dom_id()).unbind 'click.waypoint_select'
    [lat, lon] = @map_view.canvas_to_latlon(e.offsetX, e.offsetY)
    waypoints = @mission_view.selected_mission.waypoints.value()
    waypoint = waypoints[@selected_index]
    waypoint.lat = lat
    waypoint.lon = lon

    $('html').css 'cursor', 'auto'
    @_update_form_state()

  _on_form_delete: (e) =>
    e.preventDefault()
    unless $(e.target).hasClass('disabled')
      if @selected_index?
        waypoints = @mission_view.selected_mission.waypoints.value()
        waypoints.splice(@selected_index, 1)
        @mission_view.selected_mission.waypoints.set(waypoints)
        @selected_index = null
        @_clear_waypoints_select()
        @_repopulate_waypoints_from_selected_mission()
        @_update_form_state()

  _append_waypoint: (i) ->
    @_append_waypoint_option "Waypoint #{i + 1}", i

  # NOTE: I grabbed this from: http://www.movable-type.co.uk/scripts/latlong.html
  latlon_distance_in_km: (lat1, lon1, lat2, lon2) ->
    R = 6371 # Note: This is in km
    
    φ1 = lat1 * Math.PI / 180
    φ2 = lat2 * Math.PI / 180
    Δφ = (lat2-lat1) * Math.PI / 180
    Δλ = (lon2-lon1) * Math.PI / 180

    a = Math.sin(Δφ/2) * Math.sin(Δφ/2) + Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ/2) * Math.sin(Δλ/2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    R * c

  _append_waypoint_option: (label, id) ->
    new_option_html = @_select_option label, id
    new_option = $(new_option_html).insertBefore @select_waypoints_el.find('ul li.divider')
    $(new_option).click @_on_form_waypoint_select
    return new_option
  _form_value: (attr, value) ->
    @form_container.find(".#{attr}").html(value)
  _select_option: (label, index) ->
    "<li><a href=\"#\" tabindex=\"-1\" data-waypoint-id=\"#{index}\">#{label}</a></li>"


