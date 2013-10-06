class GMapStaticTile
  include HTTParty
  base_uri 'maps.googleapis.com'

  GOOGLE_TILE_SIZE = 256
  INITIAL_RESOLUTION = 2 * Math::PI * 6378137 / GOOGLE_TILE_SIZE
  ORIGIN_SHIFT = 2 * Math::PI * 6378137 / 2.0
  RENDER_TILE_SIZE = 512

  TILE_TO_PNG = '/maps/api/staticmap?format=%s&center=%s,%s&zoom=%s&size=%sx%s&maptype=satellite&sensor=false'

  def initialize(zoom, tx, ty)
    @zoom, @tx, @ty = zoom, tx.to_f, ty.to_f
  end

  def to_png
    center_lat, center_lon = pixels_to_latlon(
      @tx*RENDER_TILE_SIZE+RENDER_TILE_SIZE/2, 
      @ty*RENDER_TILE_SIZE+RENDER_TILE_SIZE/2)

    self.class.get(TILE_TO_PNG % ['png32', center_lat, center_lon, @zoom, 
      RENDER_TILE_SIZE, RENDER_TILE_SIZE])
  end

  private

  def pixels_to_latlon(px, py)
    meters_to_latlon *pixels_to_meters(px.to_f,py.to_f)
  end

  def meters_to_latlon(mx, my)
    # "Converts XY point from Spherical Mercator EPSG:900913 to lat/lon in WGS84 Datum"
    lon = (mx / ORIGIN_SHIFT) * 180.0
    lat = (my / ORIGIN_SHIFT) * 180.0

    lat = 180 / Math::PI * (2 * Math.atan(Math.exp(lat * Math::PI / 180.0)) - Math::PI / 2.0)
    [lat, lon]
  end

  def pixels_to_meters(px, py)
    # "Converts pixel coordinates in given zoom level of pyramid to EPSG:900913"
    res = resolution @zoom
    mx = px * res - ORIGIN_SHIFT
    my = py * res - ORIGIN_SHIFT
    [mx, my]
  end

  def resolution(zoom)
    # "Resolution (meters/pixel) for given zoom level (measured at Equator)"
    INITIAL_RESOLUTION / (2 ** zoom)
  end
end

class ViewHandlerController < ApplicationController

  CATCHALL_REQUESTURI_PARTS = /\A[\/]?(.*)[\/]?\Z/

  SITE_NAVIGATION = [ 'home', 'orientation-kalman', 'spatial-data-raw',
    'gps-location', 'analog-sensors', 'system' ]

  def catchall
    raise StandardError if /\.\./.match(request.fullpath)

    raise ActionController::UnknownAction if /\/_/.match request.fullpath

    @requested_action = $1 if CATCHALL_REQUESTURI_PARTS.match request.fullpath 

    @site_navigation = SITE_NAVIGATION

    begin
      action_as_path = Rails.root.join 'app','views','view_handler', @requested_action

      render :file => action_as_path
    rescue ActionView::MissingTemplate
      # This if statement will check to see if there's a directory by the name 
      # of the requested resource, and if so, we'll pull the index action out of 
      # there ...
      if File::directory? action_as_path
        @requested_action += "index" 
        retry
      end

      render :file => Rails.root.join('public','404.html'), :status => 404
    end
  end

  alias :index :catchall

  def google_static_image
    logger.error "Zoom: %s tx: %s ty: %s" % [params[:zoom], params[:tx], params[:ty]]

    tile = GMapStaticTile.new(*%w(zoom tx ty).collect{|attr| params[attr.to_sym].to_i})
    http_resp = tile.to_png

    if http_resp.code == 200
      dest_parts = ['public', 'images', 'gmap-tiles-512', params[:zoom]] 
      dest_folder = Rails.root.join(*dest_parts)
      dest_path = Rails.root.join(*dest_parts+[ '%s-%s.png' % [params[:tx], params[:ty]]])

      FileUtils.mkdir_p dest_folder unless File.directory? dest_folder
      File.open(dest_path, 'wb'){|file| file << http_resp.body} unless File.exists? dest_path
      send_file dest_path, :type => :png, :disposition => :inline
    else
      render :file => Rails.root.join('public','500.html'), :status => 500
    end
  end

end
