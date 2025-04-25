class ProductCrawler
  def initialize(url)
    @url = url
    @client = AiStudioClient.new
  end

  def crawl_and_save
    puts "Starting crawl for: #{@url}"

    links = LinkExtractor.new(@url).extract_links
    puts "Total Links (Before AI filtering): #{links.size}"

    filtered_links = filter_product_links(links)
    puts "Total Links (After AI filtering): #{filtered_links.size}"

    filtered_links.each do |link|
      puts "Analyzing: #{link}"
      product_data = analyze_product(link)
      save_product(product_data, link) if product_data
    end

    puts "Done."
  end

  private

  def filter_product_links(links)
    return [] if links.empty?

    response = @client.filter_product_links_from_text(links.join("\n"))
    if response.blank?
      puts "AI không trả về link sản phẩm"
      return []
    end

    response
  end

  def analyze_product(link)
    uri = URI.parse(link) rescue nil
    return nil unless uri&.is_a?(URI::HTTP)

    html = HTTParty.get(link).body
    products = @client.analyze_product_html(html)

    if products.blank?
      puts "Không có sản phẩm nào được phân tích từ: #{link}"
      return nil
    end

    product = products.first
    puts "Phân tích sản phẩm: #{product[:name]}"
    product.stringify_keys
  rescue => e
    puts "Lỗi khi phân tích sản phẩm: #{e.message}"
    nil
  end

  def save_product(data, source_url)
    return unless data["name"].present? && data["price"].present?

    price = extract_price(data["price"])

    product = CrawledProduct.find_or_initialize_by(source_url: source_url)

    product.assign_attributes(
      name: data["name"],
      price: price,
      description: data["description"],
      image_url: data["image_url"],
      category_name: data["category"],
      stock: data["stock"] || 0,
      status: "pending"
    )

    product.save!

    if product.previous_changes.key?(:id)
      puts "Saved: #{data["name"]} (new)"
    else
      puts "Updated: #{data["name"]} (existing)"
    end
  rescue => e
    puts "Error saving product: #{e.message}"
  end

  def extract_price(price_str)
    price_str.gsub(/[^\d]/, "").to_i
  end
end
