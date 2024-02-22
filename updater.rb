#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/inline'
require 'net/http'
require 'logger'
require 'json'
require 'optparse'
require 'pry'

class Requests
  class << self
    def fetch_zone_info(cloudflare_auth_key)
      uri = URI('https://api.cloudflare.com/client/v4/zones')
      headers = {
        'Authorization' => 'Bearer ' + cloudflare_auth_key,
        'Content-Type' => 'application/json'
      }
      response = Net::HTTP.get_response(uri, headers)
      JSON.parse(response.body)
    end

    def fetch_dns_records(api_key, zone_id, email)
      uri = URI("https://api.cloudflare.com/client/v4/zones/#{zone_id}/dns_records")
      headers = {
        'X-Auth-Key' => api_key,
        'X-Auth-Email' => email,
        'Content-Type' => 'application/json'
      }
      response = Net::HTTP.get_response(uri, headers)
      JSON.parse(response.body)
    end

    def update_dns_record(api_key, zone_id, email, record_id, ip_address, domain, proxied)
      uri = URI("https://api.cloudflare.com/client/v4/zones/#{zone_id}/dns_records/#{record_id}")
      headers = {
        'X-Auth-Key' => api_key,
        'X-Auth-Email' => email,
        'Content-Type' => 'application/json'
      }
      body = {
        'type' => 'A',
        'name' => domain,
        'content' => ip_address,
        'ttl' => 1,
        'proxied' => proxied
      }.to_json

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Put.new(uri.request_uri, headers)
      request.body = body

      response = http.request(request)

      JSON.parse(response.body)
    end
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: dns_updater [options]'

  opts.on('-e', '--email EMAIL', 'Cloudflare Email Address') do |e|
    options[:email] = e
  end

  opts.on('--auth-key AUTH_KEY', 'Cloudflare Auth Key') do |key|
    options[:auth_key] = key
  end

  opts.on('--api-key API_KEY', 'Cloudflare API Key') do |key|
    options[:api_key] = key
  end

  opts.on('-d', '--domain DOMAIN', 'Cloudflare Domain Name') do |d|
    options[:domain_name] = d
  end

  opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
    options[:verbose] = v
  end
end.parse!

email = (options[:email] || ENV['CLOUDFLARE_EMAIL']).to_s
auth_key = (options[:auth_key] || ENV['CLOUDFLARE_AUTH_KEY']).to_s
api_key = (options[:api_key] || ENV['CLOUDFLARE_API_KEY']).to_s
domain_name = (options[:domain_name] || ENV['CLOUDFLARE_DOMAIN_NAME']).to_s
debug = options[:verbose]

if debug
  puts "Cloudflare Email: #{email}"
  puts "Cloudflare Auth Key: #{auth_key}"
  puts "Cloudflare API Key: #{api_key}"
  puts "Cloudflare Domain Name: #{domain_name}"
end

current_ip_address = Net::HTTP.get(URI('https://api.ipify.org'))
puts "Current IP Address: #{current_ip_address}" if debug

prev_ip_address = nil

ip_address_file_path = ENV['HOME'] + '/.ip_address'
puts "IP Address File Path: #{ip_address_file_path}" if debug

if File.exist?(ip_address_file_path)
  prev_ip_address = File.read(ip_address_file_path)
  puts "Previous IP Address: #{prev_ip_address}" if debug
end

if current_ip_address == prev_ip_address
  exit 0
  puts 'IP address has not changed' if debug
end

zone_info = Requests.fetch_zone_info(auth_key)

zone_id = zone_info['result'].find { |zone| zone['name'] == domain_name }['id']

dns_records = Requests.fetch_dns_records(api_key, zone_id, email)

a_records = dns_records['result'].select { |record| record['type'] == 'A' }

responses = a_records.each_with_object([]) do |record, arr|
  arr << Requests.update_dns_record(
    api_key, zone_id, email, record['id'],
    current_ip_address, record['name'], record['proxied']
  )
end

logger = Logger.new(ENV['HOME'] + '/.ip_address.log')

failures = []
failures = responses.select { |res| res['success'] == false }

failures.each do |failure|
  logger.error(failure['errors'].join("\n"))
end

if failures.length == 0
  File.write(ip_address_file_path, current_ip_address)
  logger.info("IP address updated to #{current_ip_address}")
  exit 0
else
  exit 1
end
