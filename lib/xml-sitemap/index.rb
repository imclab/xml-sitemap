module XmlSitemap
  class Index
    attr_reader :maps
    
    def initialize(opts={})
      @maps   = []
      @offset = 0
      
      yield self if block_given?
    end
    
    # Add map object to index
    def add(map)
      raise ArgumentError, 'XmlSitemap::Map object requred!' unless map.kind_of?(XmlSitemap::Map)
      raise ArgumentError, 'Map is empty!' if map.empty?
      
      @maps << {
        :loc     => map.index_url(@offset),
        :lastmod => map.created_at.utc.iso8601
      }
      @offset += 1
    end
    
    # Generate sitemap XML index
    def render
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!(:xml, :version => '1.0', :encoding => 'UTF-8')
      xml.urlset(XmlSitemap::INDEX_SCHEMA_OPTIONS) { |s|
        @maps.each do |item|
          s.sitemap do |m|
            m.loc        item[:loc]
            m.lastmod    item[:lastmod]
          end
        end
      }.to_s
    end
    
    # Render XML sitemap index into the file
    def render_to(path, opts={})
      overwrite = opts[:overwrite] || true
      path = File.expand_path(path)
      
      if File.exists?(path) && !overwrite
        raise RuntimeError, "File already exists and not overwritable!"
      end
      
      File.open(path, 'w') { |f| f.write(self.render) }
    end
  end
end