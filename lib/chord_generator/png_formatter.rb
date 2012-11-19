require 'rvg/rvg' # rmagick's RVG (Ruby Vector Graphics) 

module ChordGenerator
  Magick::RVG::dpi = 72
  # Formats a single fingering as png data
  class PNGFormatter

    def initialize(frets, strings)
      @frets = frets
      @strings = strings
    end

    def print(options={})
      @label = options[:label]
      @hide_fret_numbers = options[:hide_fret_numbers]
      
      @max_fret = @frets.collect {|val| val[:fret] }.compact.max
      @min_fret = @frets.collect {|val| val[:fret] }.compact.delete_if { |f| f == 0 }.min
      @min_fret = 1 if @max_fret <= 4
      
      @min_bar_string = -1
      @max_bar_string = 0
      
      @frets.each_with_index do |fret, index|
        if fret[:barred_note] && fret[:barred_note] != "" && @min_bar_string < 0
          @min_bar_string = index
          @max_bar_string = index
        elsif fret[:barred_note]
          @max_bar_string = index
        end
      end
      
      @min_bar_string = 0 if @min_bar_string == -1
      @number_of_frets = [@max_fret - @min_fret + 1, 4].max

      get_png_data
    end

    private

    def get_png_data
      width = 160 + (@strings.size * 40)
      height = 340
      
      rvg = Magick::RVG.new(40 + (@strings.size * 40), 210).viewbox(0,0,width,height) do |canvas|
        canvas.background_fill = 'white'
        
        width_of_chord = 20 + (@strings.size * 40)
        margin_side_of_chord = (width - width_of_chord) / 2

        height_of_chord = 200
        margin_top_of_chord = ((height - height_of_chord) * 2 / 3.0).floor
        margin_bottom_of_chord = ((height - height_of_chord) / 3.0).ceil
        
        height_of_fret = height_of_chord / @number_of_frets
        radius_of_finger = (height_of_fret * 0.6) / 2
        
        width_of_fret = width_of_chord / (@strings.size - 1)

        # Draw all horizontal lines
        (@number_of_frets+1).times do |n|
          if n == 0 && @min_fret == 1
            canvas.line(margin_side_of_chord, n*height_of_fret+margin_top_of_chord, width - margin_side_of_chord, n*height_of_fret+margin_top_of_chord).styles(:stroke=>'black', :stroke_width => 5)
          else
            canvas.line(margin_side_of_chord, n*height_of_fret+margin_top_of_chord, width - margin_side_of_chord, n*height_of_fret+margin_top_of_chord)
          end
        end
        
        unless @hide_fret_numbers
          (@number_of_frets).times do |i|
            canvas.text(margin_side_of_chord - radius_of_finger - 4, i*height_of_fret+margin_top_of_chord + height_of_fret / 2 + 10) do |txt|
              txt.tspan(@min_fret + i).styles(
                :text_anchor => 'end',
                :font_size => 24,
                :font_family => 'helvetica',
                :fill => 'black')
            end
          end
        end
        
        bar_drawn = false
        
        @strings.each_with_index do |note, i|
          # Draw vertical lines
          canvas.line(i*width_of_fret+margin_side_of_chord, margin_top_of_chord, i*width_of_fret+margin_side_of_chord, height - margin_bottom_of_chord)

          if [0,nil].include?(@frets[i][:fret])
            # Add a letter at the top. Either X or O.
            canvas.text(i*width_of_fret+margin_side_of_chord, margin_top_of_chord - 6) do |txt| 
              txt.tspan((@frets[i][:fret] == 0 ? "O" : 'X').to_s).styles(
              :text_anchor => 'middle',
              :font_size => 24, 
              :font_family => 'helvetica',
              :fill => 'black')
            end            
          else
            #Add a bar
            if @frets[i][:barred_note] && !bar_drawn
              canvas.line(@min_bar_string*width_of_fret+margin_side_of_chord, (@frets[i][:fret] - @min_fret + 1)*height_of_fret - (height_of_fret / 2) + margin_top_of_chord, @max_bar_string*width_of_fret+margin_side_of_chord, (@frets[i][:fret] - @min_fret + 1)*height_of_fret - (height_of_fret / 2) + margin_top_of_chord).styles(:stroke=>'dark grey', :stroke_width => 10)
              bar_drawn = true
            end

            # Add a finger
            if @frets[i][:root]
              canvas.circle(radius_of_finger, i*width_of_fret+margin_side_of_chord,
                (@frets[i][:fret] - @min_fret + 1)*height_of_fret - (height_of_fret / 2) + margin_top_of_chord).styles(:fill => 'green')
            else
              canvas.circle(radius_of_finger, i*width_of_fret+margin_side_of_chord,
                (@frets[i][:fret] - @min_fret + 1)*height_of_fret - (height_of_fret / 2) + margin_top_of_chord)
            end

            # Add fingering to finger dot
            if @frets[i][:finger]
              canvas.text(i*width_of_fret+margin_side_of_chord + 1, (@frets[i][:fret] - @min_fret + 1)*height_of_fret - (height_of_fret / 2) + margin_top_of_chord + 8) do |txt| 
                txt.tspan(@frets[i][:finger].to_s).styles(:text_anchor => 'middle',
                :font_size => 24, 
                :font_family => 'helvetica',
                :fill => 'white')
              end
            end
          end
          
          canvas.text(i*width_of_fret+margin_side_of_chord, height - margin_bottom_of_chord + 20) do |txt| 
            txt.tspan(note).styles(:text_anchor => 'middle',
            :font_size => 18, 
            :font_family => 'helvetica',
            :fill => 'black')
          end

          if @frets[i][:interval]
            canvas.text(i*width_of_fret+margin_side_of_chord, height - margin_bottom_of_chord + 40) do |txt| 
              txt.tspan(@frets[i][:interval]).styles(:text_anchor => 'middle',
              :font_size => 18, 
              :font_family => 'helvetica',
              :fill => 'black')
            end
          end
        end
        
        if @label
          canvas.text(width / 2, margin_top_of_chord / 2) do |txt|
            txt.tspan(@label).styles(:text_anchor => 'middle',
              :font_size => 36,
              :font_family => 'helvetica',
              :fill => 'black',
              :font_weight => 'bold')
          end
        end

      end
      img = rvg.draw
      img = img.trim
      img.format = 'PNG'
      img.to_blob
    end
  end

end