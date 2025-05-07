import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["widget", "chatbox", "messages", "input"]

  connect() {
    console.log("Chatbot controller connected.")
  }

  toggle() {
    this.chatboxTarget.classList.toggle("hidden")
  }

  async send() {
    const message = this.inputTarget.value.trim()
    if (!message) return

    this.addMessage("Bạn", message)
    this.inputTarget.value = ""

    try {
      const response = await fetch("/chatbot", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
        },
        body: JSON.stringify({ message })
      })

      const data = await response.json()

      this.addMessage("AI", data.reply || "Không có phản hồi.")

      if (data.suggested_products && data.suggested_products.length > 0) {
        this.addProductSuggestions(data.suggested_products)
      }
    } catch (err) {
      console.error("Chatbot error:", err)
      this.addMessage("AI", "Đã có lỗi xảy ra.")
    }
  }

  suggest(event) {
    const message = event.target.dataset.message
    this.inputTarget.value = message
    this.send()
  }

  addMessage(sender, content) {
    const div = document.createElement("div")
    const isUser = sender === "Bạn"
    div.className = isUser ? "text-right" : "text-left"
    div.innerHTML = `<div class="inline-block px-3 py-2 rounded-lg ${isUser ? 'bg-sky-100 text-sky-800 max-w-3/4 text-left' : 'bg-gray-100 text-gray-800 max-w-2/3'}">${content}</div>`
    this.messagesTarget.appendChild(div)
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  addProductSuggestions(products) {
    const suggestionContainer = document.createElement('div')
    suggestionContainer.className = "space-y-4 mt-4"

    const introText = document.createElement('p')
    introText.textContent = "Chúng tôi có một số sản phẩm sau có lẽ bạn sẽ thích:"
    introText.className = "text-sm text-gray-700 font-medium"
    suggestionContainer.appendChild(introText)

    products.forEach(product => {
      const productCard = document.createElement('div')
      productCard.className = `
        flex items-center gap-4 bg-white rounded-2xl p-3 
        shadow-md hover:bg-sky-100 transition cursor-pointer
      `

      const formattedPrice = new Intl.NumberFormat('vi-VN').format(product.price)

      productCard.innerHTML = `
        <a href="${product.link}" class="flex items-center gap-4 w-full no-underline">
          <img src="${product.image_url}" alt="${product.name}" 
              class="w-16 h-16 object-cover rounded-lg flex-shrink-0" />
          <div class="flex-1 min-w-0">
            <h3 class="text-sm font-medium text-gray-900 truncate">
              ${product.name}
            </h3>
            <p class="text-sm text-green-600 font-semibold mt-1">
              ${formattedPrice} đ
            </p>
          </div>
        </a>
      `

      suggestionContainer.appendChild(productCard)
    })

    this.messagesTarget.appendChild(suggestionContainer)
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }
}
