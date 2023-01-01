class Entry < ApplicationRecord
    belongs_to :user

    #Gets the created_at value and formats it into: Month Day, Year
    def day
        self.created_at.strftime("%b %e, %Y")
    end
end
