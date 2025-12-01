// Simple script to generate CoachGuru app icon
// This creates a canvas-based PNG of the app icon

const fs = require('fs');
const { createCanvas } = require('canvas');

// Create a 1024x1024 canvas
const canvas = createCanvas(1024, 1024);
const ctx = canvas.getContext('2d');

// Create gradient background
const gradient = ctx.createLinearGradient(0, 0, 1024, 1024);
gradient.addColorStop(0, '#0B2D5C');
gradient.addColorStop(1, '#0E5FD8');

// Fill background with gradient
ctx.fillStyle = gradient;
ctx.fillRect(0, 0, 1024, 1024);

// Add rounded corners effect (simplified)
ctx.globalCompositeOperation = 'destination-in';
ctx.beginPath();
ctx.roundRect(0, 0, 1024, 1024, 200);
ctx.fill();

// Reset composite operation
ctx.globalCompositeOperation = 'source-over';

// Draw CG monogram
ctx.fillStyle = '#FFFFFF';
ctx.font = 'bold 200px Arial';
ctx.textAlign = 'center';
ctx.textBaseline = 'middle';
ctx.fillText('CG', 512, 512);

// Draw orange tactic arrow
ctx.fillStyle = '#FFB000';
ctx.beginPath();
ctx.moveTo(700, 300);
ctx.lineTo(800, 300);
ctx.lineTo(780, 280);
ctx.lineTo(820, 320);
ctx.lineTo(780, 360);
ctx.lineTo(800, 340);
ctx.lineTo(700, 340);
ctx.closePath();
ctx.fill();

// Add circle to arrow
ctx.beginPath();
ctx.arc(750, 320, 15, 0, 2 * Math.PI);
ctx.fill();

// Save as PNG
const buffer = canvas.toBuffer('image/png');
fs.writeFileSync('coachguru_app_icon_1024.png', buffer);

console.log('CoachGuru app icon generated: coachguru_app_icon_1024.png');
