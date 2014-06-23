class Filter < ActiveRecord::Base
	# Seralized Hash
	serialize :data, Hash

	validates :title, presence: true

	# Is the filter empty?
	def empty?
		self.data.empty?
	end
	
end
