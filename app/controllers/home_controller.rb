class HomeController < ApplicationController

  def index
		case `hostname`.chomp.split('.')[2..4]
			when ["agr", "gc", "ca"] then render "index-aafc"
			else case `hostname`.chomp
				when ["ASUS-CM6870"] then render "index-aafc"
				else render "index-public"
			end
		end
  end

  def contents
		case `hostname`.chomp.split('.')[2..4]
			when ["agr", "gc", "ca"] then render "contents-aafc"
			else 
				case `hostname`.chomp
					when "ASUS-CM6870" then render "contents-aafc"
					else render "contents-public"
				end
		end
  end

end
