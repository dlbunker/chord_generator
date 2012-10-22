require 'chord_generator/png_formatter'
require 'chord_generator/dictionary'

module ChordGenerator
  class Chord
    attr_reader :frets
    
    def initialize(chord_as_string, tuning = nil)
      @frets = parse(chord_as_string)
    end
  
    def to_png(options = {})
      label = options[:label] == false ? nil : options[:label] || name
      tuning = (options[:tuning].nil?) ? ChordGenerator::Dictionary::GUITAR_TUNINGS[:standard] : options[:tuning]

      ChordGenerator::PNGFormatter.new(frets, tuning).print(options.merge(:label => label))
    end
    
    def name
      ChordGenerator::Dictionary.name_for(frets)
    end
  
    protected
  
    def parse(chord)
      frets = chord.split(chord =~ /-/ ? "-" : "")
      #group the fingering number with the fret dot
      frets.collect! {|val| val.split("|")}

      fret_array = []

      # turn the info strings into integers
      frets.each do |fret|
        #first number is fret
        f = fret[0] =~ /[0-9]+/ ? fret[0].to_i : nil
        #second number is finger
        fing = nil
        fing = fret[1] if fret[1]
        #third is if the chord tone interval
        interval = nil
        interval = fret[2] if fret[2]
        
        bar = false
        bar = true if fret[3]
        
        root = false
        root = true if fret[4]

        fret_array << {:fret => f, :finger => fing, :interval => interval, :root => root, :barred_note => bar}
      end
      
      return fret_array
    end
  end
end