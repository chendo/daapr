class DAAPR
  class Song
    attr_reader :title, :artist, :album  
    def initialize(mlit)
      @title = mlit.minm
      @artist = mlit.asar
      @album = mlit.asal
    end
    
  end
end