class GMapStaticTile
  include HTTParty

  GOOGLE_TILE_SIZE = 256
  INITIAL_RESOLUTION = 2 * Math::PI * 6378137 / GOOGLE_TILE_SIZE
  ORIGIN_SHIFT = 2 * Math::PI * 6378137 / 2.0
  RENDER_TILE_SIZE = 512

  TILE_TO_PNG = '/maps/api/staticmap?format=%s&center=%s,%s&zoom=%s&size=%sx%s&maptype=satellite&sensor=false'

  class RequestFail < StandardError; end

  base_uri 'maps.googleapis.com'

  def initialize(zoom, tx, ty)
    @zoom, @tx, @ty = zoom, tx.to_f, ty.to_f
  end

  def to_png!(dest_path)
    http_resp = self.class.get png_url

    raise RequestFail unless http_resp.code == 200

    dest_folder = File.dirname(dest_path)
    FileUtils.mkdir_p dest_folder unless File.directory? dest_folder
    File.open(dest_path, 'wb'){|file| file << http_resp.body} unless File.exists? dest_path

    true
  end

  def png_url
    center_lat, center_lon = pixels_to_latlon(
      @tx*RENDER_TILE_SIZE+RENDER_TILE_SIZE/2, 
      @ty*RENDER_TILE_SIZE+RENDER_TILE_SIZE/2)

    TILE_TO_PNG % ['png32', center_lat, center_lon, @zoom, RENDER_TILE_SIZE, 
      RENDER_TILE_SIZE]
  end

  def self.latlon_to_tile(zoom, lat, lon)
    pixels_x, pixels_y = latlon_to_pixels zoom, lat,lon
   
    [ (pixels_x.to_f/RENDER_TILE_SIZE).floor,  (pixels_y.to_f/RENDER_TILE_SIZE).floor ]
  end

  def self.latlon_to_pixels(zoom, lat, lon)
    meters_to_pixels zoom, *latlon_to_meters(lat,lon)
  end

  def self.latlon_to_meters(lat, lon)
    # "Converts given lat/lon in WGS84 Datum to XY in Spherical Mercator EPSG:900913"
    mx = lon.to_f * ORIGIN_SHIFT / 180.0
    my = Math.log( Math.tan((90 + lat.to_f) * Math::PI / 360.0 )) / (Math::PI / 180.0)

    my = my.to_f * ORIGIN_SHIFT / 180.0
    [mx, my]
  end

  def  self.meters_to_pixels(zoom, mx, my)
    #"Converts EPSG:900913 to pyramid pixel coordinates in given zoom level"
    res = resolution zoom
    px = (mx.to_f + ORIGIN_SHIFT) / res
    py = (my.to_f + ORIGIN_SHIFT) / res
    [ px, py ]
  end

  def self.resolution(zoom)
    # "Resolution (meters/pixel) for given zoom level (measured at Equator)"
    INITIAL_RESOLUTION / (2 ** zoom)
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
    res = self.class.resolution @zoom
    mx = px * res - ORIGIN_SHIFT
    my = py * res - ORIGIN_SHIFT
    [mx, my]
  end

end
