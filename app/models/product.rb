class Product < ActiveRecord::Base
	################################## ASSOCIATIONS ##################################
	has_many :reports_recieved, as: :reportable

	# Returns the title use for reports
	def report_title
		self.title
	end
end