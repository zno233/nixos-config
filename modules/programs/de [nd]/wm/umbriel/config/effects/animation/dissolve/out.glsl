// niri dissolve: window-close
// 噪点阈值溶解 + 重力下落（先 20% 时间溶解，再加速坠落），整体按进度淡出。
float dissolve_rand(vec2 co) {
  return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 animation(vec2 uv) {
  float p = umbriel_clamped_progress;
  float noise = dissolve_rand(uv * 30.0);
  if (noise < (p * 1.5 - (1.0 - uv.y) * 0.2)) {
    return vec4(0.0);
  }

  float drop_p = max(0.0, p - 0.2) / 0.8;
  float gravity = pow(drop_p, 3.0) * 4.0;
  float spread = (noise - 0.5) * gravity * 0.1;

  vec2 moved = vec2(uv.x + spread, uv.y - gravity);
  vec4 color = umbriel_sample(moved);
  if (moved.x < 0.0 || moved.x > 1.0 || moved.y < 0.0 || moved.y > 1.0) {
    return vec4(0.0);
  }
  return color * (1.0 - p);
}
