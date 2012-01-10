Manga-collector
===============

Accessing online manga, and storing it too.

Why?
----

On a trip to Japan i 2010 I bought a somewhat random manga volume called Code: Breaker, and here in one of the first weekends of 2012 i decided that now was the time to check it out. 
Alas I only know how to say Good day, Sorry and Thanks in Japanese, thus trying to read the manga was futile.

I therefore started looking for scanlations of the manga, but it proved quite hard to locate older chapters.. 
I ended up on a site that hosts Manga scanlations, and all was peachy, until I got rather bored with reading on my trusty laptop. 

The idea of a manga collector or downloader sprang to my head one morning, and after a quiet afternoon of coding I had created a little program capable of downloading and saving individual chapters of different mangas as a cbz file. 
This means that I am now able to enjoy the manga on e.g. my kindle.

How?
----

Right now in this initial state the app only has one repository that handles downloads from http://www.mangareader.net, and it is not yet able to process the full catalog, only individual mangas. 

Usage is:

    Usage:
      ruby -I lib manga-collection.rb save <manga_url>
    Options:
      -c, [--chapter=N]

Road map
--------

A cli interface might be the next step, or perhaps a GUI written in Shoes. Another possibility is a Java client, using JRuby to leverage the current Ruby base.

License
-------
See LICENSE file

