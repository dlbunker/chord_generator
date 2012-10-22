chord_generator_
===

A Ruby library to generate images of guitar, ukulele, mandolin or banjo chords

Installation
---

    gem install chord_generator

or if you are using Bundler, add this line to your Gemfile:

    gem 'chord_generator'
    
Usage
---

    File.open("/tmp/A_major.png", 'w') do |f|
       chord = ChordGenerator::Chord.new("x-0-2-2-2-0")
       f.write chord.to_png(:label => "A")
    end

	This will write a basic open string A chord with no frills to <tt>/tmp/A_major_.png</tt>:

	![A - Major](https://github.com/dlbunker/chord_generator/raw/master/examples/A.png)

Advanced Usage
---

	You can also add fingerings, tone intervals, root notes and bars with the following options

	The chord code passed into the generator, at a minimum, specifies the string and fret.  So "x-0-2-2-2-0" means, muted 6th string, open 5th string, 2nd fret 4th string, etc.

	If you want to add fingerings to each fretted note you need to enhance the chord code by adding a pipe to each played string followed by the finger number (open strings can be left blank)
    
	File.open("/tmp/A_major.png", 'w') do |f|
	   chord = ChordGenerator::Chord.new("x-0|-2|1-2|2-2|3-0|")
	   f.write chord.to_png(:label => "A with fingering")
	end

	![A - with fingering](https://github.com/dlbunker/chord_generator/raw/master/examples/A_with_fingering.png)


	If you want to add interval tones to each fretted note you need to enhance the chord code by adding a pipe to each played string followed by the finger number (open strings can be left blank) followed by the interval
    
	File.open("/tmp/A_major.png", 'w') do |f|
	   chord = ChordGenerator::Chord.new("x-0||1-2|1|5-2|2|1-2|3|3-0||5")
	   f.write chord.to_png(:label => "A with intervals")
	end

	![A - with intervals](https://github.com/dlbunker/chord_generator/raw/master/examples/A_with_intervals.png)

	If you want to add bars and root notes to your diagrams simply enhance the code with more pipes.  For each fret/string position in the code you have the following options (fret number|fingering|interval|B|R) where B and R stand for Bar and Root note.  For Barred notes to work correctly there must be a matching bar notation on the same fret but different string.
    
	File.open("/tmp/A_major_bar.png", 'w') do |f|
	   chord = ChordGenerator::Chord.new("5|1|1|B|R-7|3|5-7|4|1-6|2|3-5|1|5-5|1|1|B")
	   f.write chord.to_png(:label => "A bar with root")
	end

	![A - bar with root](https://github.com/dlbunker/chord_generator/raw/master/examples/A_bar_with_root.png)
	
	To specify a different instrument or tuning, pass in a supported tuning from the Dictionary.

    chord = ChordGenerator::Chord.new("0||1-0||5-2|2|3-3|3|1")
    chord.to_png({:label => "G Mandolin", :tuning => ChordGenerator::Dictionary::MANDOLIN_TUNINGS[:standard]})

	![G - mandolin](https://github.com/dlbunker/chord_generator/raw/master/examples/G.png)

Thanks
---

Lot's of code based on [andmej/jamming](https://github.com/andmej/jamming), thanks!

 
Copyright
---

Copyright (c) 2012 Dan Bunker ((http://totalguitarandbass.com)). See LICENSE.txt for
further details.

Other important notes
---

