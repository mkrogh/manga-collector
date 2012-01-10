require "rubygems"
require "bundler/setup"
require "uri"
require "open-uri"

Bundler.require(:default)
require "manga/repositories"

# Based on https://gist.github.com/1217911
class ProgressBar
  def initialize(units=60)
    @units = units.to_f
  end

  def print(completed, total)
    norm     = 1.0 / (total / @units)
    progress = (completed * norm).ceil
    pending  = @units - progress
    Kernel.print "[#{'=' * progress }#{' ' * ( pending )}] #{percentage(completed, total)}%\r"
  end

  def percentage(completed, total)
    ( ( completed / total.to_f ) * 100 ).round
  end

  def finish
    print(1,1)
    puts ""
  end
end


class MangaCollector < Thor
  
  desc "save <manga_url>", "save a manga as a series of cbz chapters"
  method_option :chapter, :aliases => "-c", :type => :numeric, :lazy_default => 1
  def save(manga_url)
    manga = Manga::MangaReaderRepository.new(manga_url)

    if options[:chapter]
      manga.save_chapter(options[:chapter]-1)
    else
      puts "Downloading a complete manga is not supported at the moment"
    end
    
  end
end

if __FILE__ == $0
  MangaCollector.start
end
