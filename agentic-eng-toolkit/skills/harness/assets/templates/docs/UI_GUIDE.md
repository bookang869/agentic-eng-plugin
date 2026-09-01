# UI Design Guide

## Design Principles
1. {Principle 1 — e.g. "Should look like a tool. A daily-use dashboard, not a marketing page."}
2. {Principle 2}
3. {Principle 3}

## AI Slop Anti-Patterns — Don't Do These
| Prohibited | Reason |
|-----------|------|
| backdrop-filter: blur() | Glass morphism is the most common tell of an AI template |
| gradient-text (gradient background text) | The #1 feature of AI-generated SaaS landing pages |
| "Powered by AI" badge | Decoration, not a feature. No value to the user |
| box-shadow glow animations | Neon glow = AI slop |
| purple/indigo brand colors | The "AI = purple" cliché |
| identical rounded-2xl on every card | Uniform rounded corners feel templated |
| background gradient orbs (blurred circular blobs) | A decoration found on every AI landing page |

## Colors
### Background
| Purpose | Value |
|------|------|
| Page | {e.g. #0a0a0a} |
| Card | {e.g. #141414} |

### Text
| Purpose | Value |
|------|------|
| Primary text | {e.g. text-white} |
| Body | {e.g. text-neutral-300} |
| Secondary | {e.g. text-neutral-400} |
| Disabled | {e.g. text-neutral-500} |

### Data/Semantic Colors
| Purpose | Value |
|------|------|
| {Positive/success} | {e.g. #22c55e} |
| {Negative/error} | {e.g. #ef4444} |
| {Neutral/default} | {e.g. #525252} |

## Components
### Card
```
{e.g. rounded-lg bg-[#141414] border border-neutral-800 p-6}
```

### Button
```
Primary: {e.g. rounded-lg bg-white text-black hover:bg-neutral-200}
Text:    {e.g. text-neutral-500 hover:text-neutral-300}
```

### Input Field
```
{e.g. rounded-lg bg-neutral-900 border border-neutral-800 px-4 py-3}
```

## Layout
- Overall width: {e.g. max-w-5xl}
- Alignment: {e.g. left-aligned by default. No centered alignment}
- Spacing: {e.g. gap-3~4, space-y-8 between sections}

## Typography
| Purpose | Style |
|------|--------|
| Page title | {e.g. text-4xl font-semibold text-white} |
| Card title | {e.g. text-sm font-medium text-neutral-400} |
| Body | {e.g. text-sm text-neutral-300 leading-relaxed} |

## Animation
- {List only the animations that are allowed. e.g. fade-in (0.4s), slide-up (0.5s)}
- {All other animations are prohibited}

## Icons
- {e.g. inline SVG, strokeWidth 1.5}
- {e.g. do not wrap in an icon container (rounded background box)}
