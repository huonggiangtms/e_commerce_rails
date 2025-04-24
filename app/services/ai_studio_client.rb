require 'httparty'

class AiStudioClient
  include HTTParty
  base_uri "https://generativelanguage.googleapis.com"

  def initialize
    @api_key = Rails.application.credentials.crawler_api_key
    @model = "gemini-2.0-flash"
    @version = "v1beta"
  end

  def analyze_product_html(html)
    prompt = {
      contents: [
        {
          parts: [
            {
              text: <<~TEXT
                Đây là HTML của một trang chi tiết sản phẩm.
                Hãy phân tích và trích xuất thông tin sản phẩm gồm các trường sau:

                - Name
                - Price
                - Description (có thể phân tích mô tả hoặc để trống nếu không rõ)
                - Image URL
                - Category (gợi ý như: "Điện thoại", "Laptop", "Phụ kiện",...)

                Format:
                Name: <Tên sản phẩm>
                Price: <Giá sản phẩm>
                Description: <Mô tả>
                Image URL: <URL hình ảnh>
                Category: <Tên danh mục>

                HTML:
                #{html}
              TEXT
            }
          ]
        }
      ]
    }

    retries = 0

    begin
      response = self.class.post(
        "/#{@version}/models/#{@model}:generateContent",
        query: { key: @api_key },
        headers: { 'Content-Type' => 'application/json' },
        body: prompt.to_json
      )

      if response.code == 200
        raw_text = response.parsed_response.dig("candidates", 0, "content", "parts", 0, "text")
        return parse_response_text(raw_text)
      elsif response.code == 429
        retry_delay = extract_retry_delay(response) || 30
        raise "Quota exceeded. Retrying after #{retry_delay}s..."
      else
        Rails.logger.error("AI Product API Error: #{response.code} - #{response.body}")
        return nil
      end

    rescue => e
      if retries < 2
        retries += 1
        delay = e.message[/\d+/].to_i
        delay = 30 if delay.zero?
        Rails.logger.warn("Lỗi khi gọi API: #{e.message}. Thử lại sau #{delay}s (lần #{retries})...")
        sleep delay
        retry
      else
        Rails.logger.error("Thử lại nhiều lần vẫn lỗi: #{e.message}")
        return nil
      end
    end
  end

  def filter_product_links_from_text(text)
    prompt = {
      contents: [
        {
          parts: [
            {
              text: <<~TEXT
                Đây là danh sách các đường link:
                #{text}

                Hãy chọn ra các link dẫn tới **trang chi tiết sản phẩm** và trả về **mỗi link trên một dòng**.
                Không thêm chú thích hay ký hiệu gì khác.
              TEXT
            }
          ]
        }
      ]
    }

    retries = 0

    begin
      response = self.class.post(
        "/#{@version}/models/#{@model}:generateContent",
        query: { key: @api_key },
        headers: { 'Content-Type' => 'application/json' },
        body: prompt.to_json
      )

      if response.code == 200
        raw_text = response.parsed_response.dig("candidates", 0, "content", "parts", 0, "text")
        return raw_text.split("\n").map(&:strip).reject(&:blank?)
      elsif response.code == 429
        retry_delay = extract_retry_delay(response) || 30
        raise "Quota exceeded. Retrying after #{retry_delay}s..."
      else
        Rails.logger.error("AI Filter API Error: #{response.code} - #{response.body}")
        return []
      end
    rescue => e
      if retries < 2
        retries += 1
        delay = e.message[/\d+/].to_i
        delay = 30 if delay.zero?
        Rails.logger.warn("Lỗi khi gọi API: #{e.message}. Thử lại sau #{delay}s (lần #{retries})...")
        sleep delay
        retry
      else
        Rails.logger.error("Thử lại nhiều lần vẫn lỗi: #{e.message}")
        return []
      end
    end
  end

  private

  def parse_response_text(text)
    return nil unless text.present?

    products = []
    product = {}

    text.each_line do |line|
      case line
      when /^Name:\s*(.+)/i
        products << product if product.present?
        product = { name: $1.strip }
      when /^Price:\s*(.+)/i
        product[:price] = $1.strip
      when /^Category:\s*(.+)/i
        product[:category] = $1.strip
      when /^Description:\s*(.+)/i
        product[:description] = $1.strip
      when /^Image URL:\s*(https?:\/\/\S+)/i
        product[:image_url] = $1.strip
      when /^\s*$/
        next
      end
    end

    products << product if product.present?
    products
  end

  def extract_retry_delay(response)
    retry_info = response.parsed_response.dig("error", "details")&.find do |d|
      d["@type"]&.include?("RetryInfo")
    end

    return nil unless retry_info

    retry_delay_str = retry_info["retryDelay"] || "30s"
    retry_delay_str.to_i
  end
end
