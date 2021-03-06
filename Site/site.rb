require "rubygems"
require "bundler/setup"


require 'sinatra'
require 'haml'
require 'sass'
require 'json'
require 'yaml'
require 'coffee-script'

load 'Site/include/packager.rb'


class Gdotui < Sinatra::Application
  
  class Class
    attr_accessor :attributes, :functions, :events, :extends, :name, :description, :implements, :demo
    def initialize
      @name = ''
      @functions = {}
      @attributes = {}
      @implements = []
      @events = []
    end
    def parse(yaml)
      @name = yaml['class']
      @description = yaml['description']
      @extends = yaml['extends']
      @demo = yaml['demo']
      if yaml['implements']
        yaml['implements'].each do |func|
          @implements.push func
        end
      end
      if yaml['functions']
        yaml['functions'].each do |func|
          @functions[:"#{func[0]}"] = func[1]
        end
      end
      if yaml['events']
        yaml['events'].each do |func|
          @events.push func
        end
      end
      if yaml['attributes']
        yaml['attributes'].each do |func|
          @attributes[:"#{func[0]}"] = func[1]
        end
      end
    end
    def mergeExtends
      if @extends
         mergeString @extends
      end
    end
    def mergeImplements
      @implements.each do |imp|
        mergeString imp
      end
    end
    def mergeString(str)
      cls = str.split '.'
       if File.exists?("Docs/#{cls[0]}/#{cls[1]}")
         class2 = Class.new()
         class2.parse YAML::load(File.new("Docs/#{cls[0]}/#{cls[1]}"))
         class2.mergeAll()
         merge class2
       end
    end
    def mergeAll
      mergeExtends
      mergeImplements
    end
    def merge(class2)
      for attribute in class2.attributes
        if !@attributes[attribute[0]]
          @attributes[attribute[0]] = attribute[1]
          @attributes[attribute[0]]["inherited"] = true
        end
      end
      for func in class2.functions
        if !@functions[func[0]]
          @functions[func[0]] = func[1]
          @functions[func[0]]["inherited"] = true
        end
      end
    end
  end
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
  get /blender\.css$/ do
    content_type 'text/css'
    sass :blender
  end

  get "/home" do
    haml :home
  end

  get /\/Themes\/(.*)/ do
    send_file "Themes/#{params[:captures].first}"
  end
  
  get /\/builds\/(.*)/ do
    send_file "Build/#{params[:captures].first}"
  end

  get "/reference" do
    haml :docindex
  end
  
  get "/demos" do
    haml :demos
  end
  
  get "/reference/:package/:class" do
    @class = Class.new()
    @class.parse YAML::load(File.new("Docs/#{params[:package]}/#{params[:class]}"))
    @class.mergeAll
    haml :docs
  end
  get '/download' do
    haml :build
  end
  
  get '/roadmap' do
    haml :roadmap
  end
  
  get '/docs' do
    haml :wiki
  end
  
  post '/download' do
    content_type 'application/octet-stream'
    response['Content-disposition'] = "attachment; filename=gdotui.js;"
    p = Packager.new("package.yml")
    cont = p.build params['files']
    CoffeeScript.compile cont, :bare=>true
  end
  
  get '/themes' do
    haml :themes
  end
  get '/' do
    haml :home
  end
  get '*' do
    haml '%div'
  end
 
  
end
