require 'rubygems'
require 'rake/gempackagetask'
require 'rake/rdoctask'

SO_NAME = "ruby_debug.so"

# ------- Default Package ----------
RUBY_DEBUG_VERSION = open("ext/ruby_debug.c"){|f| f.grep(/^#define DEBUG_VERSION/).first[/"(.+)"/,1]}

FILES = FileList[
  'Rakefile',
  'README',
  'LICENSE',
  'CHANGES',
  'lib/**/*',
  'ext/*',
  'doc/*',
  'bin/*'
]

# Default GEM Specification
default_spec = Gem::Specification.new do |spec|
  spec.name = "ruby-debug"
  
  spec.homepage = "http://rubyforge.org/projects/ruby-debug/"
  spec.summary = "Fast Ruby debugger"
  spec.description = <<-EOF
ruby-debug is a fast implementation of the standard Ruby debugger debug.rb.
It's implemented by utilizing a new hook Ruby C API.
EOF

  spec.version = RUBY_DEBUG_VERSION

  spec.author = "Kent Sibilev"
  spec.email = "ksibilev@yahoo.com"
  spec.platform = Gem::Platform::RUBY
  spec.require_path = "lib" 
  spec.bindir = "bin"
  spec.executables = ["rdebug"]
  spec.extensions = ["ext/extconf.rb"]
  spec.autorequire = "ruby-debug"
  spec.files = FILES.to_a  

  spec.required_ruby_version = '>= 1.8.2'
  spec.date = DateTime.now
  spec.rubyforge_project = 'ruby-debug'
  
  # rdoc
  spec.has_rdoc = true
end

# Rake task to build the default package
Rake::GemPackageTask.new(default_spec) do |pkg|
  pkg.need_tar = true
  pkg.need_tar = true
end

task :default => [:package]

# Windows specification
win_spec = default_spec.clone
win_spec.extensions = []
win_spec.platform = Gem::Platform::WIN32
win_spec.files += ["lib/#{SO_NAME}"]

desc "Create Windows Gem"
task :win32_gem do
  # Copy the win32 extension the top level directory
  current_dir = File.expand_path(File.dirname(__FILE__))
  source = File.join(current_dir, "ext", "win32", SO_NAME)
  target = File.join(current_dir, "lib", SO_NAME)
  cp(source, target)

  # Create the gem, then move it to pkg
	Gem::Builder.new(win_spec).build
	gem_file = "#{win_spec.name}-#{win_spec.version}-#{win_spec.platform}.gem"
  mv(gem_file, "pkg/#{gem_file}")

  # Remove win extension fro top level directory	
	rm(target)
end


desc "Publish ruby-debug to RubyForge."
task :publish do 
  require 'rake/contrib/sshpublisher'
  
  # Get ruby-debug path
  ruby_debug_path = File.expand_path(File.dirname(__FILE__))

  publisher = Rake::SshDirPublisher.new("kent@rubyforge.org",
        "/var/www/gforge-projects/ruby-debug", ruby_debug_path)
end

desc "Clear temp files"
task :clean do
  cd "ext" do
    if File.exists?("Makefile")
      sh "make clean"
      rm "Makefile"
    end
  end
end

# ---------  RDoc Documentation ------
desc "Generate rdoc documentation"
Rake::RDocTask.new("rdoc") do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = "ruby-debug"
  # Show source inline with line numbers
  rdoc.options << "--inline-source" << "--line-numbers"
  # Make the readme file the start page for the generated html
  rdoc.options << '--main' << 'README'
  rdoc.rdoc_files.include('bin/**/*',
                          'lib/**/*.rb',
                          'ext/**/ruby_debug.c',
                          'README',
                          'LICENSE')
end
