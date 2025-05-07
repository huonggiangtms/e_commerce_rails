require "net/http"
require "json"

class ChatService
  API_URL = "https://generativelanguage.googleapis.com"
  MODEL = "gemini-2.0-flash"
  VERSION = "v1beta"
  ENDPOINT = "/#{VERSION}/models/#{MODEL}:generateContent"

  def self.call(message)
    system_instruction = <<~PROMPT
     Bạn là một nhân viên tư vấn bán hàng thân thiện với 50 năm kinh nghiệm tại cửa hàng ZShop (tên của bạn là: ZShop AI). Hãy:
      - Nhớ rằng ZShop là một cửa hàng về chuyên bán đề đồ dùng công nghệ.
      - Tuyệt đối không được ***nội dung*** để in đậm mà hãy gạch ý cho người dùng dễ hiểu.
      - Nếu người dùng chào hỏi, bắt buộc bạn phải chào lại lịch sự và thân thiện.
      - Nếu người dùng hỏi về sản phẩm, hãy gợi ý sản phẩm/danh mục phù hợp có bán tại ZShop.
      - Trả lời NGẮN GỌN dễ hiểu KHÔNG dài dòng.
      - Trả lời bằng đúng ngôn ngữ. Khi người dùng nhắn bằng tiếng Việt thì trả lời bằng tiếng Việt, tiếng Anh thì trả lời bằng tiếng Anh,...
      - Nếu không hiểu ý người dùng, hãy hỏi lại một cách lịch sự.
      - Tuyệt đối không trả lời những gì không liên quan đến mua sắm hoặc ZShop và xin lỗi khách hàng lịch sự.
      - Trả lời theo format của tin nhắn
      - Khi khách hàng hỏi đến hotline hay liên hệ nhanh chóng hãy trả lời số hotline cho khách hàng (0858328685)
    PROMPT

    contents = [
      { role: "user", parts: [ { text: system_instruction.strip } ] },
      { role: "user", parts: [ { text: message } ] }
    ]

    send_request(contents) || "Xin lỗi, tôi chưa thể phản hồi lúc này."
  end

  def self.extract_category(message)
    prompt = <<~PROMPT
      Bạn là chuyên gia phân tích, tư vấn viên về đồ dùng công nghệ với 50 năm kinh nghiệm tại cửa hàng ZShop.
      Người dùng hỏi: "#{message}"
      Hãy phân loại nội dung câu hỏi này vào **một danh mục sản phẩm duy nhất** có thể có tại cửa hàng ZShop như: Điện thoại, Laptop, Tai nghe, Phụ kiện, Tủ lạnh, Máy ảnh,Smartwatch, Quạt v.v.
      Trả lời duy nhất bằng tên danh mục liên quan đến đồ điện tử, không giải thích thêm. Nếu không phân loại được, hãy trả về: "khác".
    PROMPT

    contents = [
      { role: "user", parts: [ { text: prompt.strip } ] }
    ]

    send_request(contents) || "khác"
  end

  private

  def self.api_key
    Rails.application.credentials.dig(:ai_api, :chatbot_api_key)
  end

  def self.headers
    { "Content-Type" => "application/json" }
  end

  def self.send_request(contents)
    body = { contents: contents }

    response = HTTParty.post(
      "#{API_URL}#{ENDPOINT}",
      query: { key: api_key },
      headers: headers,
      body: body.to_json
    )

    if response.code == 200
      response.parsed_response.dig("candidates", 0, "content", "parts", 0, "text")&.strip
    else
      Rails.logger.error("[Gemini API Error] #{response.code} - #{response.body}")
      nil
    end
  rescue => e
    Rails.logger.error "[Gemini API Rescue] #{e.message}"
    nil
  end
end
