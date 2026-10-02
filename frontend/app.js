'use strict';
// Plain-JS state only (no Redux or other libraries). `registrations` lives in memory for this prototype;
// swap the push() below for a fetch() POST once the backend exists.
const state = { filter: 'all', registrations: [] };

const $ = (sel, root = document) => root.querySelector(sel);
const $$ = (sel, root = document) => [...root.querySelectorAll(sel)];
const cards = $$('.event-card');
const form = $('#reg-form');
const status = $('#form-status');

function renderSeats(card) {
  const n = Number(card.dataset.seats);
  const pill = $('.seats', card);
  const btn = $('.register-btn', card);
  pill.className = 'pill seats ' + (n === 0 ? 'pill-lock' : n <= 5 ? 'pill-warn' : 'pill-ok');
  pill.textContent = n === 0 ? 'Event full' : n <= 5 ? `Only ${n} seats left` : `${n} seats left`;
  if (n === 0) { btn.disabled = true; btn.textContent = 'Event full'; btn.removeAttribute('aria-label'); }
  $(`#eventId option[value="${card.dataset.id}"]`).disabled = n === 0;
}

function applyFilter() {
  let shown = 0;
  cards.forEach(card => {
    const visible = state.filter === 'all' || card.dataset.category === state.filter;
    card.hidden = !visible;
    if (visible) shown++;
  });
  $$('.filter').forEach(b => b.setAttribute('aria-pressed', String(b.dataset.filter === state.filter)));
  $('#result-count').textContent = `Showing ${shown} of ${cards.length} events`;
}

const rules = {
  fullName: v => v.trim().length >= 2 || 'Enter your full name.',
  studentEmail: v => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v.trim()) || 'Enter a valid email address, like name@school.edu.ph.',
  program: v => v !== '' || 'Choose your program.',
  eventId: v => v !== '' || 'Choose an event.',
  consent: v => v !== '' || 'Agree to share your details to continue.',
};

function setError(field, msg) {
  const out = $(`#${field.id}-error`);
  out.textContent = msg; out.hidden = false;
  field.setAttribute('aria-invalid', 'true');
}
function clearError(field) {
  const out = $(`#${field.id}-error`);
  out.textContent = ''; out.hidden = true;
  field.removeAttribute('aria-invalid');
}

$$('.filter').forEach(b => b.addEventListener('click', () => { state.filter = b.dataset.filter; applyFilter(); }));

$$('.register-btn').forEach(b => b.addEventListener('click', () => {
  const field = $('#eventId');
  field.value = b.closest('.event-card').dataset.id;
  clearError(field);
  const calm = matchMedia('(prefers-reduced-motion: reduce)').matches;
  $('#register').scrollIntoView({ behavior: calm ? 'auto' : 'smooth' });
  $('#fullName').focus({ preventScroll: true });
}));

['input', 'change'].forEach(evt => form.addEventListener(evt, e => {
  if (e.target.hasAttribute('aria-invalid')) clearError(e.target);
}));

form.addEventListener('submit', e => {
  e.preventDefault();
  status.textContent = '';
  let firstBad = null;

  Object.keys(rules).forEach(id => {
    const field = document.getElementById(id);
    const value = field.type === 'checkbox' ? (field.checked ? 'yes' : '') : field.value;
    const result = rules[id](value);
    if (result === true) clearError(field);
    else { setError(field, result); firstBad = firstBad || field; }
  });

  const email = form.studentEmail.value.trim().toLowerCase();
  const eventId = form.eventId.value;
  if (!firstBad && state.registrations.some(r => r.email === email && r.eventId === eventId)) {
    setError(form.studentEmail, 'This email is already registered for that event.');
    firstBad = form.studentEmail;
  }
  if (firstBad) { firstBad.focus(); return; }

  const card = cards.find(c => c.dataset.id === eventId);
  card.dataset.seats = Number(card.dataset.seats) - 1;
  state.registrations.push({ name: form.fullName.value.trim(), email, program: form.program.value, eventId, at: new Date().toISOString() });
  renderSeats(card);

  status.textContent = `You are registered for ${$('h3', card).textContent}. A confirmation will be sent to ${email}.`;
  form.reset();
  status.focus();
});

cards.forEach(renderSeats);
applyFilter();
