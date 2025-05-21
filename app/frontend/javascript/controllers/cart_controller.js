import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["totalPrice", "itemTotal", "submitButton"];

  connect() {
    this.updateTotal();
  }

  updateTotal() {
    const checkboxes = this.element.querySelectorAll(".cart-item-checkbox");
    const checkedCheckboxes = this.element.querySelectorAll(".cart-item-checkbox:checked");
    let total = 0;

    checkedCheckboxes.forEach((checkbox) => {
      total += parseInt(checkbox.dataset.price);
    });

    this.totalPriceTargets.forEach((target) => {
      target.textContent = new Intl.NumberFormat("vi-VN", {
        style: "currency",
        currency: "VND",
        minimumFractionDigits: 0,
      }).format(total);
    });

    if (this.hasSubmitButtonTarget) {
      const isDisabled = checkedCheckboxes.length === 0;
      this.submitButtonTarget.disabled = isDisabled;

      if (isDisabled) {
        this.submitButtonTarget.classList.add(
          "bg-sky-400",
          "cursor-not-allowed",
          "opacity-50"
        );
        this.submitButtonTarget.classList.remove(
          "bg-gradient-to-r",
          "from-cyan-400",
          "to-blue-500",
          "hover:from-cyan-500",
          "hover:to-blue-600"
        );
      } else {
        this.submitButtonTarget.classList.remove(
          "bg-sky-400",
          "cursor-not-allowed",
          "opacity-50"
        );
        this.submitButtonTarget.classList.add(
          "bg-gradient-to-r",
          "from-cyan-400",
          "to-blue-500",
          "hover:from-cyan-500",
          "hover:to-blue-600"
        );
      }
    }


    const selectAllCheckbox = this.element.querySelector(".cart-item-checkbox-all");
    if (selectAllCheckbox) {
      selectAllCheckbox.checked = checkedCheckboxes.length === checkboxes.length;
    }
  }


  toggleAll(event) {
    const isChecked = event.target.checked;
    const checkboxes = this.element.querySelectorAll(".cart-item-checkbox"

    );
    checkboxes.forEach((checkbox) => {
      checkbox.checked = isChecked;
    });
    this.updateTotal();
  }

  updateItemPrice(event) {
    const input = event.target;
    const cartItemId = input.dataset.cartItemId;
    const quantity = parseInt(input.value);
    const cartItem = this.itemTotalTargets.find(
      (target) => target.dataset.cartItemId === cartItemId
    );

    fetch(`/cart_items/${cartItemId}.json`)
      .then((response) => response.json())
      .then((data) => {
        const newPrice = data.product_price * quantity;
        cartItem.textContent = new Intl.NumberFormat("vi-VN", {
          style: "currency",
          currency: "VND",
          minimumFractionDigits: 0,
        }).format(newPrice);
        const checkbox = cartItem.closest(".cart-item").querySelector(".cart-item-checkbox");
        checkbox.dataset.price = newPrice;
        checkbox.checked = true;
        this.updateTotal();
      });
  }
}
