class LoadMoresController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation

  def index
    Rails.logger.info "Loading page: #{params[:page]}"
    @messages = @conversation.chatbot_messages
                     .order(created_at: :desc)
                     .page(params[:page]).per(20)

    render json: {
      messages: @messages.map { |m| { id: m.id, sender: m.sender, content: m.content, created_at: m.created_at } },
      next_page: @messages.next_page,
      has_more: @messages.next_page.present?
    }
  end

  private

  def set_conversation
    @conversation = current_user.chatbot_conversations.first_or_create!
  end
end
