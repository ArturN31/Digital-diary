class Entry < ApplicationRecord
    require 'csv'
    belongs_to :user

    #Gets the created_at value and formats it into: Month Day, Year
    def day
        self.updated_at.strftime("%b %e, %Y")
    end

    #Entries to csv file
    def self.to_csv
        entries = all
        CSV.generate do |csv|
            column_names = ['food_name', 'food_upc_code', 'created_at', 'food_calories', 'food_protein', 'food_carbohydrates', 'food_fats', 'food_fibre',]
            csv << column_names
            entries.each do |entry|
                csv << entry.attributes.values_at(*column_names)
            end
        end
    end
end