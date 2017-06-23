# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

	# convert date (Time) into a human-readable text string
	def lsrsVersionTimestamp()
		`find "#{Rails.root.to_s}/app" -printf '%T+ %p\n' | sort -r | head -1`[0..9].delete('-')
	end

end
