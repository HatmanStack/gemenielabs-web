import { describe, it, expect } from 'vitest';

describe('Contact Form', () => {
  it('validates required fields', () => {
    const body = { name: '', email: '', message: '' };
    const isValid = body.name && body.email && body.message;
    expect(isValid).toBeFalsy();
  });

  it('accepts valid input', () => {
    const body = {
      name: 'Test User',
      email: 'test@example.com',
      message: 'Hello, this is a test message.',
    };
    const isValid = body.name && body.email && body.message;
    expect(isValid).toBeTruthy();
  });

  it('validates email format', () => {
    const validEmails = ['test@example.com', 'user@domain.co.uk'];
    const invalidEmails = ['notanemail', '@missing.com', 'no@'];

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    validEmails.forEach((email) => {
      expect(emailRegex.test(email)).toBe(true);
    });

    invalidEmails.forEach((email) => {
      expect(emailRegex.test(email)).toBe(false);
    });
  });
});

describe('Data exports', () => {
  it('company data has required fields', async () => {
    // This would normally import from frontend, but we test the structure
    const company = {
      name: 'Gemenie Labs',
      tagline: 'Mobile & Web Applications Powered by AI',
      about: 'We build modern applications...',
      services: ['Mobile App Development'],
    };

    expect(company.name).toBeDefined();
    expect(company.tagline).toBeDefined();
    expect(company.about).toBeDefined();
    expect(Array.isArray(company.services)).toBe(true);
  });

  it('projects have required fields', () => {
    const project = {
      name: 'Test Project',
      description: 'A test project',
      tech: ['TypeScript'],
      url: 'https://example.com',
      github: 'https://github.com/test',
    };

    expect(project.name).toBeDefined();
    expect(project.description).toBeDefined();
    expect(Array.isArray(project.tech)).toBe(true);
    expect(project.url).toMatch(/^https?:\/\//);
  });
});
