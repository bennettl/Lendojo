class Filter < ActiveRecord::Base
	# Seralized Hash
	serialize :data, Hash

	validates :title, presence: true
end
