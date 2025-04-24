require "httparty"
require "nokogiri"

class LinkExtractor
  def initialize(url)
    @url = url
  end

  def extract_links
    response = HTTParty.get(@url, headers: {
      "User-Agent" => "Mozilla/5.0 (TomoBot/1.0)"
    })

    html = response.body
    doc = Nokogiri::HTML(html)

    doc.css("a[href]").map do |a|
      begin
        href = a["href"]
        URI.join(@url, href).to_s
      rescue
        nil
      end
    end.compact.uniq
  end
end
