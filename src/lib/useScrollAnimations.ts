'use client';

import { useEffect } from 'react';
import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export default function useScrollAnimations() {
  useEffect(() => {
    const heroTitle = document.querySelector('.hero-title');
    const heroSubtitle = document.querySelector('.hero-subtitle');

    if (heroTitle) {
      gsap.to(heroTitle, {
        scrollTrigger: {
          trigger: '#hero',
          start: 'top top',
          end: '+=100%',
          scrub: true,
          pin: true,
        },
        scale: 0.5,
        y: '-30%',
      });
    }

    if (heroSubtitle) {
      gsap.fromTo(
        heroSubtitle,
        { opacity: 0, y: 50 },
        {
          opacity: 1,
          y: 0,
          scrollTrigger: {
            trigger: heroSubtitle,
            start: 'top 80%',
            end: 'top 60%',
            scrub: true,
          },
        },
      );
    }

    document
      .querySelectorAll<HTMLElement>('.parallax-section')
      .forEach((section) => {
        const img = section.querySelector('img');
        if (!img) return;
        gsap.fromTo(
          img,
          { y: 0 },
          {
            y: '20%',
            scrollTrigger: {
              trigger: section,
              start: 'top bottom',
              end: 'bottom top',
              scrub: true,
            },
          },
        );
      });

    gsap.to('#step2', {
      scrollTrigger: {
        trigger: '#how-it-works',
        start: 'top top+=100%',
        end: 'top top+=200%',
        scrub: true,
      },
      opacity: 1,
    });
    gsap.to('#step3', {
      scrollTrigger: {
        trigger: '#how-it-works',
        start: 'top top+=200%',
        end: 'top top+=300%',
        scrub: true,
      },
      opacity: 1,
    });

    return () => ScrollTrigger.getAll().forEach((st) => st.kill());
  }, []);
}
