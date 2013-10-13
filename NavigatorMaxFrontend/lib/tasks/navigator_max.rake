require Rails.root.join(*%w(lib gmap_static_tile))

namespace :navigator_max do
  desc "Download a range of tiles given the ZOOM, and UPPER_LEFT and BOTTOM_RIGHT gps coords"
  task :cache_gmap_tiles => :environment do
    include Rails.application.routes.url_helpers

    REQUIRED_PARAMS = %w(ZOOM UPPER_LEFT BOTTOM_RIGHT)

    raise StandardError, "Missing one or more required params: %s" % [
      REQUIRED_PARAMS.join(',') ] unless REQUIRED_PARAMS.all?{|rp| ENV.include?(rp)}

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

    # Start downloading!
    i = 0
    tx_from.upto(tx_to).each do |tx|
      ty_from.upto(ty_to).each do |ty|
        i+=1
        local_path = [Rails.root, 'public', 
          gmap_image_path(:zoom => zoom, :tx => tx, :ty => ty) ].join('/')

        unless File.exists? local_path
          retry_attempts = 0
          tile = GMapStaticTile.new zoom, tx, ty
          begin
            puts "* Downloading %sx%s (%s/%s)" % [tx, ty, i, across_tiles*up_tiles]
            tile.to_png! local_path 
          rescue GMapStaticTile::RequestFail
            if retry_attempts < 5
              puts "  - Error: Retrying"
              retry_attempts += 1
              retry
            else 
              puts "  - Error: Skipping tile: %s" % tile.png_url.inspect
              next
            end
          end
        end
      end
    end
  end
end
