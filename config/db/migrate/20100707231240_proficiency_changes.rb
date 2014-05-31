class ProficiencyChanges < ActiveRecord::Migration
  def self.up
    Proficiency.move("Cultural Studies","Cultural Practice")
    Proficiency.destroy_by_name("Cultural Studies")
    Proficiency.rename("Cultural Practice", "Cultural Practice and Studies")
    
    Proficiency.move("Movement / Kinesthetic Awareness","Embodied Interaction")
    Proficiency.destroy_by_name("Movement / Kinesthetic Awareness")
    Proficiency.rename("Embodied Interaction", "Embodiment and Kinesthetics")
    
    Proficiency.move("Producing and Staging","Project Development")
    Proficiency.destroy_by_name("Producing and Staging")
    Proficiency.rename("Project Development","Project Design and Production")
    
    Proficiency.move("Essay Writing","Narrative Composition")
    Proficiency.destroy_by_name("Essay Writing")
    Proficiency.rename("Narrative Composition","Narrative Construction")
    
    Proficiency.move("Research Writing", "Research Methodology")
    Proficiency.destroy_by_name("Research Writing")
    Proficiency.rename("Research Methodology", "Research Methodology and Writing")
    
    Proficiency.move("Publishing and Sharing","Digital Storage and Retrieval")
    Proficiency.destroy_by_name("Publishing and Sharing")
    Proficiency.rename("Digital Storage and Retrieval","Digital Archiving and Publishing")
    
    Proficiency.rename("Content Analysis", "Computational Media Analysis")
    
    Proficiency.move("Experimental Design","System Design/Development")
    Proficiency.destroy_by_name("Experimental Design")
    
    Proficiency.rename("Fabrication and System Building", "Fabrication and Building")
    
    Proficiency.rename("Performance", "Performance and Interaction")
  end

  def self.down
  end
end
