# frozen_string_literal: true

# Add common methods to Rockette module
module TextHelper
  def bail
    puts "Bailing, a socket (network) or IO error occurred. Can you access the url from here?"
    puts "Double check the url and make sure you have a network connection to the target."
    exit
  end

  def check_input(input)
    input unless input.nil?
  end

  def padder(str)
    "\n#{str}\n"
  end
end
