class Event < ApplicationRecord
    validates :billetto_id, presence: true, uniqueness: true
    validates :title, presence: true
    validates :starts_at, :ends_at, presence: true
end
