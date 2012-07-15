# JotBot time-tracking software #



## Overview ##

JotBot is a cross-platform desktop application written in JRuby.  It was a commercial product released somewhere around 2009. 

It is notable for being one of the first commercial JRuby apps as well as for being a reasonably robust example of [Monkeybars](http://Monkeybars.org).

JotBot never sold very well, and the JotBot Web store was shutdown around 2011.

The source code is being released to provide some examples of Monkeybars usage. Also, it's a useful app.


## Stuff ##

First and foremost JotBot (and Monkeybars) was primary the work of [David Koontz](http://dkoontz.wordpress.com/) and [Logan Barnett](http://blog.logustus.com/).

I ([James Britt](http://jamesbritt.com)) contributed to both Monkeybars and JotBot (and am now the Monkeybars project admin) but the bulk of credit belongs to David and Logan.

Monkeybars arose out of a private commercial project first started by David and then continued by Happy Camper Studios (that being David, Logan, and myself).

Happy Camper disbanded around 2009 and I was granted ownership of JotBot.  I, through my company [Neurogami](http://neurogami.com), sold JotBot using Shopify and a Ramaze + JRuby + Glassfish Web app that handled license key generation and delivery when a sale was made.

JotBot sold like shit, and it cost more money to maintain the sales infrastructure than it even generated, but I learned a lot.  Still cheaper than business school.

We used JotBot at Happy Camper (we wrote it to scratch our own itch), and I continued to use since then.

The code has been sitting in private git repo all this time, and I kept thinking I'd think of some way to revamp it and remarket it.  

But, I haven't, and likely never will.   Lately I've been working more with assorted hardware, and have started a publishing site ([Just the Best Parts](http://justthebestparts.com) for E-books explain technology for artists.

So I'm making the source available for personal, non-commercial use.


## Issues ##

I've been using a version compiled around 2010.  Since then there have been changes to JRuby, Java, Monkeybars, and [Rawr](https://github.com/rawr/rawr).

Somewhere along the line stuff got misaligned and compiling JotBot got gnarly.

In preparation for releasing the code I removed a number of tangential files (e.g. all the code for the Web site and assorted experimental rigs) and tried to par down the source to what is essentially for just building a running copy of JotBot.

It builds but fails (for me at least) when run.  I suspect there's some subtle problem due to changes in JRuby and or Java. Might be an issue in Monkeybars.

I didn't want to stall the release just because of a small problem, such as the application failing to run.

I'm assuming that I or someone else will figure out what the problem is and the code will get updated.

Even if that never happens the code offers some interesting Monkeybars and JRuby+Swing examples.


Make the most of it, for what it's worth.


## How to build ##

You need to install the Rawr gem.

You should the be able to build the app using

    rake rawr:jar

There are tasks for generating installers for OSX and Windows.  They're old and may not work.

At the very least you should be able to run JotBot from the resulting jar file:

    java -jar /path/to/JotBot.jar

You may get prompted to enter a licence key.

Paste in this text:


`Xvlcy7/2HGPlcL6BVQp1LfyYpxnKCgYzatVOAv7C6vqJjAgrnhC5K9UNm46V
FeAFU5wK8X6k1HSJL+hZCbQei/8WmIL45yfp1zIijsZRR1/J2srdpZ9/eaTx
oIUb3LEkPchjL6zplaJDZCyWpuhzhlxA5AMtvT+Ksd7k0TyKgdEg6yFaJzSV
oc5tQInfh9jsHNjOdnF0/Y0dmyeMxkV2Y/8NJ2ERhSn7r0m3MOQ0vjjhdWSn
Lptw8Ou2pJCQqvRErww0upYyOMtUx067TaU1La2iYBSDgT1zsyvjkhXXLXDb
hIwFXIkcPLMltt/3U0FkZHpE5yrTxQjdP1C0Jxtcdw==`


That might work.  Or change the code to stop asking for a key.



## License ##

JotBot is released under the [GPL v3](http://www.gnu.org/copyleft/gpl.html)


    JotBot time-tracking software
    Copyright (C) 2012  James Britt / Neurogami

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
     
    
     

--------------

James Britt

July 15, 2012


Feed your head.

