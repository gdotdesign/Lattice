require "rubygems"
require "bundler/setup"

require 'sinatra'
require 'haml'
require 'syntax'
require 'sass'
require 'uv'
require 'json'
require 'yaml'
require 'coffee-script'

load 'include/packager.rb'

class Gdotui < Sinatra::Application
  
  set :views, File.dirname(__FILE__) + "/views"
  set :root, File.dirname(__FILE__)
  set :public, Proc.new { File.join(root, "public") }
  set :port => 9090
  set :haml, {:format => :xhtml, :ugly=>true} 
  set :sass, {:style => :compressed}
  
  helpers do
    def parse(lines)
      ret = {}
      index = ''
      lines.each do |line|
        line.rstrip!
        if line =~ /^---(.*)//home/gdotdesign/github/mootools-core
          index = line.match(/^---(.*)/)[1].downcase
          ret[:"#{index}"] = ''
        else
          ret[:"#{index}"] += line+"\n"
        end
      end
      ret
    end
  end
  
  get /style\.css$/ do
    content_type 'text/css'
    sass :style
  end

  get "/home" do
    haml :home
  end

  get /\/Themes\/(.*)/ do
    send_file "../Themes/#{params[:captures].first}"
  end
  
  get /\/mootools\/(.*)/ do
    send_file "../mootools/#{params[:captures].first}"
  end

  get /\/builds\/(.*)/ do
    send_file "../builds/#{params[:captures].first}"
  end

  get "/docs" do
    haml :docindex
  end
  
  get "/demos" do
    haml :demoindex
  end
  
  get "/demos/:package/:class" do
    lines = IO.readlines "../Demos/#{params[:package]}/#{params[:class]}"
    @stuff = parse lines
    haml :demo
  end
  get "/docs/:package/:class" do
    @stuff = YAML::load(File.new("../Docs/#{params[:package]}/#{params[:class]}"))
    haml :docs
  end
  get '/build' do
    content_type 'text/plain'
    p = Packager.new("../package.yml")
    p.build
  end
  get '*' do
    haml '%div'
  end
 
  
end
