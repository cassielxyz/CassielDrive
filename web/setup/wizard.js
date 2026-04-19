// ── Cassiel Drive Setup Wizard — Logic ──

const TOTAL_STEPS = 8;
let currentStep = 0;

// ── Initialize ──
document.addEventListener('DOMContentLoaded', () => {
  buildProgressSteps();
  updateProgress();
});

// ── Step Navigation ──
function nextStep() {
  if (currentStep < TOTAL_STEPS - 1) {
    document.querySelector(`.step[data-step="${currentStep}"]`).classList.remove('active');
    currentStep++;
    document.querySelector(`.step[data-step="${currentStep}"]`).classList.add('active');
    updateProgress();
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
}

function prevStep() {
  if (currentStep > 0) {
    document.querySelector(`.step[data-step="${currentStep}"]`).classList.remove('active');
    currentStep--;
    document.querySelector(`.step[data-step="${currentStep}"]`).classList.add('active');
    updateProgress();
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
}

function goToStep(step) {
  document.querySelector(`.step[data-step="${currentStep}"]`).classList.remove('active');
  currentStep = step;
  document.querySelector(`.step[data-step="${currentStep}"]`).classList.add('active');
  updateProgress();
  window.scrollTo({ top: 0, behavior: 'smooth' });
}

// ── Progress Bar ──
function buildProgressSteps() {
  const container = document.getElementById('progressSteps');
  const labels = ['Welcome', 'Project', 'APIs', 'Consent', 'Users', 'Credentials', 'Validate', 'Done'];
  labels.forEach((label, i) => {
    const span = document.createElement('span');
    span.className = 'progress-step';
    span.textContent = label;
    span.onclick = () => { if (i <= currentStep) goToStep(i); };
    span.style.cursor = 'pointer';
    container.appendChild(span);
  });
}

function updateProgress() {
  const fill = document.getElementById('progressFill');
  const percentage = (currentStep / (TOTAL_STEPS - 1)) * 100;
  fill.style.width = percentage + '%';

  const steps = document.querySelectorAll('.progress-step');
  steps.forEach((step, i) => {
    step.classList.remove('active', 'done');
    if (i === currentStep) step.classList.add('active');
    else if (i < currentStep) step.classList.add('done');
  });
}

// ── Copy to Clipboard ──
function copyText(text, btn) {
  if (!text) return;
  navigator.clipboard.writeText(text).then(() => {
    const original = btn.textContent;
    btn.textContent = '✓ Copied';
    btn.classList.add('copied');
    setTimeout(() => {
      btn.textContent = original;
      btn.classList.remove('copied');
    }, 2000);
  }).catch(() => {
    // Fallback for older browsers
    const textarea = document.createElement('textarea');
    textarea.value = text;
    document.body.appendChild(textarea);
    textarea.select();
    document.execCommand('copy');
    document.body.removeChild(textarea);
    btn.textContent = '✓ Copied';
    btn.classList.add('copied');
    setTimeout(() => {
      btn.textContent = 'Copy';
      btn.classList.remove('copied');
    }, 2000);
  });
}

// ── Email Validation ──
function validateEmail() {
  const input = document.getElementById('testEmail');
  const result = document.getElementById('emailResult');
  const email = input.value.trim();

  if (!email) {
    result.textContent = '';
    result.style.color = '';
    return;
  }

  const gmailRegex = /^[a-z0-9._%+-]+@gmail\.com$/i;
  const genericEmailRegex = /^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$/i;

  if (gmailRegex.test(email)) {
    if (email !== email.toLowerCase()) {
      result.textContent = '⚠️ Use lowercase: ' + email.toLowerCase();
      result.style.color = 'var(--warning)';
    } else {
      result.textContent = '✓ Valid Gmail — add this as a test user';
      result.style.color = 'var(--success)';
    }
  } else if (genericEmailRegex.test(email)) {
    result.textContent = '✓ Valid email — make sure to add as a test user';
    result.style.color = 'var(--success)';
  } else {
    result.textContent = '✗ Invalid email format';
    result.style.color = 'var(--error)';
  }
}

// ── Credential Validation ──
function validateCredentials() {
  const clientId = document.getElementById('clientIdInput').value.trim();
  const clientSecret = document.getElementById('clientSecretInput').value.trim();
  const clientIdHint = document.getElementById('clientIdHint');
  const clientSecretHint = document.getElementById('clientSecretHint');
  const validationBox = document.getElementById('credentialValidation');
  const qrSection = document.getElementById('qrSection');

  let clientIdValid = false;
  let clientSecretValid = false;

  // Validate Client ID
  if (!clientId) {
    clientIdHint.textContent = '';
    clientIdHint.className = 'field-hint';
  } else if (clientId.endsWith('.apps.googleusercontent.com')) {
    clientIdHint.textContent = '✓ Valid Client ID format';
    clientIdHint.className = 'field-hint valid';
    clientIdValid = true;
  } else {
    clientIdHint.textContent = '✗ Must end with .apps.googleusercontent.com';
    clientIdHint.className = 'field-hint invalid';
  }

  // Validate Client Secret
  if (!clientSecret) {
    clientSecretHint.textContent = '';
    clientSecretHint.className = 'field-hint';
  } else if (clientSecret.startsWith('GOCSPX-') && clientSecret.length > 20) {
    clientSecretHint.textContent = '✓ Valid Client Secret format';
    clientSecretHint.className = 'field-hint valid';
    clientSecretValid = true;
  } else if (clientSecret.length > 10) {
    clientSecretHint.textContent = '⚠ Unusual format but may still work';
    clientSecretHint.className = 'field-hint valid';
    clientSecretValid = true;
  } else {
    clientSecretHint.textContent = '✗ Client Secret seems too short';
    clientSecretHint.className = 'field-hint invalid';
  }

  // Overall validation
  if (clientIdValid && clientSecretValid) {
    validationBox.textContent = '✓ Both credentials look valid! Paste them in Cassiel Drive Settings.';
    validationBox.className = 'validation-box valid';
    // Show QR code section
    qrSection.style.display = 'block';
    generateQR(clientId, clientSecret);
  } else if (clientId || clientSecret) {
    if (!clientIdValid && clientId) {
      validationBox.textContent = '✗ Client ID format is incorrect.';
      validationBox.className = 'validation-box invalid';
    } else if (!clientSecretValid && clientSecret) {
      validationBox.textContent = '✗ Client Secret format is incorrect.';
      validationBox.className = 'validation-box invalid';
    } else {
      validationBox.className = 'validation-box';
    }
    qrSection.style.display = 'none';
  } else {
    validationBox.className = 'validation-box';
    qrSection.style.display = 'none';
  }
}

// ── QR Code Generation (simple text-based, no library) ──
function generateQR(clientId, clientSecret) {
  const qrDiv = document.getElementById('qrCode');
  // Create a simple visual representation with the data
  // Since we can't use a real QR library in plain JS without deps,
  // we'll show a structured data display for manual entry
  const data = `cassiel://${clientId}|${clientSecret}`;

  qrDiv.innerHTML = `
    <div style="text-align:center; color:#333; font-size:12px; padding:8px;">
      <div style="font-weight:700; margin-bottom:8px; color:#25A7DA;">📋 Credentials Ready</div>
      <div style="word-break:break-all; font-family:monospace; font-size:9px; line-height:1.4; max-height:140px; overflow:auto;">
        <div style="margin-bottom:4px;"><strong>ID:</strong> ${clientId.substring(0, 20)}...</div>
        <div><strong>Key:</strong> ${clientSecret.substring(0, 15)}...</div>
      </div>
      <div style="margin-top:8px; font-size:10px; color:#999;">Copy & paste into app Settings</div>
    </div>
  `;
}
