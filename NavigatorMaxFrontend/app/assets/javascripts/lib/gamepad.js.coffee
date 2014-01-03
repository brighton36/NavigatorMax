# This is really hacky at the moment. I've only tested it with chrome, using an
# Xbox360 controller on OS X.
window.GamePad = class
  @BTN_GREEN_A = 0
  @BTN_RED_B = 1
  @BTN_BLUE_X = 2
  @BTN_YELLOW_Y = 3
  @BTN_LEFT_TOP = 4
  @BTN_RIGHT_TOP = 5
  @BTN_LEFT_TRIGGER = 6
  @BTN_RIGHT_TRIGGER = 7
  @BTN_SELECT = 8
  @BTN_START = 9
  @BTN_ANALOG_LEFT = 10
  @BTN_ANALOG_RIGHT = 11
  @BTN_DPAD_UP = 12
  @BTN_DPAD_DOWN = 13
  @BTN_DPAD_LEFT = 14
  @BTN_DPAD_RIGHT = 15
  @BTN_XBOX_LOGO = 16

  @AXIS_LEFT_X = 0
  @AXIS_LEFT_Y = 1
  @AXIS_RIGHT_X = 2
  @AXIS_RIGHT_Y = 3

  @is_supported: -> navigator.webkitGetGamepads || navigator.webkitGamepads

  constructor: ->
    # State Tracking:
    @pad_change_this_poll = false
    @gamepad_types_prior = []
    @timestamps_prior = []
    @buttons_prior = []
    @gamepads = []

    # Event handlers:
    @_on_button_down = []

  is_controller_avalable?(controller_index) ->
    @gamepads[controller_index]?

  on_button_down: (controller_index, btn_index, fire) ->
    @_on_button_down[controller_index] ?= []
    @_on_button_down[controller_index][btn_index] = fire

  right_trigger: (controller_index) -> @button controller_index, @constructor.BTN_RIGHT_TRIGGER

  left_trigger: (controller_index) -> @button controller_index, @constructor.BTN_LEFT_TRIGGER

  button: (controller_index, button_index) ->
    @gamepads[controller_index].buttons[button_index] if @gamepads.length > controller_index

  left_analog: (controller_index) ->
    @axis controller_index, @constructor.AXIS_LEFT_X, @constructor.AXIS_LEFT_Y

  right_analog: (controller_index) ->
    @axis controller_index, @constructor.AXIS_RIGHT_X, @constructor.AXIS_RIGHT_Y

  axis: (controller_index, axes...) ->
    if @gamepads.length > controller_index
      ret = []
      ret.push @gamepads[controller_index].axes[axis_index] for axis_index in axes
      if ret.length > 0 then ret else ret[0]

  # This stores our state internally, so that anytime the app needs to know a
  # value, it can just ask for it.
  poll: ->
    # Get the array of gamepads – the first method (function call)
    # is the most modern one, the second is there for compatibility with
    # slightly older versions of Chrome, but it shouldn’t be necessary
    # for long.
    raw_gamepads = (navigator.webkitGetGamepads && navigator.webkitGetGamepads()) || navigator.webkitGamepads

    if (raw_gamepads)
      # We don’t want to use raw_gamepads coming straight from the browser,
      # since it can have “holes” (e.g. if you plug two gamepads, and then
      # unplug the first one, the remaining one will be at index [1]).
      @gamepads = []

      @pad_changed_on_poll = false
      for raw_gamepad, i in raw_gamepads
        if (typeof raw_gamepads[i] != @gamepad_types_prior[i])
          @pad_changed_on_poll = true
          @gamepad_types_prior[i] = typeof raw_gamepads[i]

        @gamepads.push raw_gamepads[i] if raw_gamepads[i]?
      @_trigger_on_attach() if @pad_changed_on_poll

      for gamepad, i in @gamepads
        gamepad = @gamepads[i]
        
        if gamepad? and (gamepad.timestamp != @timestamps_prior[i])
          # Let's solve some problems, and not fire if they just plugged in 
          # controllers:
          @_trigger_on_press i unless @pad_changed_on_poll

          # Record the state for use in the next go around
          @timestamps_prior[i] = gamepad.timestamp
          @buttons_prior[i] = gamepad.buttons.slice(0)

  _trigger_on_attach: ->
    # TODO: Maybe fire a method here at some point?

  _trigger_on_press: (controller_index) ->
    if @buttons_prior[controller_index]?
      for event, btn_index in @_on_button_down[controller_index]
        if event?
          btn_state_prior = @buttons_prior[controller_index][btn_index]
          btn_state_now = @gamepads[controller_index].buttons[btn_index]
          event() if btn_state_now == 1 and btn_state_prior == 0

