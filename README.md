# mp4titler
A perl script that will set a media file's Title tag to match its base file name.

I had a very large collection of video files created with various cameras, devices, and
from various digital media sources. I used to access these primarily with a file server,
either nfs for *nix machines, or SMB for Windows. I have a lot of DLNA compatible 
devices throughout my home, so I finally set up an minidlna server.

What I came to find was that, for example, several years of home videos that I
shot with a Sony mini-DVD-R camcorder all appeared as "DVD DCR108". This didn't 
make browsing them easy.

I've been a *nix systems programmer for about 800 years, and that means that
even though I was born and raised on C/C++, and I've had to do a lot of Java, PHP,
and so forth, I turn to perl and CPAN first because

A) I'm old, and
2) CPAN has everything.

Sure enough, the CPAN library Image::ExifTool could let me set the title of various video
files to whatever I wanted. What I wanted was the file name, because they were things like
"North Shore Trip 2004.mp4"

So I whipped up this little script that recursively iterates over one or more
directories specified on the command line, looking for files ending with this
regular expression (from the code):

my $pattern = "mpeg|mp4|m4v";

It turns out ExifTool can't modify a true MPEG file (I'm not a media file format expert
so do not ask me why), so this list is probably not right. It so happens that all
but a few of my files were some variant of mp4, and I could transcode the couple of
MPEG files I had to mp4, so this did the job for me.

I really know next to NOTHING about media files. It looks like Image::ExifTool could do this
to PNGs and Jpegs and all sorts of files. I don't know about that. I just know it worked
for my use case, and here it is if it will be of use to you.


