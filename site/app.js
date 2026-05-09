const header = document.querySelector('[data-header]');
const navToggle = document.querySelector('.nav-toggle');
const navLinks = document.querySelectorAll('.global-nav a');
const revealTargets = document.querySelectorAll('.reveal');
const tabButtons = document.querySelectorAll('[role="tab"]');

const updateHeader = () => {
  header.classList.toggle('is-scrolled', window.scrollY > 20);
};

navToggle.addEventListener('click', () => {
  const isOpen = header.classList.toggle('is-open');
  navToggle.setAttribute('aria-expanded', String(isOpen));
});

navLinks.forEach((link) => {
  link.addEventListener('click', () => {
    header.classList.remove('is-open');
    navToggle.setAttribute('aria-expanded', 'false');
  });
});

const revealObserver = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add('is-visible');
        revealObserver.unobserve(entry.target);
      }
    });
  },
  { threshold: 0.14 }
);

revealTargets.forEach((target) => revealObserver.observe(target));

tabButtons.forEach((button) => {
  button.addEventListener('click', () => {
    const panel = document.getElementById(button.getAttribute('aria-controls'));

    tabButtons.forEach((tab) => {
      const tabPanel = document.getElementById(tab.getAttribute('aria-controls'));
      const isSelected = tab === button;
      tab.setAttribute('aria-selected', String(isSelected));
      tabPanel.hidden = !isSelected;
      tabPanel.classList.toggle('active', isSelected);
    });

    panel.focus?.();
  });
});

window.addEventListener('scroll', updateHeader, { passive: true });
updateHeader();
