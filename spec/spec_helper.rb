# encoding: utf-8

require 'rubygems'
require 'rspec'
require 'require_all'

# require_rel '../lib'   # use the require_all gem to require everything in ../lib

# Dir["#{Dir.pwd}/lib/**/*.rb"].each { |f| 
#   p f
#   require f
# }
require 'chingu'

RSpec.configure  do | config |

  config.expect_with(:rspec) { |c| c.syntax = [:should, :expect]}

  config.mock_with :rspec do |mocks|
    mocks.syntax = [:should, :expect]
    mocks.verify_doubled_constant_names = true
  end

end

def media_path(file)
  File.join($window.root, "..", "..", "examples", "media", file)
end

if defined?(Rcov)
  # all_app_files = Dir.glob('lib/**/*.rb')
  # all_app_files.each{|rb| require rb}
end

