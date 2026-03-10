/**
 * OneConnect Member Sign-In Page JavaScript
 * Handles form validation, country selection, phone formatting, and social auth
 */

// Country data with validation rules
const countries = {
    'GB': {
        name: 'United Kingdom',
        code: '+44',
        flag: 'assets/images/uk_flag.svg',
        minLength: 10,
        maxLength: 11,
        placeholder: '+44 (000) 000-0000'
    },
    'PK': {
        name: 'Pakistan',
        code: '+92',
        flag: '🇵🇰',
        minLength: 10,
        maxLength: 11,
        placeholder: '+92 (000) 000-0000'
    },
    'US': {
        name: 'United States',
        code: '+1',
        flag: '🇺🇸',
        minLength: 10,
        maxLength: 10,
        placeholder: '+1 (000) 000-0000'
    },
    'IN': {
        name: 'India',
        code: '+91',
        flag: '🇮🇳',
        minLength: 10,
        maxLength: 10,
        placeholder: '+91 (000) 000-0000'
    }
};

// Global state
let currentCountry = 'GB';
let isPhoneFocused = false;

// DOM Elements
const elements = {
    countrySelector: document.getElementById('countrySelector'),
    flagIcon: document.getElementById('flagIcon'),
    countryCode: document.getElementById('countryCode'),
    phoneInput: document.getElementById('phoneInput'),
    helpButton: document.getElementById('helpButton'),
    continueButton: document.getElementById('continueButton'),
    modalOverlay: document.getElementById('modalOverlay'),
    countryModal: document.getElementById('countryModal'),
    modalClose: document.getElementById('modalClose'),
    helpModalOverlay: document.getElementById('helpModalOverlay'),
    helpModal: document.getElementById('helpModal'),
    helpModalClose: document.getElementById('helpModalClose'),
    socialButtons: {
        google: document.getElementById('googleButton'),
        apple: document.getElementById('appleButton'),
        email: document.getElementById('emailButton')
    }
};

/**
 * Initialize the application
 */
function init() {
    setupEventListeners();
    updateCountryDisplay();
    updatePhonePlaceholder();
}

/**
 * Set up all event listeners
 */
function setupEventListeners() {
    // Country selector
    elements.countrySelector.addEventListener('click', openCountryModal);
    
    // Phone input
    elements.phoneInput.addEventListener('input', handlePhoneInput);
    elements.phoneInput.addEventListener('focus', handlePhoneFocus);
    elements.phoneInput.addEventListener('blur', handlePhoneBlur);
    
    // Help button
    elements.helpButton.addEventListener('click', openHelpModal);
    
    // Continue button
    elements.continueButton.addEventListener('click', handleContinue);
    
    // Modal controls
    elements.modalClose.addEventListener('click', closeCountryModal);
    elements.modalOverlay.addEventListener('click', handleModalOverlayClick);
    elements.helpModalClose.addEventListener('click', closeHelpModal);
    elements.helpModalOverlay.addEventListener('click', handleHelpModalOverlayClick);
    
    // Country options
    const countryOptions = document.querySelectorAll('.country-option');
    countryOptions.forEach(option => {
        option.addEventListener('click', () => selectCountry(option.dataset.code));
    });
    
    // Social buttons
    elements.socialButtons.google.addEventListener('click', () => handleSocialSignIn('Google'));
    elements.socialButtons.apple.addEventListener('click', () => handleSocialSignIn('Apple'));
    elements.socialButtons.email.addEventListener('click', () => handleSocialSignIn('Email'));
    
    // Keyboard navigation
    document.addEventListener('keydown', handleKeyDown);
}

/**
 * Handle phone input changes and formatting
 */
function handlePhoneInput(event) {
    const value = event.target.value;
    const formatted = formatPhoneNumber(value, currentCountry);
    
    if (formatted !== value) {
        const cursorPos = event.target.selectionStart;
        event.target.value = formatted;
        
        // Maintain cursor position
        const newPos = cursorPos + (formatted.length - value.length);
        event.target.setSelectionRange(newPos, newPos);
    }
}

/**
 * Handle phone input focus
 */
function handlePhoneFocus() {
    isPhoneFocused = true;
    const container = document.querySelector('.phone-input-container');
    container.classList.add('focused');
}

/**
 * Handle phone input blur
 */
function handlePhoneBlur() {
    isPhoneFocused = false;
    const container = document.querySelector('.phone-input-container');
    container.classList.remove('focused');
}

/**
 * Format phone number based on country
 */
function formatPhoneNumber(phoneNumber, countryCode) {
    // Remove all non-digit characters
    const cleanNumber = phoneNumber.replace(/\D/g, '');
    
    if (!cleanNumber) return '';
    
    switch (countryCode) {
        case 'GB':
            return formatUKNumber(cleanNumber);
        case 'US':
            return formatUSNumber(cleanNumber);
        case 'PK':
        case 'IN':
            return formatGenericNumber(cleanNumber);
        default:
            return cleanNumber;
    }
}

/**
 * Format UK phone number
 */
function formatUKNumber(number) {
    if (number.length <= 3) return number;
    if (number.length <= 6) return `${number.slice(0, 3)} ${number.slice(3)}`;
    if (number.length <= 10) return `${number.slice(0, 3)} ${number.slice(3, 6)} ${number.slice(6)}`;
    return `${number.slice(0, 4)} ${number.slice(4, 7)} ${number.slice(7, 11)}`;
}

/**
 * Format US phone number
 */
function formatUSNumber(number) {
    if (number.length <= 3) return `(${number}`;
    if (number.length <= 6) return `(${number.slice(0, 3)}) ${number.slice(3)}`;
    return `(${number.slice(0, 3)}) ${number.slice(3, 6)}-${number.slice(6, 10)}`;
}

/**
 * Format generic phone number
 */
function formatGenericNumber(number) {
    if (number.length <= 3) return number;
    if (number.length <= 7) return `${number.slice(0, 3)} ${number.slice(3)}`;
    return `${number.slice(0, 3)} ${number.slice(3, 7)} ${number.slice(7)}`;
}

/**
 * Validate phone number
 */
function isValidPhoneNumber(phoneNumber, countryCode) {
    const cleanNumber = phoneNumber.replace(/\D/g, '');
    const country = countries[countryCode];
    
    if (!country) return false;
    
    return cleanNumber.length >= country.minLength && cleanNumber.length <= country.maxLength;
}

/**
 * Open country selection modal
 */
function openCountryModal() {
    elements.modalOverlay.classList.add('active');
    document.body.style.overflow = 'hidden';
}

/**
 * Close country selection modal
 */
function closeCountryModal() {
    elements.modalOverlay.classList.remove('active');
    document.body.style.overflow = '';
}

/**
 * Handle modal overlay click
 */
function handleModalOverlayClick(event) {
    if (event.target === elements.modalOverlay) {
        closeCountryModal();
    }
}

/**
 * Open help modal
 */
function openHelpModal() {
    elements.helpModalOverlay.classList.add('active');
    document.body.style.overflow = 'hidden';
}

/**
 * Close help modal
 */
function closeHelpModal() {
    elements.helpModalOverlay.classList.remove('active');
    document.body.style.overflow = '';
}

/**
 * Handle help modal overlay click
 */
function handleHelpModalOverlayClick(event) {
    if (event.target === elements.helpModalOverlay) {
        closeHelpModal();
    }
}

/**
 * Select a country
 */
function selectCountry(countryCode) {
    if (countries[countryCode]) {
        currentCountry = countryCode;
        updateCountryDisplay();
        updatePhonePlaceholder();
        closeCountryModal();
        
        // Clear and refocus phone input
        elements.phoneInput.value = '';
        elements.phoneInput.focus();
    }
}

/**
 * Update country display
 */
function updateCountryDisplay() {
    const country = countries[currentCountry];
    
    elements.countryCode.textContent = currentCountry;
    
    if (country.flag.startsWith('assets/')) {
        elements.flagIcon.src = country.flag;
        elements.flagIcon.alt = `${country.name} Flag`;
        elements.flagIcon.style.display = 'block';
    } else {
        // Handle emoji flags
        elements.flagIcon.style.display = 'none';
        // Create emoji span if needed
        let emojiSpan = elements.countrySelector.querySelector('.emoji-flag-display');
        if (!emojiSpan) {
            emojiSpan = document.createElement('span');
            emojiSpan.className = 'emoji-flag-display';
            elements.countrySelector.insertBefore(emojiSpan, elements.countryCode);
        }
        emojiSpan.textContent = country.flag;
        emojiSpan.style.fontSize = '18px';
        emojiSpan.style.marginRight = '8px';
    }
}

/**
 * Update phone input placeholder
 */
function updatePhonePlaceholder() {
    const country = countries[currentCountry];
    elements.phoneInput.placeholder = country.placeholder;
}

/**
 * Handle continue button click
 */
function handleContinue() {
    const phoneNumber = elements.phoneInput.value.trim();
    
    if (!phoneNumber) {
        showNotification('Please enter your phone number', 'error');
        elements.phoneInput.focus();
        return;
    }
    
    if (!isValidPhoneNumber(phoneNumber, currentCountry)) {
        const country = countries[currentCountry];
        showNotification(`Please enter a valid phone number for ${country.name}`, 'error');
        elements.phoneInput.focus();
        return;
    }
    
    // Success
    const country = countries[currentCountry];
    showNotification(`Verification code will be sent to ${country.code} ${phoneNumber}`, 'success');
    
    // Simulate API call
    elements.continueButton.disabled = true;
    elements.continueButton.innerHTML = '<span>Sending...</span>';
    
    setTimeout(() => {
        elements.continueButton.disabled = false;
        elements.continueButton.innerHTML = '<span>Continue</span><img src="assets/images/arrow_icon.svg" alt="Arrow" class="arrow-icon">';
        
        // Here you would typically navigate to OTP verification page
        console.log('Navigate to OTP verification with:', {
            country: currentCountry,
            phone: phoneNumber,
            countryCode: country.code
        });
    }, 2000);
}

/**
 * Handle social sign-in
 */
function handleSocialSignIn(provider) {
    showNotification(`Signing in with ${provider}...`, 'info');
    
    // Simulate social auth
    console.log(`Social sign-in with ${provider}`);
    
    // Here you would integrate with actual social auth providers
    switch (provider) {
        case 'Google':
            // Integrate with Google Sign-In SDK
            break;
        case 'Apple':
            // Integrate with Apple Sign-In SDK
            break;
        case 'Email':
            // Navigate to email sign-in form
            break;
    }
}

/**
 * Show notification
 */
function showNotification(message, type = 'info') {
    // Remove existing notification
    const existing = document.querySelector('.notification');
    if (existing) {
        existing.remove();
    }
    
    // Create notification
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    
    // Style notification
    Object.assign(notification.style, {
        position: 'fixed',
        top: '20px',
        left: '50%',
        transform: 'translateX(-50%)',
        backgroundColor: type === 'error' ? '#ff4444' : type === 'success' ? '#44ff44' : '#4444ff',
        color: 'white',
        padding: '12px 24px',
        borderRadius: '8px',
        boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
        zIndex: '10000',
        fontSize: '14px',
        maxWidth: '90%',
        textAlign: 'center',
        opacity: '0',
        transition: 'opacity 0.3s ease'
    });
    
    document.body.appendChild(notification);
    
    // Animate in
    setTimeout(() => {
        notification.style.opacity = '1';
    }, 10);
    
    // Remove after 4 seconds
    setTimeout(() => {
        notification.style.opacity = '0';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.remove();
            }
        }, 300);
    }, 4000);
}

/**
 * Handle keyboard navigation
 */
function handleKeyDown(event) {
    switch (event.key) {
        case 'Escape':
            closeCountryModal();
            closeHelpModal();
            break;
        case 'Enter':
            if (elements.modalOverlay.classList.contains('active')) {
                // Handle country selection if modal is open
                const focused = document.activeElement;
                if (focused && focused.classList.contains('country-option')) {
                    selectCountry(focused.dataset.code);
                }
            } else if (document.activeElement === elements.phoneInput) {
                handleContinue();
            }
            break;
    }
}

/**
 * Utility function to debounce function calls
 */
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

/**
 * Handle window resize for responsive adjustments
 */
function handleResize() {
    // Adjust modal positioning if needed
    const modals = document.querySelectorAll('.country-modal, .help-modal');
    modals.forEach(modal => {
        if (window.innerHeight < 600) {
            modal.style.maxHeight = '70vh';
        } else {
            modal.style.maxHeight = '80vh';
        }
    });
}

// Add resize listener with debounce
window.addEventListener('resize', debounce(handleResize, 150));

/**
 * Initialize the application when DOM is loaded
 */
document.addEventListener('DOMContentLoaded', init);

/**
 * Handle page visibility change (for analytics/tracking)
 */
document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'hidden') {
        console.log('Page hidden');
    } else {
        console.log('Page visible');
    }
});

/**
 * Export functions for testing (if needed)
 */
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        formatPhoneNumber,
        isValidPhoneNumber,
        countries
    };
}