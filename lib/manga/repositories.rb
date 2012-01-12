require "bundler/setup"
require "open-uri"
require "fileutils"
Bundler.require(:default)

def require_relative(relative_feature)
  c = caller.first
  fail "Can't parse #{c}" unless c.rindex(/:\d+(:in `.*')?$/)
  file = $`
  if /\A\((.*)\)/ =~ file # eval, etc.
    raise LoadError, "require_relative is called in #{$1}"
  end
  absolute = File.expand_path(relative_feature, File.dirname(file))
  require absolute
end unless Kernel.respond_to?(:require_relative)


require_relative "models"

module Manga
  class Repository    
    attr_accessor :verbose, :archive_dir
   
    @@repositories = {} 
    @archive_dir = "archive"
   
    def self.register(site,klazz)
      @@repositories[site] = klazz
    end

    def self.repository(manga_url)
      host = URI(manga_url).host

      if @@repositories.key? host
        # flyweight singleton? (add singletonian instantiating..)
        @@repositories[host].new(manga_url)
      else
        puts "No repository registered for #{manga_url}"
      end
    end
  end

  class MangaReaderRepository < Repository

    def initialize(manga_url)
      @manga_url = URI(manga_url)
    end

    def list_chapters
      unless @chapter_list
        @chapter_list = []
        puts "Retrieving chapter list" if @verbose
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
        puts "Retrieving page list for #{chapter}" if @verbose
        pages_url = Nokogiri::HTML.parse(open(chapter.url)).css("#selectpage option").collect { |page| manga_base_url + page["value"] }

        puts "Identifying individual page images (#{pages_url.length} pages)" if @verbose
        pages_url.each do |page|
          img = Nokogiri::HTML.parse(open(page)).css("#imgholder img").first
          chapter.pages << Page.new(img["src"])
        end
      end
      chapter
    end


    def save_chapter(nbr=1)
      chapter = fetch_chapter(nbr-1)
      
      FileUtils.mkdir_p(@archive) if @archive

      puts "Downloading: #{chapter.title} (#{chapter.pages.length} pages)"   
      bar = ProgressBar.new
    
      path = chapter.title.gsub(" : ","-").gsub(" ","_") + ".cbz"
      path = File.join(@archive, path) if @archive
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
  
  #Register
  Repository.register("www.mangareader.net",MangaReaderRepository)
end
