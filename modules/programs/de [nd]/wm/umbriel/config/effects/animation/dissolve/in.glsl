// niri dissolve: window-open
// 窗口从上方 30% 处落下，配合 spring 回弹；越界部分透明，整体按进度淡入。
vec4 animation(vec2 uv) {
  float p = umbriel_progress;
  vec2 moved = vec2(uv.x, uv.y + (1.0 - p) * 0.3);
  vec4 color = umbriel_sample(moved);
  if (moved.x < 0.0 || moved.x > 1.0 || moved.y < 0.0 || moved.y > 1.0) {
    color = vec4(0.0);
  }
  return color * umbriel_clamped_progress;
}
