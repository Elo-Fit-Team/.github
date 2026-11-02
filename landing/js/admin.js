/* ==========================================================================
   ELOFIT - Admin Dashboard Logic
   ========================================================================== */

const ADMIN_PASSWORD_DEFAULT = 'elofit2026';

let registrations = [];
let filteredRegistrations = [];

document.addEventListener('DOMContentLoaded', () => {
  initAuthGate();
  initClock();
  initEventListeners();
});

// Authentication Gate
function initAuthGate() {
  const isAuth = sessionStorage.getItem('elofit_admin_auth') === 'true';
  const gateEl = document.getElementById('auth-gate');
  const mainView = document.getElementById('admin-main-view');

  if (isAuth) {
    if (gateEl) gateEl.style.display = 'none';
    if (mainView) mainView.style.display = 'block';
    loadData();
  } else {
    if (gateEl) gateEl.style.display = 'flex';
    if (mainView) mainView.style.display = 'none';
  }

  const form = document.getElementById('auth-gate-form');
  if (form) {
    form.addEventListener('submit', (e) => {
      e.preventDefault();
      const input = document.getElementById('admin-pass-input').value.trim();
      if (input === ADMIN_PASSWORD_DEFAULT) {
        sessionStorage.setItem('elofit_admin_auth', 'true');
        gateEl.style.display = 'none';
        mainView.style.display = 'block';
        loadData();
        showToast('Добро пожаловать в панель администратора!');
      } else {
        showToast('Неверный пароль администратора', 'error');
      }
    });
  }

  const logoutBtn = document.getElementById('btn-logout');
  if (logoutBtn) {
    logoutBtn.addEventListener('click', () => {
      sessionStorage.removeItem('elofit_admin_auth');
      window.location.reload();
    });
  }
}

// Live Digital Clock (Shows seconds)
function initClock() {
  const clockEl = document.getElementById('live-clock');
  if (!clockEl) return;

  function update() {
    const now = new Date();
    const pad = (n) => String(n).padStart(2, '0');
    clockEl.textContent = `${pad(now.getDate())}.${pad(now.getMonth() + 1)}.${now.getFullYear()}, ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
  }

  update();
  setInterval(update, 1000);
}

// Load Data from Server API or LocalStorage
async function loadData() {
  let loaded = false;

  // 1. Try local server endpoint if available
  try {
    const res = await fetch('/api/registrations');
    if (res.ok) {
      const serverData = await res.json();
      if (Array.isArray(serverData)) {
        registrations = serverData;
        loaded = true;
      }
    }
  } catch (_) {
    // Static mode fallback
  }

  // 2. If server not active, read from localStorage
  if (!loaded) {
    try {
      const raw = localStorage.getItem('elofit_registrations');
      registrations = raw ? JSON.parse(raw) : [];
    } catch (e) {
      console.error('Error reading localStorage:', e);
      registrations = [];
    }
  }

  // Only display real registrations from server or local storage
  applyFiltersAndRender();
}

function saveRegistrations() {
  localStorage.setItem('elofit_registrations', JSON.stringify(registrations));
  // Also sync to server if running
  try {
    fetch('/api/sync', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(registrations)
    }).catch(() => {});
  } catch (_) {}
}

// Compute & update Stats Cards
function updateStats() {
  const totalEl = document.getElementById('stat-total');
  const todayEl = document.getElementById('stat-today');
  const lasthourEl = document.getElementById('stat-lasthour');
  const goalEl = document.getElementById('stat-goal');

  if (!totalEl) return;

  totalEl.textContent = registrations.length.toString();

  const now = new Date();
  const todayStr = `${String(now.getDate()).padStart(2, '0')}.${String(now.getMonth() + 1).padStart(2, '0')}.${now.getFullYear()}`;
  const oneHourAgo = now.getTime() - 60 * 60 * 1000;

  let todayCount = 0;
  let lastHourCount = 0;
  const goalCounts = {};

  registrations.forEach(r => {
    if (r.dateOnly === todayStr) {
      todayCount++;
    }
    const t = new Date(r.timestamp).getTime();
    if (!isNaN(t) && t >= oneHourAgo) {
      lastHourCount++;
    }
    if (r.goal) {
      goalCounts[r.goal] = (goalCounts[r.goal] || 0) + 1;
    }
  });

  todayEl.textContent = todayCount.toString();
  lasthourEl.textContent = lastHourCount.toString();

  // Find top goal
  let topGoal = 'Пока нет данных';
  let maxCount = 0;
  for (const [goal, count] of Object.entries(goalCounts)) {
    if (count > maxCount) {
      maxCount = count;
      topGoal = goal;
    }
  }
  goalEl.textContent = topGoal;
}

// Filter, Search, Sort & Render
function applyFiltersAndRender() {
  const search = (document.getElementById('filter-search')?.value || '').toLowerCase().trim();
  const goalFilter = document.getElementById('filter-goal')?.value || '';
  const levelFilter = document.getElementById('filter-level')?.value || '';
  const sortBy = document.getElementById('filter-sort')?.value || 'newest';

  filteredRegistrations = registrations.filter(r => {
    const matchesSearch = !search ||
      (r.name && r.name.toLowerCase().includes(search)) ||
      (r.email && r.email.toLowerCase().includes(search)) ||
      (r.contact && r.contact.toLowerCase().includes(search));

    const matchesGoal = !goalFilter || r.goal === goalFilter;
    const matchesLevel = !levelFilter || r.level === levelFilter;

    return matchesSearch && matchesGoal && matchesLevel;
  });

  // Sort
  if (sortBy === 'newest') {
    filteredRegistrations.sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime());
  } else if (sortBy === 'oldest') {
    filteredRegistrations.sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime());
  } else if (sortBy === 'name') {
    filteredRegistrations.sort((a, b) => (a.name || '').localeCompare(b.name || ''));
  }

  renderTable();
  updateStats();
}

// Render Table Rows
function renderTable() {
  const tbody = document.getElementById('users-table-body');
  const emptyState = document.getElementById('table-empty-state');
  if (!tbody) return;

  tbody.innerHTML = '';

  if (filteredRegistrations.length === 0) {
    if (emptyState) emptyState.style.display = 'block';
    return;
  }
  if (emptyState) emptyState.style.display = 'none';

  filteredRegistrations.forEach((r, index) => {
    const tr = document.createElement('tr');

    // Initials for avatar
    const initials = (r.name || 'Атлет')
      .split(' ')
      .map(part => part[0])
      .slice(0, 2)
      .join('')
      .toUpperCase();

    // Contact link parsing
    let contactHtml = escapeHtml(r.contact || '-');
    if (r.contact && r.contact.startsWith('@')) {
      const handle = r.contact.replace('@', '');
      contactHtml = `<a href="https://t.me/${handle}" target="_blank" rel="noopener" class="contact-link">✈️ @${escapeHtml(handle)}</a>`;
    } else if (r.contact && /^\+?[\d\s\-()]+$/.test(r.contact)) {
      const cleanPhone = r.contact.replace(/[^\d+]/g, '');
      contactHtml = `<a href="tel:${cleanPhone}" class="contact-link">📞 ${escapeHtml(r.contact)}</a>`;
    }

    // Relative time calculation
    const relativeTimeStr = getRelativeTimeString(r.timestamp);

    tr.innerHTML = `
      <td style="color: var(--text-muted); font-size: 0.8rem; font-weight: 600;">${index + 1}</td>
      <td>
        <div class="user-col">
          <div class="user-avatar-initials">${initials}</div>
          <div>
            <div class="user-info-name">${escapeHtml(r.name || 'Без имени')}</div>
            <div class="user-info-sub">ID: ${escapeHtml(r.id || '-')}</div>
          </div>
        </div>
      </td>
      <td>
        <span style="font-family: monospace; font-size: 0.86rem; color: #E2E8F0;">${escapeHtml(r.email || '-')}</span>
      </td>
      <td>
        ${contactHtml}
      </td>
      <td>
        <span style="background: rgba(255,255,255,0.06); padding: 4px 10px; border-radius: 6px; font-size: 0.8rem;">
          ${escapeHtml(r.goal || 'Не указана')}
        </span>
      </td>
      <td>
        <span style="background: rgba(59, 130, 246, 0.12); color: #60A5FA; padding: 4px 10px; border-radius: 12px; font-size: 0.78rem; font-weight: 600;">
          ${escapeHtml(r.level || 'Новичок')}
        </span>
      </td>
      <td>
        <span class="time-badge">
          ⏰ ${escapeHtml(r.timeFormatted || r.timestamp || '-')}
        </span>
        <span class="time-relative">${relativeTimeStr}</span>
      </td>
      <td>
        <select class="status-select" data-id="${r.id}">
          <option value="Новый" ${r.status === 'Новый' ? 'selected' : ''}>🆕 Новый</option>
          <option value="Связались" ${r.status === 'Связались' ? 'selected' : ''}>💬 Связались</option>
          <option value="Выдан доступ" ${r.status === 'Выдан доступ' ? 'selected' : ''}>✅ Выдан доступ</option>
          <option value="Архив" ${r.status === 'Архив' ? 'selected' : ''}>📁 Архив</option>
        </select>
      </td>
      <td>
        <button class="btn-delete" data-id="${r.id}" title="Удалить запись">
          ✕
        </button>
      </td>
    `;

    tbody.appendChild(tr);
  });

  // Attach status change & delete events
  tbody.querySelectorAll('.status-select').forEach(sel => {
    sel.addEventListener('change', (e) => {
      const id = e.target.dataset.id;
      const val = e.target.value;
      const target = registrations.find(x => x.id === id);
      if (target) {
        target.status = val;
        saveRegistrations();
        showToast('Статус обновлен');
      }
    });
  });

  tbody.querySelectorAll('.btn-delete').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const id = e.target.dataset.id;
      if (confirm('Точно удалить эту регистрацию?')) {
        registrations = registrations.filter(x => x.id !== id);
        saveRegistrations();
        applyFiltersAndRender();
        showToast('Регистрация удалена');
      }
    });
  });
}

// Relative time string helper (например: "5 минут назад")
function getRelativeTimeString(isoString) {
  if (!isoString) return '';
  const date = new Date(isoString);
  if (isNaN(date.getTime())) return '';

  const diffSec = Math.floor((Date.now() - date.getTime()) / 1000);
  if (diffSec < 60) return 'только что';
  const diffMin = Math.floor(diffSec / 60);
  if (diffMin < 60) return `${diffMin} мин. назад`;
  const diffHours = Math.floor(diffMin / 60);
  if (diffHours < 24) return `${diffHours} ч. назад`;
  const diffDays = Math.floor(diffHours / 24);
  return `${diffDays} дн. назад`;
}

// Export Table to CSV / Excel
function exportToCSV() {
  if (registrations.length === 0) {
    showToast('Нет данных для экспорта', 'error');
    return;
  }

  const headers = ['#', 'Имя', 'Email', 'Контакт', 'Цель', 'Уровень', 'Дата и время', 'Статус', 'ID'];
  const rows = registrations.map((r, i) => [
    i + 1,
    `"${(r.name || '').replace(/"/g, '""')}"`,
    `"${(r.email || '').replace(/"/g, '""')}"`,
    `"${(r.contact || '').replace(/"/g, '""')}"`,
    `"${(r.goal || '').replace(/"/g, '""')}"`,
    `"${(r.level || '').replace(/"/g, '""')}"`,
    `"${(r.timeFormatted || '').replace(/"/g, '""')}"`,
    `"${(r.status || '').replace(/"/g, '""')}"`,
    `"${(r.id || '').replace(/"/g, '""')}"`
  ]);

  const csvContent = '\uFEFF' + [headers.join(';'), ...rows.map(e => e.join(';'))].join('\r\n');
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');

  const now = new Date();
  const dateStr = `${now.getFullYear()}-${String(now.getMonth()+1).padStart(2,'0')}-${String(now.getDate()).padStart(2,'0')}`;
  link.setAttribute('href', url);
  link.setAttribute('download', `elofit_registrations_${dateStr}.csv`);
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);

  showToast('Таблица скачана в формате CSV/Excel! 📥');
}

// Event Listeners initialization
function initEventListeners() {
  document.getElementById('filter-search')?.addEventListener('input', applyFiltersAndRender);
  document.getElementById('filter-goal')?.addEventListener('change', applyFiltersAndRender);
  document.getElementById('filter-level')?.addEventListener('change', applyFiltersAndRender);
  document.getElementById('filter-sort')?.addEventListener('change', applyFiltersAndRender);

  document.getElementById('btn-export-csv')?.addEventListener('click', exportToCSV);

  // Telegram modal
  const tgModal = document.getElementById('tg-settings-modal');
  document.getElementById('btn-open-tg-settings')?.addEventListener('click', () => {
    loadTgSettings();
    tgModal.classList.add('active');
  });
  document.getElementById('btn-close-tg')?.addEventListener('click', () => {
    tgModal.classList.remove('active');
  });
  document.getElementById('btn-save-tg')?.addEventListener('click', saveTgSettings);
  document.getElementById('btn-test-tg')?.addEventListener('click', testTgNotification);
}

// Telegram Settings
function loadTgSettings() {
  try {
    const raw = localStorage.getItem('elofit_tg_config');
    if (raw) {
      const cfg = JSON.parse(raw);
      document.getElementById('tg-bot-token').value = cfg.botToken || '';
      document.getElementById('tg-chat-id').value = cfg.chatId || '';
      document.getElementById('tg-enabled').checked = cfg.enabled !== false;
    }
  } catch (_) {}
}

function saveTgSettings() {
  const botToken = document.getElementById('tg-bot-token').value.trim();
  const chatId = document.getElementById('tg-chat-id').value.trim();
  const enabled = document.getElementById('tg-enabled').checked;

  const config = { botToken, chatId, enabled };
  localStorage.setItem('elofit_tg_config', JSON.stringify(config));
  document.getElementById('tg-settings-modal').classList.remove('active');
  showToast('Настройки Telegram успешно сохранены! ✈️');
}

async function testTgNotification() {
  const botToken = document.getElementById('tg-bot-token').value.trim();
  const chatId = document.getElementById('tg-chat-id').value.trim();

  if (!botToken || !chatId) {
    showToast('Введите Bot Token и Chat ID', 'error');
    return;
  }

  showToast('Отправка тестового сообщения...', 'info');

  try {
    const res = await fetch(`https://api.telegram.org/bot${encodeURIComponent(botToken)}/sendMessage`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        chat_id: chatId,
        text: '⚡ *Тестовое оповещение EloFit!*\n\nСвязка с Telegram ботом работает отлично! Теперь при каждой регистрации на сайте вы будете сразу получать данные и точное время пользователя.',
        parse_mode: 'Markdown'
      })
    });

    const json = await res.json();
    if (json.ok) {
      showToast('Тестовое сообщение успешно пришло в ваш Telegram! 🔥');
    } else {
      showToast('Ошибка Telegram: ' + (json.description || 'Неверный токен или chat ID'), 'error');
    }
  } catch (err) {
    showToast('Не удалось отправить сообщение в Telegram: ' + err.message, 'error');
  }
}

// Toast helper
function showToast(message, type = 'success') {
  const toast = document.getElementById('toast-notify');
  const msgEl = document.getElementById('toast-message');
  const iconEl = document.getElementById('toast-icon');
  if (!toast || !msgEl) return;

  toast.className = `toast ${type}`;
  msgEl.textContent = message;
  iconEl.textContent = type === 'success' ? '✓' : (type === 'error' ? '✕' : 'ℹ️');

  toast.classList.add('show');
  setTimeout(() => toast.classList.remove('show'), 3500);
}

// XSS Safety helper
function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}
