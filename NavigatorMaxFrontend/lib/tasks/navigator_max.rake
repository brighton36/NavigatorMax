require Rails.root.join(*%w(lib gmap_static_tile))

namespace :navigator_max do
  desc "Download a range of tiles given the ZOOM, and UPPER_LEFT and BOTTOM_RIGHT gps coords"
  task :cache_gmap_tiles => :environment do
    # TODO : Dump an error if our params suck 
    zoom = ENV['ZOOM'].to_i
    ul_lat, ul_lon, br_lat, br_lon = [ ENV['UPPER_LEFT'], 
      ENV['BOTTOM_RIGHT']].collect{|l| l.split(',')}.flatten.collect(&:to_f)

    puts 'UL(Lat: %s Lon: %s) BR(Lat: %s Lon: %s)' % [ul_lat, ul_lon, br_lat, br_lon]

    ul_tile_x, ul_tile_y = GMapStaticTile.latlon_to_tile zoom, ul_lat, ul_lon
    br_tile_x, br_tile_y = GMapStaticTile.latlon_to_tile zoom, br_lat, br_lon
    
    puts 'UL(Tx: %s Ty: %s) BR(Tx: %s Ty: %s)' % [ul_tile_x, ul_tile_y, br_tile_x, br_tile_y]

    tx_from, tx_to = (ul_tile_x > br_tile_x) ? [br_tile_x, ul_tile_x] : [ul_tile_x, br_tile_x]
    ty_from, ty_to = (ul_tile_y > br_tile_y) ? [br_tile_y, ul_tile_y] : [ul_tile_y, br_tile_y]

    across_tiles = tx_to - tx_from
    up_tiles = ty_to-ty_from
    puts "Tiles Across: %s Tiles Up: %s Total Tiles: %s " % [across_tiles, up_tiles, across_tiles*up_tiles]

    # TODO: Start downloading!
  end
end
