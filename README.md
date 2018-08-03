# Manga-collector

Accessing online manga, and storing it too.

## Why?

On a trip to Japan i 2010 I bought a somewhat random manga volume called Code: Breaker, and here in one of the first weekends of 2012 i decided that now was the time to check it out. 
Alas I only know how to say Good day, Sorry and Thanks in Japanese, thus trying to read the manga was futile.

I therefore started looking for scanlations of the manga, but it proved quite hard to locate older chapters.. 
I ended up on a site that hosts Manga scanlations, and all was peachy, until I got rather bored with reading on my trusty laptop. 

The idea of a manga collector or downloader sprang to my head one morning, and after a quiet afternoon of coding I had created a little program capable of downloading and saving individual chapters of different mangas as a cbz file. 
This means that I am now able to enjoy the manga on e.g. my kindle.

## How?

Right now it only handles downloads from http://www.mangareader.net. 

Usage is:

    Usage:
      ./manga-reader.sh <manga_url>
    Options:
      -c <start_chapter>, defaults to 1
      -l <last_chapter>, defaults to start_chapter
      -n, dry run, don't actually write anything to disk

Example:

    ./manga-reader.sh http://www.mangareader.net/bleach -c 1 -l 3

## Changelog

###  2018-08-03

  - Replaced ruby implementation with a bash script using `curl`, `awk`, `sed` and `zip`.
  - Ruby version has been pushed to a branch named [ruby](https://github.com/mkrogh/manga-collector/tree/ruby)
 
###  2018-08-02
  
  - Update gemfile.lock
  - Port to ruby 2.5

### 2012-01-10
  
  - First "release"

## License

See LICENSE file

