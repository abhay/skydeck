require 'rubygems'
require 'curb'
require 'digest/sha1'
require 'json'

$:.unshift File.dirname(__FILE__) + '/skydeck'
require 'core_ext'

class Skydeck
  API_BASE_URL = "https://api.skydeck.com/api"
  
  attr_accessor :oauth_consumer_key, :oauth_token
  attr_accessor :oauth_signature_method, :oauth_signature
  attr_accessor :oauth_timestamp, :oauth_nonce
  attr_accessor :version
  
  REQUIRED_PARAMS = %w[
    version
    oauth_consumer_key
    oauth_signature_method
    oauth_signature
    oauth_token
    oauth_timestamp
    oauth_nonce
  ].map{|p| p.intern }
  
  def initialize(opts={})
    opts.each {|k,v| self.send("#{k}=", v)}
    
    @connection = Curl::Easy.new
    
  end
  
  def api_call(api_call, additional_query_params={}, http_method=:get, postdata={})
    full_url = "#{API_BASE_URL}/#{api_call}"
    query_str = required_query_params.merge(additional_query_params).to_qs
    
    response = raw_call full_url, query_str, http_method, postdata
    process_response(response)
  end
  
  class APIError < StandardError; end
  
  private
  
    def raw_call(full_url, query_str, http_method, postdata)
      @connection.url = "#{full_url}?#{query_str}"
      
      case http_method
      when :get
        @connection.headers = "" unless @connection.headers.empty?
        @connection.http_get
      when :post
        @connection.headers["Content-type"] = "application/json"
        @connection.http_post postdata.to_json
      else
        raise APIError.new("Unsupported HTTP Method: #{http_method.inspect}")
      end
      
      response_code = @connection.response_code
      response_body = @connection.body_str
      
      raise APIError.new(response_body) if [400, 401].include?(response_code)
      
      response_body
    end
    
    def process_response(response)
      JSON.parse(response.to_s) rescue {}
    end
    
    def required_query_params
      REQUIRED_PARAMS.inject({}) do |hsh, key|
        hsh.merge(key => self.send(key) || default_param(key))
      end
    end
    
    def default_param(key)
      case key
      when :oauth_signature_method
        "PLAINTEXT"
      when :oauth_timestamp
        "#{Time.now.to_i}"
      when :oauth_nonce
        Digest::SHA1.hexdigest("th15i5a53cr3t-#{Time.now.to_i}")
      end
    end
end
