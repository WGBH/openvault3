class Treasury

  attr_reader :data

  # YML style
  # def initialize(title)
  #   filepath = File.join(Rails.root, "app", "views", "treasuries", "data", "#{title}.yml")

  #   raise "Bad Treasury Name! No File!" unless File.exist?(filepath)
  #   # @file = 
  #   @data = YAML.load( File.read(filepath) )
  # end

  def initialize(title)
    filepath = File.join(Rails.root, "app", "views", "treasuries", "data", "#{title}.yml")

    raise "Bad Treasury Name! No File!" unless File.exist?(filepath)
    # @file = 
    @data = YAML.load( File.read(filepath) )

    docs = RSolr.connect(url: 'http://localhost:8983/solr/')
                    .get('select', params: {
                           'q' => "*:*",
                           # 'fl' => 'id,short_title,thumbnail_src,asset_description',
                           # 'sort' => 'short_title asc',
                           'rows' => '1000' # Solr default is 10.
                         })['response']['docs'].map { |doc| PBCore.new( doc['xml'] ) }

    # want season number, need something that will always be there!
    # season_data = docs.group_by {|pb| pb.year }

    # get a bucket of images to draw from
    @cooke_images = images

    # year for testing
    season_data = docs.reject {|g| g.year.nil? }.group_by {|pb| pb.year }

    # combine yml data with docs
    @data["seasons"] = @data["seasons"].map do |season|
      snumber = season["seasonNumber"]
      season_from_pbcores( snumber, season["description"], season_data[ snumber ] )
    end
  end

  def images
    [
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/2025552.jpg",
      # "https://s3.amazonaws.com/openvault.wgbh.org/carousel/alistair_cooke_banner.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/Mezzanine_584.jpg.focalcrop.1200x630.50.10.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/cooke-headshot.jpg",
      # "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/download.jpeg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/Alistair-Cookie.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/maxresdefault.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/p01vzv4w.jpg",
      
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/1280px-Bunratty_Castle_South_Solar_01.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/20180814-Parlor-023.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/3c304-blue-drawing-roombuckinghampalace.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/450c3aff51adacec1954c15fd524b6bb.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/DrawingRoom1-2.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/HOL_3016.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/OSMstuzB7-8hO7LQNWjauYkBPstvyuv1Y5PDXlPBTOM.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/The-Fife-Arms-Drawing-Room.-Ancient-Quartz-by-Zhang-Enli.-Photo-credit-Sim-Canetty-Clarke-e1553790189459-scaled.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/d3ddd-the-yellow-drawing-room-credit-tim-imrie.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/f20ab-invererycastledrawingroom.png",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/herter.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/victorian.jpg",

    ]
  end

  def season_from_pbcores(season_number, season_description, pbcores)
    {
      "seasonImage" => random_cooke_image,
      "description" => season_description,
      "seasonNumber" => season_number,
      "cardData" => pbcores.map {|pb| card_from_pbcore(pb) }
    }
  end

  def card_from_pbcore(pbcore)
    {
      "title" => pbcore.title,
      "description" => pbcore.program_description,
      "date" => pbcore.date,
      "programNumber" => pbcore.program_number,
      "guid" => pbcore.id,
      "recordLink" => "/catalog/#{pbcore.id}",
      "embedLink" => "/embed/card/#{pbcore.id}",
      "cardImage" => random_cooke_image,

      # HEY - DON DO TIHS THOUGH
      "clipCard" => pbcore.year == "1961"
      # "clipCard" => pbcore.is_clip?
    }
  end

  def random_cooke_image
    @cooke_images.shuffle!.pop || images.sample
  end

  def title
    @data["title"]
  end

  def poster_image
    @data["posterImage"]
  end

  def description
    @data["description"]
  end

  def seasons
    @data["seasons"]
  end
end