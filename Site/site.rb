require "rubygems"
require "bundler/setup"

require 'sinatra'
require 'haml'
require 'syntax'
require 'sass'
require 'uv'
require 'json'
require 'yaml'

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
        if line =~ /^---(.*)/
          index = line.match(/^---(.*)/)[1].downcase
          ret[:"#{index}"] = ''
        else
          puts index
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

  get "/Themes/*" do
    puts 'style'
    send_file "../Themes/#{params[:splat][0]}"
  end
  
  get "/mootools/*" do
    puts 'style'
    send_file "../mootools/#{params[:splat][0]}"
  end

  get "/builds/*" do
    puts 'style'
    send_file "../builds/#{params[:splat][0]}"
  end

  get "/:package/:class" do
    lines = IO.readlines "../Demos/#{params[:package]}/#{params[:class]}"
    @stuff = parse lines
    haml :demo
    #@stuff = YAML::load(File.new("../Docs/#{params[:package]}/#{params[:class]}"))
    #puts @stuff.inspect
    #haml :docs
  end
  
  get '*' do
    haml '%div'
  end
 
  
end
