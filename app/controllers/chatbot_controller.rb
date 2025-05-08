class ChatbotController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation

  def index
    @faqs = Faq.all
    @messages = @conversation.chatbot_messages
                     .order(created_at: :desc)
                     .limit(20)

                     @messages = @messages.reverse
  end

  def load_more
    page = params[:page]&.to_i || 2
    per_page = 20
    @messages = @conversation.chatbot_messages
                     .order(created_at: :desc)
                     .limit(per_page)
                     .offset((page - 1) * per_page)

    @messages = @messages.reverse

    render json: @messages.map { |m| { sender: m.sender, content: m.content } }
  end

  def create
    user_message = params[:message]
    return render json: { error: "Empty message" }, status: :bad_request if user_message.blank?

    @conversation.chatbot_messages.create!(sender: "user", content: user_message)

    faq = Faq.find_by(question: user_message)
    if faq.present?
      bot_reply = faq.answer
    else
      bot_reply = call_ai_service(user_message)

      # Gợi ý sản phẩm theo category
      category = ChatService.extract_category(user_message)
      if category.present?
        suggested_products = Product.joins(:category)
                                   .where("categories.name ILIKE ?", "%#{category}%")
                                   .limit(5)

        if suggested_products.any?
          product_list = suggested_products.map do |product|
            {
              id: product.id,
              name: product.name,
              price: product.price,
              image_url: product.image_url,
              link: Rails.application.routes.url_helpers.product_path(product)
            }
          end

          @conversation.chatbot_messages.create!(sender: "bot", content: bot_reply)

          render json: {
            reply: bot_reply,
            suggested_products: product_list
          }
          return
        end
      end
    end

    @conversation.chatbot_messages.create!(sender: "bot", content: bot_reply)

    render json: { reply: bot_reply }
  end

  private

  def set_conversation
    @conversation = current_user.chatbot_conversations.first_or_create!
  end

  def call_ai_service(message)
    ChatService.call(message)
  rescue => e
    Rails.logger.error("AI Service Error: #{e.message}")
    "Xin lỗi, tôi chưa thể trả lời câu hỏi này lúc này."
  end
end
