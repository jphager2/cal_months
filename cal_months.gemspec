current_dir = File.expand_path('..', __FILE__)
extensions = %w{ rb yml haml erb slim html js json jbuilder }
files = Dir.glob(current_dir + "/**/*.{#{extensions}}")
files.collect! {|file| file.sub(current_dir + '/', '')}
files.push('LICENSE')

Gem::Specification.new do |s|
  s.name        = 'cal_months'
  s.version     = '0.0.1'
	s.date        = "#{Time.now.strftime("%Y-%m-%d")}"
	s.homepage    = ''
  s.summary     = 'icalendar integration'
  s.description = 'A nice extension for quickly incorporating icalendar imports with default views'
  s.authors     = ['jphager2']
  s.email       = 'jphager2@gmail.com'
  s.files       = files 
  s.license     = 'MIT'

  s.add_runtime_dependency 'icalendar', '~> 2.2.2'
end
