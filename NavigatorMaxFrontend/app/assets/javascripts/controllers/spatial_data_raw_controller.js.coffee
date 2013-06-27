class NavigatorMaxFrontend.SpatialDataRawController extends Batman.Controller
  routingKey: 'spatial_data_raw'

  index: (params) ->
    console.log "In the index!"
    @render false
