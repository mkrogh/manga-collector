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
  method_option :last_chapter, :aliases => "-l", :type => :numeric, :lazy_default => 1
  method_option :verbose, :aliases => "-v", :type => :boolean, :default => false
  def save(manga_url)
    @manga = Manga::Repository.repository(manga_url)

    return if @manga.nil?
    
    @manga.verbose = options[:verbose]

    if options[:last_chapter] and options[:chapter]
      save_range(options[:chapter]..options[:last_chapter])
    elsif options[:chapter]
       @manga.save_chapter(options[:chapter])
    else
      puts "Downloading a complete manga is not supported at the moment, please use -c 1 -l 3 to download chapter 1-3"
    end
    
  end

  private
    def save_range(range)
      range.each do |chapter|
        @manga.save_chapter(chapter)
      end
    end
end

if __FILE__ == $0
  MangaCollector.start
end
