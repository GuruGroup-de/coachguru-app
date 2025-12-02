# CoachGuru Theme Usage Guidelines

This document outlines the proper usage of CoachGuru brand colors and theme elements.

---

## 🎨 Color Palette

### Primary Colors

#### #0b69ff - Primary Blue
- **Usage**: Primary buttons, links, highlights, main brand elements
- **RGB**: `11, 105, 255`
- **Best for**: Call-to-action buttons, active states, primary navigation

#### #00c2ff - Secondary Blue
- **Usage**: Secondary elements, hover states, accents
- **RGB**: `0, 194, 255`
- **Best for**: Secondary buttons, gradients, highlights

### Dark Colors

#### #050816 - Dark
- **Usage**: Text on light backgrounds, dark mode backgrounds
- **RGB**: `5, 8, 22`
- **Best for**: Headings, body text, dark backgrounds

#### #1a2a6c - Dark Blue
- **Usage**: Darker accents, depth, shadows
- **RGB**: `26, 42, 108`
- **Best for**: Dark mode elements, depth effects, shadows

---

## 🌈 Gradient Combinations

### Primary Gradient
```
linear-gradient(135deg, #0b69ff 0%, #00c2ff 100%)
```
- **Usage**: Primary buttons, hero sections, main CTAs
- **Direction**: 135 degrees (diagonal)

### Dark Gradient
```
linear-gradient(135deg, #050816 0%, #1a2a6c 100%)
```
- **Usage**: Dark mode backgrounds, footer sections
- **Direction**: 135 degrees (diagonal)

### Blue Gradient (3-color)
```
linear-gradient(135deg, #1a2a6c 0%, #0b69ff 50%, #00c2ff 100%)
```
- **Usage**: Hero banners, special sections, animated backgrounds
- **Direction**: 135 degrees (diagonal)

---

## 📝 Usage Rules

### Do's ✅

- **Use primary blue (#0b69ff)** for main call-to-action buttons
- **Use gradients** for hero sections and banners
- **Maintain contrast** - ensure text is readable on colored backgrounds
- **Use dark colors** for text on light backgrounds
- **Apply gradients** to buttons for modern, professional look
- **Consistent application** - use the same color for the same purpose throughout

### Don'ts ❌

- **Don't modify colors** - use exact hex values
- **Don't use colors** that aren't in the palette
- **Don't place light text** on light backgrounds
- **Don't use gradients** inappropriately (e.g., on small text)
- **Don't mix** with other brand color schemes
- **Don't use colors** at low opacity without testing contrast

---

## 🎯 Application Examples

### Buttons

**Primary Button:**
```css
background: linear-gradient(135deg, #0b69ff 0%, #00c2ff 100%);
color: white;
```

**Dark Button:**
```css
background: linear-gradient(135deg, #050816 0%, #1a2a6c 100%);
color: white;
```

### Text

**Gradient Text (Headings):**
```css
background: linear-gradient(135deg, #0b69ff 0%, #00c2ff 100%);
-webkit-background-clip: text;
-webkit-text-fill-color: transparent;
```

**Dark Text:**
```css
color: #050816;
```

### Backgrounds

**Hero Section:**
```css
background: linear-gradient(135deg, #1a2a6c 0%, #0b69ff 50%, #00c2ff 100%);
```

**Card Background:**
```css
background: white;
border: 2px solid #0b69ff;
```

---

## 📱 Platform-Specific Usage

### Web
- Use full gradients and animations
- Apply hover effects liberally
- Use all color variations

### Mobile App
- Use solid colors for better performance
- Limit gradient usage to key elements
- Ensure touch targets have good contrast

### Print
- Use solid colors only
- Ensure high contrast
- Test in grayscale for accessibility

---

## 🔗 CSS Variables

Import `theme.css` to use CSS variables:

```css
@import url('theme.css');

.my-element {
  background: var(--coachguru-gradient-primary);
  color: var(--coachguru-dark);
}
```

Or use utility classes:

```html
<div class="bg-gradient-primary text-coachguru-dark">
  Content here
</div>
```

---

## 📊 Color Accessibility

### Contrast Ratios

- **#0b69ff on white**: 4.5:1 ✅ (WCAG AA)
- **#00c2ff on white**: 3.2:1 ⚠️ (Use with caution)
- **#050816 on white**: 16.8:1 ✅ (WCAG AAA)
- **White on #0b69ff**: 4.5:1 ✅ (WCAG AA)

### Recommendations

- Always test color combinations for accessibility
- Use dark colors (#050816, #1a2a6c) for text on light backgrounds
- Use white or light colors for text on dark/blue backgrounds
- Avoid using #00c2ff alone for text - combine with darker colors

---

## 🎨 Design System Integration

### Flutter App
Colors are defined in `lib/theme/theme.dart`:
- `CoachGuruTheme.mainBlue` → #0b69ff
- `CoachGuruTheme.lightBlue` → #00c2ff
- `CoachGuruTheme.textDark` → #050816

### Web/Documentation
Use `docs/theme/theme.css` for consistent styling.

---

## 📞 Questions?

For theme-related questions:
- Check this documentation first
- Review `docs/branding/branding.md` for brand guidelines
- Open an issue on GitHub for clarification

---

**Last Updated**: December 2024

