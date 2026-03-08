const PROJECTS = {
    'natures-pulse': {
        title: "Nature's Pulse",
        subtitle: 'Personal Animation / 2025',
        description: 'Organic motion study exploring branching forms, soft turbulence, and rhythmic light.',
        poster: 'assets/placeholder-poster.jpg',
        video: 'assets/placeholder-video.mp4'
    },
    'ethereal-flow': {
        title: 'Ethereal Flow',
        subtitle: 'Motion Design / 2025',
        description: 'A quieter atmospheric piece built around fluid silhouettes, bloom, and suspended movement.',
        poster: 'assets/placeholder-poster.jpg',
        video: 'assets/placeholder-video.mp4'
    },
    'abstract-life': {
        title: 'Abstract Life',
        subtitle: 'Experimental CGI / 2024',
        description: 'A more graphic study of living systems translated into bold abstract animation.',
        poster: 'assets/placeholder-poster.jpg',
        video: 'assets/placeholder-video.mp4'
    }
};

const ACTIVE_PROJECT_KEY = 'active-project-transition';
const INDEX_SCROLL_KEY = 'index-scroll-position';
const INDEX_RETURN_KEY = 'index-return-pending';
const PROJECT_ORDER = Object.keys(PROJECTS);

document.addEventListener('DOMContentLoaded', () => {
    hydrateProjectPage();
    restoreIndexScrollPosition();
    initNavVisibility();
    initHamburgerMenu();
    initAnchorScrolling();
    initRevealAnimations();
    initViewTransitions();
});

function initNavVisibility() {
    const nav = document.getElementById('main-nav');
    const landingSection = document.getElementById('landing');
    const scrollIndicator = document.querySelector('.scroll-indicator');

    if (!nav || !landingSection || !scrollIndicator) {
        return;
    }

    window.addEventListener('scroll', () => {
        const triggerPoint = landingSection.offsetHeight * 0.5;

        if (window.scrollY > triggerPoint) {
            nav.classList.add('visible');
            scrollIndicator.classList.add('hidden');
        } else {
            nav.classList.remove('visible');
            scrollIndicator.classList.remove('hidden');
        }
    });
}

function initHamburgerMenu() {
    const nav = document.getElementById('main-nav');
    const hamburger = document.querySelector('.hamburger');
    const navLinks = document.querySelector('.nav-links');

    if (!nav || !hamburger || !navLinks) {
        return;
    }

    function toggleMenu() {
        const isActive = hamburger.classList.contains('active');

        if (!isActive) {
            hamburger.classList.add('active');
            navLinks.classList.add('active');
            nav.classList.add('mobile-active');
            document.body.style.overflow = 'hidden';
            return;
        }

        hamburger.classList.remove('active');
        navLinks.classList.remove('active');
        nav.classList.remove('mobile-active');
        document.body.style.overflow = '';
    }

    hamburger.addEventListener('click', (event) => {
        event.stopPropagation();
        toggleMenu();
    });

    navLinks.addEventListener('click', () => {
        if (hamburger.classList.contains('active')) {
            toggleMenu();
        }
    });
}

function initAnchorScrolling() {
    const anchorLinks = document.querySelectorAll('a[href^="#"]');

    anchorLinks.forEach((anchor) => {
        anchor.addEventListener('click', (event) => {
            const targetId = anchor.getAttribute('href');
            const targetSection = targetId ? document.querySelector(targetId) : null;

            if (!targetSection) {
                return;
            }

            event.preventDefault();
            targetSection.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        });
    });
}

function initRevealAnimations() {
    const revealElements = document.querySelectorAll('.reveal');

    if (!revealElements.length) {
        return;
    }

    const revealObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach((entry) => {
            if (!entry.isIntersecting) {
                return;
            }

            if (entry.target.classList.contains('project-card')) {
                const projectCards = document.querySelectorAll('.project-card');
                const index = Array.from(projectCards).indexOf(entry.target);

                setTimeout(() => {
                    entry.target.classList.add('active');
                }, index * 150);
            } else {
                entry.target.classList.add('active');
            }

            observer.unobserve(entry.target);
        });
    }, {
        root: null,
        threshold: 0.15,
        rootMargin: '0px 0px -50px 0px'
    });

    revealElements.forEach((element) => {
        revealObserver.observe(element);
    });
}

function hydrateProjectPage() {
    if (document.body.dataset.page !== 'project') {
        return;
    }

    const projectSlug = getProjectSlug();
    const fallbackSlug = Object.keys(PROJECTS)[0];
    const activeSlug = PROJECTS[projectSlug] ? projectSlug : fallbackSlug;
    const project = PROJECTS[activeSlug];
    const navigation = getProjectNavigation(activeSlug);

    document.body.dataset.project = activeSlug;

    const title = document.querySelector('.project-title');
    const subtitle = document.querySelector('.project-subtitle');
    const copy = document.querySelector('.project-copy');
    const video = document.querySelector('.project-video');
    const videoSource = document.querySelector('.project-video-source');
    const backLink = document.querySelector('.back-link');
    const prevLink = document.querySelector('.project-nav-prev');
    const nextLink = document.querySelector('.project-nav-next');
    const prevName = document.querySelector('.project-nav-prev .project-nav-name');
    const nextName = document.querySelector('.project-nav-next .project-nav-name');

    if (title) {
        title.textContent = project.title;
    }

    if (subtitle) {
        subtitle.textContent = project.subtitle;
    }

    if (copy) {
        copy.textContent = project.description;
    }

    if (video) {
        video.poster = getAssetPath(project.poster);
    }

    if (video && videoSource) {
        videoSource.src = getAssetPath(project.video);
        video.load();
    }

    if (backLink) {
        backLink.href = '../';
    }

    if (prevLink) {
        prevLink.href = getProjectHref(navigation.prevSlug);
        prevLink.dataset.project = navigation.prevSlug;
        prevLink.style.backgroundImage = `linear-gradient(rgba(0, 0, 0, 0.18), rgba(0, 0, 0, 0.42)), url("${getAssetPath(PROJECTS[navigation.prevSlug].poster)}")`;
    }

    if (nextLink) {
        nextLink.href = getProjectHref(navigation.nextSlug);
        nextLink.dataset.project = navigation.nextSlug;
        nextLink.style.backgroundImage = `linear-gradient(rgba(0, 0, 0, 0.18), rgba(0, 0, 0, 0.42)), url("${getAssetPath(PROJECTS[navigation.nextSlug].poster)}")`;
    }

    if (prevName) {
        prevName.textContent = PROJECTS[navigation.prevSlug].title;
    }

    if (nextName) {
        nextName.textContent = PROJECTS[navigation.nextSlug].title;
    }

    document.title = `${project.title} | Paweł Grzelak`;
}

function initViewTransitions() {
    setSharedNavTransition();

    if (!supportsViewTransitions()) {
        return;
    }

    if (document.body.dataset.page === 'project') {
        prepareProjectPageTransition();
        return;
    }

    prepareIndexPageTransitions();
}

function setSharedNavTransition() {
    const logo = document.querySelector('.logo');

    if (logo) {
        logo.style.viewTransitionName = 'site-logo';
    }
}

function prepareIndexPageTransitions() {
    const storedProject = sessionStorage.getItem(ACTIVE_PROJECT_KEY);

    if (storedProject) {
        applyProjectTransitionNames(storedProject);
    }

    document.querySelectorAll('.project-card').forEach((card) => {
        card.addEventListener('click', () => {
            const projectSlug = card.dataset.project;

            if (!projectSlug) {
                return;
            }

            sessionStorage.setItem(INDEX_SCROLL_KEY, String(window.scrollY));
            sessionStorage.setItem(ACTIVE_PROJECT_KEY, projectSlug);
            applyProjectTransitionNames(projectSlug);
        });
    });
}

function prepareProjectPageTransition() {
    const projectSlug = document.body.dataset.project;

    if (!projectSlug) {
        return;
    }

    const expectedSlug = sessionStorage.getItem(ACTIVE_PROJECT_KEY);
    const activeSlug = expectedSlug || projectSlug;
    const mediaContainer = document.querySelector('.project-video-container');
    const projectTitle = document.querySelector('.project-title');
    const backLink = document.querySelector('.back-link');

    if (mediaContainer) {
        mediaContainer.style.viewTransitionName = `project-media-${activeSlug}`;
    }

    if (projectTitle) {
        projectTitle.style.viewTransitionName = `project-title-${activeSlug}`;
    }

    if (backLink) {
        backLink.addEventListener('click', () => {
            sessionStorage.setItem(INDEX_RETURN_KEY, 'true');
            sessionStorage.setItem(ACTIVE_PROJECT_KEY, projectSlug);
        });
    }

    document.querySelectorAll('.project-nav-link').forEach((link) => {
        link.addEventListener('click', () => {
            const targetSlug = link.dataset.project;

            if (targetSlug) {
                sessionStorage.setItem(ACTIVE_PROJECT_KEY, targetSlug);
            }
        });
    });
}

function applyProjectTransitionNames(activeSlug) {
    document.querySelectorAll('.project-card').forEach((card) => {
        const isActive = card.dataset.project === activeSlug;
        const title = card.querySelector('h3');

        card.style.viewTransitionName = isActive ? `project-media-${activeSlug}` : 'none';

        if (title) {
            title.style.viewTransitionName = isActive ? `project-title-${activeSlug}` : 'none';
        }
    });
}

function supportsViewTransitions() {
    return typeof document.startViewTransition === 'function';
}

function getProjectNavigation(activeSlug) {
    const currentIndex = PROJECT_ORDER.indexOf(activeSlug);
    const safeIndex = currentIndex === -1 ? 0 : currentIndex;
    const prevIndex = (safeIndex - 1 + PROJECT_ORDER.length) % PROJECT_ORDER.length;
    const nextIndex = (safeIndex + 1) % PROJECT_ORDER.length;

    return {
        prevSlug: PROJECT_ORDER[prevIndex],
        nextSlug: PROJECT_ORDER[nextIndex]
    };
}

function getProjectHref(projectSlug) {
    if (document.body.dataset.page === 'project') {
        return `../${projectSlug}/`;
    }

    return `${projectSlug}/`;
}

function getProjectSlug() {
    const bodySlug = document.body.dataset.project;

    if (bodySlug) {
        return bodySlug;
    }

    const params = new URLSearchParams(window.location.search);
    const querySlug = params.get('project');

    if (querySlug) {
        return querySlug;
    }

    const pathSegments = window.location.pathname.split('/').filter(Boolean);
    return pathSegments[pathSegments.length - 1] || '';
}

function getAssetPath(assetPath) {
    if (document.body.dataset.page === 'project') {
        return `../${assetPath}`;
    }

    return assetPath;
}

function restoreIndexScrollPosition() {
    if (document.body.dataset.page === 'project') {
        return;
    }

    const shouldRestore =
        sessionStorage.getItem(INDEX_RETURN_KEY) === 'true' ||
        getNavigationType() === 'back_forward';
    const savedScrollY = Number(sessionStorage.getItem(INDEX_SCROLL_KEY));

    if (!shouldRestore || Number.isNaN(savedScrollY)) {
        return;
    }

    sessionStorage.removeItem(INDEX_RETURN_KEY);
    document.documentElement.classList.add('disable-smooth-scroll');

    requestAnimationFrame(() => {
        window.scrollTo(0, savedScrollY);

        requestAnimationFrame(() => {
            document.documentElement.classList.remove('disable-smooth-scroll');
        });
    });
}

function getNavigationType() {
    const navigationEntry = performance.getEntriesByType('navigation')[0];
    return navigationEntry ? navigationEntry.type : '';
}
