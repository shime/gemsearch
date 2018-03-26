require "cgi"
require "json"
require "open-uri"

module Gemsearch
  class Fetcher
    RUBYGEMS_SEARCH_URL = "https://rubygems.org/api/v1/search.json"

    def fetch(query)
      JSON.parse(open("#{RUBYGEMS_SEARCH_URL}?query=#{CGI.escape(query)}").read)
    rescue OpenURI::HTTPError
      []
    end
  end
end
