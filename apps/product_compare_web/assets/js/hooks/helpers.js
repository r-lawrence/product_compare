
export const showHideToggle = (element, toggleClass, toggleItem, showText, hiddenText) => {
  let toggle = element.querySelector(toggleClass)
  let toggleDisplay = element.querySelector(toggleItem)

  toggle.addEventListener("click", () => {
    if (toggle.textContent === showText) {
      toggleDisplay.classList.remove("hidden")
      toggle.textContent = hiddenText
    } else {
      toggleDisplay.classList.add("hidden")
      toggle.textContent = showText
    }
  })
}