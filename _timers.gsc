
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;

safe_replacefunc(path, name, replacement) {
  func = getfunction(path, name);

  if (!isdefined(func))
    return false;

  if (!isdefined(level.old_funcs))
    level.old_funcs = [];

  level.old_funcs[name] = func;
  replacefunc(func, replacement);

  return true;
}

set_dvar_default(name, value) {
  if (getdvar(name) != "")
    return;

  setdvar(name, value);
}

get_dvar_default(dvar, def, type) {
  if (!isdefined(dvar) || dvar == "" || getdvar(dvar) == "")
    return def;

  if (!isdefined(type))
    type = "string";

  switch (tolower(type)) {
    case "int":
      return getdvarint(dvar);

    case "float":
      return getdvarfloat(dvar);

    case "bool":
      return getdvarint(dvar) != 0;

    case "string":
    default:
      return getdvar(dvar);
  }
}

main() {
  init_dvars();
}

init() {
  level thread init_timers();
}

is_split_enabled() {
  return get_dvar_default("is_split_timer", true, "bool");
}

init_dvars() {
  set_dvar_default("is_split_timer", 1);
}

init_timers() {
  if (isdefined(level.hud_timers_initialized))
    return;

  level.hud_timers_initialized = true;
  level.hud_game_start = undefined;
  level.hud_round_start = undefined;
  level.hud_round_time = 0;
  level.hud_round_active = false;

  level.hud_split_enabled = is_split_enabled();
  level.hud_split_round = 0;
  level.hud_split_time = 0;

  level thread track_timer_rounds();
  level thread create_timer_hud();
}

track_timer_rounds() {
  level endon("end_game");

  for (;;) {
    level waittill("start_of_round");

    if (!isdefined(level.hud_game_start))
      level.hud_game_start = gettime();

    level.hud_round_start = gettime();
    level.hud_round_time = 0;
    level.hud_round_active = true;

    if (isdefined(level.hud_round_hud))
      level.hud_round_hud setTimerUp(0);

    level waittill("end_of_round");

    level.hud_round_time = gettime() - level.hud_round_start;
    level.hud_round_active = false;

    if (isdefined(level.hud_round_hud))
      level.hud_round_hud set_string_text(format_timer_time(level.hud_round_time));

    if (level.hud_split_enabled) {
      level.hud_split_round = level.round_number;
      level.hud_split_time = gettime() - level.hud_game_start;

      if (isdefined(level.hud_split_hud))
        level.hud_split_hud set_string_text("R" + level.hud_split_round + " - " + format_timer_time(level.hud_split_time));
    }
  }
}

create_timer_hud() {
  level endon("end_game");

  flag_wait("initial_blackscreen_passed");

  if (!isdefined(level.hud_game_start))
    level.hud_game_start = gettime();

  level.hud_game_hud = create_timer_element(-30, "^2GAME  ^7");
  level.hud_round_hud = create_timer_element(-10, "^3ROUND  ^7");

  if (level.hud_split_enabled)
    level.hud_split_hud = create_timer_element(10, "^5SPLIT  ^7");

  game_elapsed = (gettime() - level.hud_game_start) / 1000.0;

  level.hud_game_hud setTimerUp(game_elapsed);

  if (level.hud_round_active && isdefined(level.hud_round_start)) {
    round_elapsed = (gettime() - level.hud_round_start) / 1000.0;
    level.hud_round_hud setTimerUp(round_elapsed);
  } else {
    level.hud_round_hud set_string_text(format_timer_time(level.hud_round_time));
  }

  if (level.hud_split_enabled && isdefined(level.hud_split_hud)) {
    if (level.hud_split_round > 0) {
      level.hud_split_hud set_string_text("R" + level.hud_split_round + " - " + format_timer_time(level.hud_split_time));
    } else {
      level.hud_split_hud set_string_text("--:--");
    }
  }
}

create_timer_element(y, label) {
  hud = createServerFontString("objective", 1.5);

  hud setpoint("TOPLEFT", "TOPLEFT", -55, y);

  hud.label = istring(label);
  hud.color = (1, 1, 1);
  hud.alpha = 1;
  hud.sort = 10;
  hud.hideWhenInMenu = 0;
  hud.glowAlpha = 0;

  return hud;
}

format_timer_time(milliseconds) {
  if (!isdefined(milliseconds) || milliseconds < 0)
    milliseconds = 0;

  total_seconds = int(milliseconds / 1000);

  hours = int(total_seconds / 3600);
  minutes = int(total_seconds / 60) % 60;
  seconds = total_seconds % 60;

  seconds_text = "" + seconds;

  if (seconds < 10)
    seconds_text = "0" + seconds;

  if (hours > 0) {
    minutes_text = "" + minutes;

    if (minutes < 10)
      minutes_text = "0" + minutes;

    return hours + ":" + minutes_text + ":" + seconds_text;
  }

  return minutes + ":" + seconds_text;
}

set_string_text(text) {
  if (!isdefined(text))
    text = "";

  if (isdefined(self.text) && self.text == text)
    return;

  self settextunlimited(text);
  self.text = text;
}

set_value_text(value) {
  if (!isdefined(value))
    value = 0;

  text = "" + value;

  if (isdefined(self.text) && self.text == text)
    return;

  self settextunlimited(text);
  self.text = text;
}

destroy_element() {
  if (isdefined(self.frame))
    self.frame destroy();

  if (isdefined(self.bar))
    self.bar destroy();

  if (isdefined(self.barframe))
    self.barframe destroy();

  self destroy();
}