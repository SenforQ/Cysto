import 'dart:math';

const List<String> kMagicMotionPromptPresets = [
  'Gentle breeze moves the hair; eyes shimmer softly; a slight smile; camera slowly pushes in.',
  'Character gives a small nod; clothes flutter slightly; soft bokeh in the background drifts.',
  'Natural blinks and breathing; head tilts slightly as if engaging with the camera.',
  'Slow half-turn; skirt or coat edges flow; light and shadow shift gradually.',
  'Emotion shifts from mild surprise to a warm smile; shoulders relax.',
  'Rain or light particles drift down; character looks off-screen; lashes flutter.',
  'A prop (book, headphones) moves subtly; body weight shifts slightly.',
  'Hair and eye highlights shift with the light; cinematic shallow depth of field.',
  'Small victory pose—fist pump or peace sign—energetic but not exaggerated.',
  'Sitting in a daze, then snapping to focus; eyes lock in; lips press briefly.',
  'Neon at night reflects in the eyes and moves slowly; urban mood.',
  'Petals or cherry blossoms drift from above; character reaches as if to catch them.',
  'Rim light sweeps slowly across the profile; subtle chest movement with breath.',
  'Magic particles spiral upward around the character; calm, focused expression.',
  'Extremely slow pan; character holds the pose while small details keep moving.',
];

String randomMagicMotionPrompt(Random random) {
  return kMagicMotionPromptPresets[random.nextInt(kMagicMotionPromptPresets.length)];
}
