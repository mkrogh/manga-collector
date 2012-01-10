require "rubygems"
require "bundler/setup"
require "uri"
require "open-uri"

Bundler.require(:default)
require "manga/models"

class MangaRepository
  
end

class MangaReaderRepository < MangaRepository

  def initialize(manga_url)
    @manga_url = URI(manga_url)
  end

  def list_chapters
    unless @chapter_list
      @chapter_list = []
      chapters = Nokogiri::HTML.parse(open(@manga_url)).css("#chapterlist a")

      chapters.each do |chapter|
        title = chapter.parent.text.strip
        @chapter_list << Manga::Chapter.new(title, manga_base_url+chapter["href"]) 
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
        chapter.pages << Manga::Page.new(img["src"])
      end
    end
    chapter
  end


  def save_chapter(nbr=0)
    chapter = fetch_chapter(nbr)

    path = chapter.title.gsub(" : ","-").gsub(" ","_") + ".cbz"
      
    chapter.pages.each_with_index do |page, nbr|
      page_file = "page_%03d" % nbr
      page.save(path, page_file)
    end
       
  end


  private
    def manga_base_url
      "#{@manga_url.scheme}://#{@manga_url.host}"
    end
end


if __FILE__ == $0
  #manga = MangaReaderRepository.new("http://www.mangareader.net/322/code-breaker.html")
  manga = MangaReaderRepository.new("http://www.mangareader.net/93/naruto.html")

  #manga.save_chapter(119)
  #manga.save_chapter(50)
  #manga.save_chapter(51)
  #manga.save_chapter(52)
  #manga.save_chapter(53)
  manga.save_chapter(154)
  #puts manga.list_chapters
end
