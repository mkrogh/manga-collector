require "bundler/setup"
require "open-uri"
Bundler.require(:default)
require_relative "models"

module Manga
  class Repository
    
  end

  class MangaReaderRepository < Repository

    def initialize(manga_url)
      @manga_url = URI(manga_url)
    end

    def list_chapters
      unless @chapter_list
        @chapter_list = []
        chapters = Nokogiri::HTML.parse(open(@manga_url)).css("#chapterlist a")

        chapters.each do |chapter|
          title = chapter.parent.text.strip
          @chapter_list << Chapter.new(title, manga_base_url+chapter["href"]) 
        end
      end

      @chapter_list
    end

    def fetch_chapter(nbr=0)
      chapter = list_chapters[nbr]
      unless chapter.pages.length > 0
        pages_url = Nokogiri::HTML.parse(open(chapter.url)).css("#selectpage option").collect { |page| manga_base_url + page["value"] }

        pages_url.each do |page|
          img = Nokogiri::HTML.parse(open(page)).css("#imgholder img").first
          chapter.pages << Page.new(img["src"])
        end
      end
      chapter
    end


    def save_chapter(nbr=1)
      chapter = fetch_chapter(nbr-1)
      
      puts "Downloading: #{chapter.title} (#{chapter.pages.length} pages)"   
      bar = ProgressBar.new
    
      path = chapter.title.gsub(" : ","-").gsub(" ","_") + ".cbz"
        
      chapter.pages.each_with_index do |page, nbr|
        bar.print(nbr,chapter.pages.length)
        page_file = "page_%03d" % nbr
        page.save(path, page_file)
      end

      bar.finish       
    end


    private
      def manga_base_url
        "#{@manga_url.scheme}://#{@manga_url.host}"
      end
  end
end
