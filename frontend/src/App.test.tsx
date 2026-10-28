import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import App from './App';

describe('App shell', () => {
  it('renders a main landmark', () => {
    render(<App />);

    expect(screen.getByRole('main')).toBeInTheDocument();
  });

  it('names the app in a level 1 heading', () => {
    render(<App />);

    expect(screen.getByRole('heading', { level: 1, name: 'Prepwise' })).toBeInTheDocument();
  });

  it('shows the tagline', () => {
    render(<App />);

    expect(screen.getByText('Weekly Maths and English practice for the 11+.')).toBeInTheDocument();
  });
});
