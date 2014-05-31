module DataHelper
  
  def at_least_one_slot_filled?(inputs)
    found_filled_slot = false
    inputs.each do |input|
      slot_is_good = true
      input.each do |list|
        slot_is_good = false if list.nil? or list.empty? or list.size == 0
      end
      found_filled_slot = true if slot_is_good == true
    end
    found_filled_slot
  end
  
  
  def prof_outputs_color_map(n)
    cmap = {
      1 => "#eeffee",
      2 => "#ddffdd",
      3 => "#ccffcc",
      4 => "#bbffbb",
      5 => "#aaffaa",
      6 => "#99ff99",
      7 => "#88ff88",
      8 => "#77ff77",
      9 => "#66ff66",
      10 => "#55ff55"
    }
    color = cmap[n]
    color = "#ffffff" if n == 0
    color = "#00ff00" if n > 10
    return color
  end
    
end