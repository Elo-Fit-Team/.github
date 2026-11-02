/* ==========================================================================
   ELOFIT - Client App & Registration Handler
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {
  initChips();
  initRegistrationForm();
  initCounter();
  initModal();
  initUserLogin();
});

// Level selector chips
function initChips() {
  const chips = document.querySelectorAll('.level-chip');
  const hiddenInput = document.getElementById('reg-level');
  if (!chips.length || !hiddenInput) return;

  chips.forEach(chip => {
    chip.addEventListener('click', () => {
      chips.forEach(c => c.classList.remove('active'));
      chip.classList.add('active');
      hiddenInput.value = chip.dataset.level || 'Новичок';
    });
  });
}

// Live registered athletes counter - strictly REAL count
function initCounter() {
  const counterEl = document.getElementById('hero-live-counter');
  if (!counterEl) return;

  fetch('/api/registrations')
    .then(r => r.json())
    .then(data => {
      if (Array.isArray(data)) {
        counterEl.textContent = data.length.toString();
      }
    })
    .catch(() => {
      const localData = getLocalRegistrations();
      counterEl.textContent = localData.length.toString();
    });
}

// Helper: Format Date & Exact Time (DD.MM.YYYY в HH:mm:ss)
function formatTimestamp(dateObj) {
  const d = dateObj || new Date();
  const pad = (n) => String(n).padStart(2, '0');

  const day = pad(d.getDate());
  const month = pad(d.getMonth() + 1);
  const year = d.getFullYear();

  const hours = pad(d.getHours());
  const minutes = pad(d.getMinutes());
  const seconds = pad(d.getSeconds());

  return {
    date: `${day}.${month}.${year}`,
    time: `${hours}:${minutes}:${seconds}`,
    fullFormatted: `${day}.${month}.${year} в ${hours}:${minutes}:${seconds}`,
    iso: d.toISOString()
  };
}

// Get registrations stored in localStorage
function getLocalRegistrations() {
  try {
    const raw = localStorage.getItem('elofit_registrations');
    return raw ? JSON.parse(raw) : [];
  } catch (e) {
    console.error('Error reading local registrations:', e);
    return [];
  }
}

// Save registration to localStorage
function saveLocalRegistration(record) {
  try {
    const list = getLocalRegistrations();
    list.unshift(record); // newest first
    localStorage.setItem('elofit_registrations', JSON.stringify(list));
    return true;
  } catch (e) {
    console.error('Error saving local registration:', e);
    return false;
  }
}

// Optional Telegram Notification Webhook
async function triggerTelegramNotification(record) {
  try {
    const configRaw = localStorage.getItem('elofit_tg_config');
    if (!configRaw) return;
    const config = JSON.parse(configRaw);
    if (!config.botToken || !config.chatId || !config.enabled) return;

    const message = `🔥 *Новая регистрация в EloFit!*
👤 *Имя:* ${record.name}
📧 *Email:* ${record.email}
📱 *Контакт:* ${record.contact}
🎯 *Цель:* ${record.goal}
⚡ *Уровень:* ${record.level}
⏰ *Время:* ${record.timeFormatted}`;

    await fetch(`https://api.telegram.org/bot${encodeURIComponent(config.botToken)}/sendMessage`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        chat_id: config.chatId,
        text: message,
        parse_mode: 'Markdown'
      })
    });
  } catch (err) {
    console.warn('Telegram notification skipped/failed:', err);
  }
}

// Main Registration Handler
function initRegistrationForm() {
  const form = document.getElementById('registration-form');
  const submitBtn = document.getElementById('btn-submit-registration');
  if (!form || !submitBtn) return;

  form.addEventListener('submit', async (e) => {
    e.preventDefault();

    const name = document.getElementById('reg-name').value.trim();
    const email = document.getElementById('reg-email').value.trim();
    const contact = document.getElementById('reg-contact').value.trim();
    const goal = document.getElementById('reg-goal').value;
    const level = document.getElementById('reg-level').value;

    // Basic validation
    if (!name) {
      showToast('Пожалуйста, укажите ваше имя или никнейм', 'error');
      document.getElementById('reg-name').focus();
      return;
    }

    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      showToast('Пожалуйста, введите корректный адрес email', 'error');
      document.getElementById('reg-email').focus();
      return;
    }

    if (!contact) {
      showToast('Пожалуйста, укажите Telegram (@username) или телефон', 'error');
      document.getElementById('reg-contact').focus();
      return;
    }

    // Capture exact date and time
    const now = new Date();
    const stamp = formatTimestamp(now);

    const newRecord = {
      id: 'reg_' + Date.now() + '_' + Math.random().toString(36).substring(2, 7),
      name,
      email,
      contact,
      goal,
      level,
      timestamp: stamp.iso,
      timeFormatted: stamp.fullFormatted,
      dateOnly: stamp.date,
      timeOnly: stamp.time,
      status: 'Новый'
    };

    // UI Loading state
    const originalBtnText = submitBtn.innerHTML;
    submitBtn.disabled = true;
    submitBtn.innerHTML = 'Запись данных... ⏳';

    try {
      // 1. Try sending to local backend server if active
      let serverSaved = false;
      try {
        const resp = await fetch('/api/register', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(newRecord)
        });
        if (resp.ok) {
          serverSaved = true;
        }
      } catch (_) {
        // Standalone static mode
      }

      // 2. Always persist locally in browser storage
      saveLocalRegistration(newRecord);
      localStorage.setItem('elofit_current_user', JSON.stringify(newRecord));

      // 3. Send Telegram notification if configured
      triggerTelegramNotification(newRecord);

      // 4. Update live counter
      initCounter();

      // 5. Open Success Modal with exact time
      showSuccessModal(newRecord);

      // 6. Reset form
      form.reset();
      const chips = document.querySelectorAll('.level-chip');
      chips.forEach((c, idx) => c.classList.toggle('active', idx === 0));
      document.getElementById('reg-level').value = 'Новичок';

    } catch (err) {
      console.error('Registration failed:', err);
      showToast('Произошла ошибка при регистрации. Попробуйте еще раз.', 'error');
    } finally {
      submitBtn.disabled = false;
      submitBtn.innerHTML = originalBtnText;
    }
  });
}

// User Login Modal Handler
function initUserLogin() {
  const openBtn = document.getElementById('btn-header-login');
  const modal = document.getElementById('login-modal');
  const closeBtn = document.getElementById('btn-close-login-modal');
  const switchLink = document.getElementById('link-switch-to-reg');
  const form = document.getElementById('user-login-form');

  if (openBtn && modal) {
    openBtn.addEventListener('click', () => modal.classList.add('active'));
  }

  if (closeBtn && modal) {
    closeBtn.addEventListener('click', () => modal.classList.remove('active'));
  }

  if (modal) {
    modal.addEventListener('click', (e) => {
      if (e.target === modal) modal.classList.remove('active');
    });
  }

  if (switchLink && modal) {
    switchLink.addEventListener('click', () => {
      modal.classList.remove('active');
      document.getElementById('register')?.scrollIntoView({ behavior: 'smooth' });
    });
  }

  if (form) {
    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      const query = (document.getElementById('login-identifier')?.value || '').toLowerCase().trim();
      if (!query) return;

      // 1. Fetch server registrations or read local
      let list = [];
      try {
        const resp = await fetch('/api/registrations');
        if (resp.ok) list = await resp.json();
      } catch (_) {}

      if (!list || list.length === 0) {
        list = getLocalRegistrations();
      }

      // 2. Find matching user
      const found = list.find(u => 
        (u.email && u.email.toLowerCase() === query) ||
        (u.contact && u.contact.toLowerCase() === query) ||
        (u.name && u.name.toLowerCase() === query)
      );

      if (found) {
        localStorage.setItem('elofit_current_user', JSON.stringify(found));
        showToast('Вход выполнен! Переходим в личный кабинет...');
        setTimeout(() => {
          window.location.href = 'account.html';
        }, 800);
      } else {
        showToast('Пользователь не найден. Зарегистрируйтесь ниже!', 'error');
        modal.classList.remove('active');
        document.getElementById('register')?.scrollIntoView({ behavior: 'smooth' });
      }
    });
  }
}

// Modal handling
function showSuccessModal(record) {
  const modal = document.getElementById('success-modal');
  if (!modal) return;

  document.getElementById('modal-name').textContent = record.name;
  document.getElementById('modal-email').textContent = record.email;
  document.getElementById('modal-contact').textContent = record.contact;
  document.getElementById('modal-time').textContent = record.timeFormatted;

  modal.classList.add('active');
}

function initModal() {
  const modal = document.getElementById('success-modal');
  const closeBtn = document.getElementById('btn-close-modal');
  if (!modal || !closeBtn) return;

  closeBtn.addEventListener('click', () => modal.classList.remove('active'));
  modal.addEventListener('click', (e) => {
    if (e.target === modal) modal.classList.remove('active');
  });
}

// Toast notification helper
function showToast(message, type = 'success') {
  const toast = document.getElementById('toast-notify');
  const msgEl = document.getElementById('toast-message');
  const iconEl = document.getElementById('toast-icon');
  if (!toast || !msgEl) return;

  toast.className = `toast ${type}`;
  msgEl.textContent = message;
  iconEl.textContent = type === 'success' ? '✓' : '⚠️';

  toast.classList.add('show');
  setTimeout(() => toast.classList.remove('show'), 3500);
}
