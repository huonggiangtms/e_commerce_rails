import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["name", "phone", "province", "district", "ward", "addressDetails", "address", "nameError", "phoneError", "provinceError", "districtError", "wardError", "addressError"];

  connect() {
    this.fetchProvinces();
  }

  async fetchProvinces() {
    try {
      const response = await fetch("https://provinces.open-api.vn/api/p/");
      const provinces = await response.json();
      this.provinceTarget.innerHTML = '<option value="">Chọn Tỉnh/Thành phố</option>' + provinces.map(p => `<option value="${p.code}" data-name="${p.name}">${p.name}</option>`).join('');
    } catch (error) {
      console.error("Error fetching provinces:", error);
      this.provinceErrorTarget.textContent = "Không thể tải danh sách tỉnh/thành phố.";
      this.provinceErrorTarget.classList.remove("hidden");
    }
  }

  async fetchDistricts() {
    this.districtTarget.innerHTML = '<option value="">Chọn Quận/Huyện</option>';
    this.wardTarget.innerHTML = '<option value="">Chọn Phường/Xã</option>';
    this.districtErrorTarget.classList.add("hidden");
    this.wardErrorTarget.classList.add("hidden");
    this.updateAddress();

    const provinceCode = this.provinceTarget.value;
    if (!provinceCode) {
      this.districtTarget.disabled = true;
      this.wardTarget.disabled = true;
      return;
    }

    try {
      const response = await fetch(`https://provinces.open-api.vn/api/p/${provinceCode}?depth=2`);
      const data = await response.json();
      const districts = data.districts;
      this.districtTarget.innerHTML = '<option value="">Chọn Quận/Huyện</option>' + districts.map(d => `<option value="${d.code}" data-name="${d.name}">${d.name}</option>`).join('');
      this.districtTarget.disabled = false;
    } catch (error) {
      console.error("Error fetching districts:", error);
      this.districtErrorTarget.textContent = "Không thể tải danh sách quận/huyện.";
      this.districtErrorTarget.classList.remove("hidden");
    }
  }

  async fetchWards() {
    this.wardTarget.innerHTML = '<option value="">Chọn Phường/Xã</option>';
    this.wardErrorTarget.classList.add("hidden");
    this.updateAddress();

    const districtCode = this.districtTarget.value;
    if (!districtCode) {
      this.wardTarget.disabled = true;
      return;
    }

    try {
      const response = await fetch(`https://provinces.open-api.vn/api/d/${districtCode}?depth=2`);
      const data = await response.json();
      const wards = data.wards;
      this.wardTarget.innerHTML = '<option value="">Chọn Phường/Xã</option>' + wards.map(w => `<option value="${w.code}" data-name="${w.name}">${w.name}</option>`).join('');
      this.wardTarget.disabled = false;
    } catch (error) {
      console.error("Error fetching wards:", error);
      this.wardErrorTarget.textContent = "Không thể tải danh sách phường/xã.";
      this.wardErrorTarget.classList.remove("hidden");
    }
  }

  validateName() {
    const name = this.nameTarget.value;
    const regex = /^[\p{L}\s]+$/u;
    if (!name) {
      this.nameErrorTarget.textContent = "Họ và tên không được để trống.";
      this.nameErrorTarget.classList.remove("hidden");
      return false;
    } else if (name.length < 2 || name.length > 100) {
      this.nameErrorTarget.textContent = "Họ và tên phải từ 2 đến 100 ký tự.";
      this.nameErrorTarget.classList.remove("hidden");
      return false;
    } else if (!regex.test(name)) {
      this.nameErrorTarget.textContent = "Họ và tên chỉ được chứa chữ cái và khoảng trắng.";
      this.nameErrorTarget.classList.remove("hidden");
      return false;
    } else {
      this.nameErrorTarget.textContent = "";
      this.nameErrorTarget.classList.add("hidden");
      return true;
    }
  }

  validatePhone() {
    const phone = this.phoneTarget.value;
    const regex = /^0\d{9}$/;
    if (!phone) {
      this.phoneErrorTarget.textContent = "Số điện thoại không được để trống.";
      this.phoneErrorTarget.classList.remove("hidden");
      return false;
    } else if (!regex.test(phone)) {
      this.phoneErrorTarget.textContent = "Số điện thoại phải là 10 chữ số, bắt đầu bằng 0.";
      this.phoneErrorTarget.classList.remove("hidden");
      return false;
    } else {
      this.phoneErrorTarget.textContent = "";
      this.phoneErrorTarget.classList.add("hidden");
      return true;
    }
  }

  validateAddress() {
    const province = this.provinceTarget.value;
    const district = this.districtTarget.value;
    const ward = this.wardTarget.value;
    const details = this.addressDetailsTarget.value;

    this.provinceErrorTarget.classList.add("hidden");
    this.districtErrorTarget.classList.add("hidden");
    this.wardErrorTarget.classList.add("hidden");
    this.addressErrorTarget.classList.add("hidden");

    let isValid = true;

    if (!province) {
      this.provinceErrorTarget.textContent = "Vui lòng chọn tỉnh/thành phố.";
      this.provinceErrorTarget.classList.remove("hidden");
      isValid = false;
    }
    if (!district) {
      this.districtErrorTarget.textContent = "Vui lòng chọn quận/huyện.";
      this.districtErrorTarget.classList.remove("hidden");
      isValid = false;
    }
    if (!ward) {
      this.wardErrorTarget.textContent = "Vui lòng chọn phường/xã.";
      this.wardErrorTarget.classList.remove("hidden");
      isValid = false;
    }
    if (!details || details.length < 5) {
      this.addressErrorTarget.textContent = "Địa chỉ chi tiết phải từ 5 ký tự trở lên.";
      this.addressErrorTarget.classList.remove("hidden");
      isValid = false;
    }

    this.updateAddress();
    return isValid;
  }

  updateAddress() {
    const provinceName = this.provinceTarget.selectedOptions[0]?.dataset.name || "";
    const districtName = this.districtTarget.selectedOptions[0]?.dataset.name || "";
    const wardName = this.wardTarget.selectedOptions[0]?.dataset.name || "";
    const details = this.addressDetailsTarget.value || "";
    this.addressTarget.value = [details, wardName, districtName, provinceName].filter(Boolean).join(", ");
  }

  validateForm(event) {
    const isNameValid = this.validateName();
    const isPhoneValid = this.validatePhone();
    const isAddressValid = this.validateAddress();

    if (!isNameValid || !isPhoneValid || !isAddressValid) {
      event.preventDefault();
    }
  }
}
