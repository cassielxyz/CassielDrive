document.addEventListener('DOMContentLoaded', () => {
    // 1. Scroll Animations (Intersection Observer)
    const observerOptions = {
        root: null,
        rootMargin: '0px',
        threshold: 0.15
    };

    const scrollObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('is-visible');
            }
        });
    }, observerOptions);

    document.querySelectorAll('.animate-on-scroll').forEach((elem) => {
        scrollObserver.observe(elem);
    });

    // 2. Accordion Logic (For Docs Section)
    const accordions = document.querySelectorAll('.accordion-header');
    
    accordions.forEach(acc => {
        acc.addEventListener('click', function() {
            // Toggle chevron rotation
            const icon = this.querySelector('i');
            if(icon.style.transform === 'rotate(180deg)') {
                icon.style.transform = 'rotate(0deg)';
            } else {
                icon.style.transform = 'rotate(180deg)';
            }

            // Toggle height of content
            const content = this.nextElementSibling;
            if (content.style.maxHeight && content.style.maxHeight !== '0px') {
                content.style.maxHeight = '0px';
                content.style.paddingBottom = '0px';
            } else {
                content.style.maxHeight = content.scrollHeight + 40 + "px";
                content.style.paddingBottom = '20px';
            }
        });
    });

    // 3. Sticky Download Bar Logic
    const downloadSection = document.getElementById('download');
    const stickyBar = document.getElementById('stickyDownload');
    
    if (downloadSection && stickyBar) {
        window.addEventListener('scroll', () => {
            const downloadRect = downloadSection.getBoundingClientRect();
            // Show sticky bar only when the user has scrolled past the hero section
            // AND the main download section is NOT currently visible in the viewport.
            
            const scrollThreshold = window.innerHeight; // Passed Hero
            
            if (window.scrollY > scrollThreshold && downloadRect.top > window.innerHeight) {
                stickyBar.classList.add('visible');
            } else {
                stickyBar.classList.remove('visible');
            }
        });
    }

    // 4. Smooth Anchor Scrolling
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const targetId = this.getAttribute('href');
            if(targetId === '#') return;
            
            const targetElement = document.querySelector(targetId);
            if(targetElement) {
                const headerOffset = 80;
                const elementPosition = targetElement.getBoundingClientRect().top;
                const offsetPosition = elementPosition + window.pageYOffset - headerOffset;
  
                window.scrollTo({
                    top: offsetPosition,
                    behavior: "smooth"
                });
            }
        });
    });
});