require "bundler/setup"
require "open-uri"
Bundler.require(:default)

module Manga
  class Manga
    attr_reader :latest_chapter
    attr_accessor :chapters

    def initialize()
      @chapters = []
    end
    
  end

  class Chapter
    attr_accessor :pages, :nbr, :url, :title
    
    def initialize(title, url)
      @title = title
      @url = url
      @pages = []
    end

    def to_s
      "#{@title}"
    end
  end


  class Page
    attr_accessor :img_url

    def initialize(img_url)
      @img_url = img_url
      @saved = false
    end

    def to_s
      "img_url: #{@img_url}"
    end

    def save(archive,file)
      file = file + File.extname(@img_url)
      
      Zip::ZipFile.open(archive, Zip::ZipFile::CREATE) do |zipfile|
        img = open(@img_url) 
        zipfile.add(file, img)
      end
      
      @saved = true
    end

    def saved?
       @saved
    end
  end
end