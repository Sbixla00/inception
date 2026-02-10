// Display current time
function updateTimestamp() {
    const timestamp = document.querySelector('.timestamp');
    if (timestamp) {
        const now = new Date();
        const timeString = now.toLocaleString('en-US', { 
            year: 'numeric', 
            month: 'long', 
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
        timestamp.textContent = `Built with vanilla HTML, CSS, and JavaScript | ${timeString}`;
    }
}

// Add animation to service items on scroll
function animateOnScroll() {
    const items = document.querySelectorAll('.service-item, .isolation-item');
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '0';
                entry.target.style.transform = 'translateY(20px)';
                
                setTimeout(() => {
                    entry.target.style.transition = 'all 0.6s ease';
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }, 100);
                
                observer.unobserve(entry.target);
            }
        });
    }, {
        threshold: 0.1
    });
    
    items.forEach(item => observer.observe(item));
}

// Add click effect to tech badges
function addTechBadgeEffects() {
    const badges = document.querySelectorAll('.tech-badge');
    badges.forEach(badge => {
        badge.addEventListener('click', () => {
            badge.style.transform = 'scale(1.2)';
            setTimeout(() => {
                badge.style.transform = 'scale(1)';
            }, 200);
        });
    });
}

// Count up animation for service items
function countServices() {
    const serviceItems = document.querySelectorAll('.service-item');
    const count = serviceItems.length;
    
    // You could add a counter animation here if desired
    console.log(`Total services running: ${count}`);
}

// Initialize everything when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    updateTimestamp();
    animateOnScroll();
    addTechBadgeEffects();
    countServices();
    
    // Update timestamp every minute
    setInterval(updateTimestamp, 60000);
    
    console.log('🐳 Inception Project - Static Website Loaded');
    console.log('All services are containerized using Docker!');
});
