class GetFeed
  require "rubygems"
  require "curb"
  require "json"
  attr_reader :identifier, :options, :request, :response
  
  def initialize identifier, opts = {}
    @identifier = identifier
    raise_errors
    perform_request_and_parse_to_response
  end
  
  def perform_request_and_parse_to_response
    add_request
    perform_request
    parse_to_response
  end

  def add_request
    @request = Curl::Easy.http_get(request_uri)
  end

  def perform_request
    @request.perform
  end
  
  def parse_to_response
    @response = JSON.parse(@request.body_str)
  end
  
  def raise_errors
    raise "Use GetFeed::Twitter.new or GetFeed::Facebook.new instead of GetFeed.new" unless self.respond_to?("request_uri")
    raise ArgumentError, "identifier is required" if @identifier.nil? || @identifier.empty?
  end
  
  class Facebook < self
    BASE_URI = "https://graph.facebook.com/"
    def initialize identifier, opts = {}
      @options = {:limit => nil, :since => nil, :until => nil}.merge!(opts)
      super
    end
    def request_uri
      uri = BASE_URI+identifier+"/posts?"
      [:limit, :since, :until].each { |key| uri += "#{key.to_s}=#{@options[key].to_i}&" unless @options[key].nil? }
      return uri
    end
    def raise_errors
      super
      [:since, :until].each {|key| raise ArgumentError, "option #{key.to_s} has to be Time" if !@options[:key].nil? && !@options[:key].is_a?(Time)}
      raise ArgumentError, "option 'limit' has to be Fixnum" if !@options[:limit].nil? && !@options[:limit].is_a?(Fixnum)
    end
  end
  
  class Twitter < self
    BASE_URI = "http://twitter.com/status/user_timeline/"
    def initialize identifier, opts = {}
      @options = {:count => nil, :since_id => nil, :max_id => nil}.merge!(opts)
      super
    end
    def request_uri
      uri = BASE_URI+identifier+".json?include_entities=true"
      [:count, :since_id, :max_id].each { |key| uri += "&#{key.to_s}=#{@options[key].to_i}" unless @options[key].nil? }
      return uri
    end
    def raise_errors
      super
      [:count, :since_id, :max_id].each {|key| raise ArgumentError, "option '#{key.to_s}' has to be Fixnum" if !@options[:key].nil? && !@options[:key].is_a?(Fixnum) }
    end
  end
  
end




