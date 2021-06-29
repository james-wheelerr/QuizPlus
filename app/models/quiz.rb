class Quiz < ApplicationRecord
    
    has_many :question
    has_many :answer
    
end
