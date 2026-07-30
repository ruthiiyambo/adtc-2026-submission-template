const messagesEl = document.querySelector("#messages");
const formEl = document.querySelector("#chat-form");
const inputEl = document.querySelector("#question-input");
const sendButtonEl = document.querySelector("#send-button");
const healthTextEl = document.querySelector("#health-text");
const healthPillEl = document.querySelector("#health-pill");
const promptChipEls = document.querySelectorAll(".prompt-chip");

const conversation = [];
let requestInFlight = false;

function setHealth(status, detail) {
  healthPillEl.className = "health-pill";

  if (status === "ok") {
    healthPillEl.classList.add("health-pill-ok");
    healthPillEl.textContent = "Heeno / Ready";
    healthTextEl.textContent = detail || "Local model is ready.";
    return;
  }

  if (status === "error") {
    healthPillEl.classList.add("health-pill-error");
    healthPillEl.textContent = "Aaye / Offline";
    healthTextEl.textContent =
      detail || "Local model not ready yet. Start llama-server first.";
    return;
  }

  healthPillEl.classList.add("health-pill-pending");
  healthPillEl.textContent = "Starting";
  healthTextEl.textContent = detail || "Checking local model...";
}

function scrollMessagesToBottom() {
  messagesEl.scrollTop = messagesEl.scrollHeight;
}

function addMessage(role, text, options = {}) {
  const wrapper = document.createElement("article");
  wrapper.className = `message message-${role}`;

  if (options.loading) {
    wrapper.classList.add("message-loading");
  }

  const roleEl = document.createElement("p");
  roleEl.className = "message-role";
  roleEl.textContent = role === "user" ? "Farmer" : "FarmHand NA";

  const bubbleEl = document.createElement("div");
  bubbleEl.className = "message-bubble";
  bubbleEl.textContent = text;

  wrapper.append(roleEl, bubbleEl);
  messagesEl.appendChild(wrapper);
  scrollMessagesToBottom();
  return bubbleEl;
}

function setComposerBusy(isBusy) {
  requestInFlight = isBusy;
  sendButtonEl.disabled = isBusy;
  inputEl.disabled = isBusy;
  sendButtonEl.textContent = isBusy ? "Thinking..." : "Ask FarmHand";
}

async function refreshHealth() {
  try {
    const response = await fetch("/api/health", { cache: "no-store" });
    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.detail || "Health check failed.");
    }

    const detail = data.detail || `Local model ready: ${data.model || "llama-server"}.`;
    setHealth("ok", detail);
  } catch (error) {
    setHealth("error", error.message);
  }
}

async function sendQuestion(question) {
  setComposerBusy(true);

  conversation.push({ role: "user", content: question });
  addMessage("user", question);

  const loadingBubbleEl = addMessage(
    "assistant",
    "Let me break that down into simple steps...",
    { loading: true }
  );

  try {
    const response = await fetch("/api/chat", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        messages: conversation,
        max_tokens: 360,
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.detail || "The local model returned an error.");
    }

    const answer = data.answer || "I could not generate an answer just now.";
    conversation.push({ role: "assistant", content: answer });
    loadingBubbleEl.textContent = answer;
    loadingBubbleEl.parentElement.classList.remove("message-loading");
  } catch (error) {
    loadingBubbleEl.textContent =
      "I could not reach the local model. Make sure `llama-server` is running, then try again.\n\nMore detail: " +
      error.message;
    loadingBubbleEl.parentElement.classList.remove("message-loading");
  } finally {
    setComposerBusy(false);
    inputEl.focus();
    scrollMessagesToBottom();
    refreshHealth();
  }
}

formEl.addEventListener("submit", async (event) => {
  event.preventDefault();

  if (requestInFlight) {
    return;
  }

  const question = inputEl.value.trim();

  if (!question) {
    inputEl.focus();
    return;
  }

  inputEl.value = "";
  await sendQuestion(question);
});

inputEl.addEventListener("keydown", (event) => {
  if ((event.metaKey || event.ctrlKey) && event.key === "Enter") {
    formEl.requestSubmit();
  }
});

promptChipEls.forEach((chipEl) => {
  chipEl.addEventListener("click", () => {
    inputEl.value = chipEl.dataset.prompt || "";
    inputEl.focus();
  });
});

setHealth("pending", "Checking local model...");
refreshHealth();
window.setInterval(refreshHealth, 15000);
