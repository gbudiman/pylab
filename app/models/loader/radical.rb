module Radical
  def self.load_file _path: Rails.root.join('db', 'seeds', 'radical.rb')
    puts 'radical loaded'
    IO.foreach _path do |line|
      puts line
    end
  end
end