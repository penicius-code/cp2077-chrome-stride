// Chrome Stride 1.4.3, 2026-10-29.
// Sprint speed from leg cyberware. The tier bonuses, the 94 km/h (26 m/s) speed cap (a wild cheetah's measured top speed) and the
// raised engine ground / air limits are in r6\tweaks\zz_ChromeStride\ChromeStride.yaml.
//
// This file (Mod Settings > Chrome Stride; Mod Settings itself is optional, the defaults below apply without it):
//  - Sprint speed limit (50 km/h, 94 = off): ceiling for the normal sprint. The burst (up to 94 km/h) and Running Man's
//    double sprint ignore it. Speeds in the settings and the speed log are km/h (m/s); internally m/s.
//  - Carrying a body: x0.54 on the sprint and a 36 km/h (10 m/s) ceiling. No double sprint or burst with a body.
//  - Sprint stamina (on): sprinting burns stamina (vanilla and Dark Future make it free). At 0 stamina V is winded and
//    sprints slower until stamina is back above the recovery level.
//  - Burst on double tap (on): Running Man's double tap sprint (Nexus 26611, Right Shift) fires an all-out burst with a
//    forward kick, the vanilla dash sound and screen effect, and a fast stamina drain. It lasts as long as stamina allows
//    (or a set number of seconds), there is no cooldown; it needs a little stamina and ends with V winded.
//  - Running Man's plain double sprint (burst off) costs stamina per second instead of per frame.
//  - Sprint build-up (on): the sprint starts at 50 % of top speed and builds up over 15 s while you keep sprinting, more of
//    the gain early. It follows the speed you really have: jumps and slides keep it, a stop, a wall
//    or being winded loses it, and it rebuilds from there.
//  - Jenkins' Tendons steady (on): its bonus stays full while sprinting instead of a start kick that fades, so the
//    build-up alone shapes the sprint and Jenkins raises the top speed.
//  - Speed log (off): once per second while sprinting, measured speed and the MaxSpeed stat go to the CET game log,
//    plus one dump of every MaxSpeed modifier per game session.
// All speed changes are one Multiplier on MaxSpeed that only exists while V is in the Sprint state.
// Without Running Man the vanilla two-step sprint is switched off, so the double tap parts do nothing.
//
// 1.4.3: Mod Settings "Burst top speed (km/h)", 40 to 94, live (tweak the burst speed on the fly).
// 1.4.2: normal sprint limit 50 km/h (13.9 m/s), burst unchanged up to 94 km/h (conserve energy, burst only when top
//        speed is needed); limits in km/h (new keys sprintLimitKmh / carryLimitKmh), build-up 0.50 over 15 s, curve 2,
//        speed log in km/h (m/s).
// 1.4.1: build-up over 10 s instead of 6 (after the in-game test of 1.4.0: "works, ramp up longer").
// 1.4.0: sprint build-up on by default and reworked (start slower, ramp up to top speed): 0.30 -> 1.0 over 6 s on an
//        ease-out curve, carry-over from the measured speed instead of a 1 s + 1 s timer, the build-up cannot run more
//        than 1.5 s ahead of the real speed, Jenkins' Tendons pool held full while sprinting. Speed log: 2D speed, build-up
//        and Jenkins stacks.
// 1.3.1: the burst fires on every trigger Running Man accepts again (its double tap and vanilla's single ToggleSprint tap,
//        Left Shift); 1.3.0 had required the multitap action and the double tap did not fire.
// 1.3.0 (after a code review and an in-game test): sprint limit off by default (the leg chrome curve is visible
//        again: 22.4 at the start, 18.7 sustained in the test), winded and build-up relative to the limited sprint, burst only on
//        the real double tap (a Left Shift tap used to fire it), burst without time limit and without cooldown, stamina
//        gate 10 %, not while winded, per-second drains instead of Running Man's per-frame cost, carry penalty in the
//        script, cleanup without the dead band. YAML: tier packages as base plus increments (TweakXL inheritance).
// 1.2.0: engine ground / air limits 26, sprint and carry limits, modifier dump. 1.1.0: sprint stamina and winded state,
//        burst with kick and effects, speed log. 1.0.0: first build.

public class ChromeStrideSettings extends ScriptableSystem {

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Sprint speed")
  @runtimeProperty("ModSettings.category.order", "0")
  @runtimeProperty("ModSettings.displayName", "Sprint speed limit (km/h)")
  @runtimeProperty("ModSettings.description", "Ceiling for the normal sprint, however much chrome you have. 50 = 50 km/h (13.9 m/s), a sustainable hard run; the double tap burst goes up to the mod's cap of 94 km/h (26 m/s, a wild cheetah) and ignores this limit, as does Running Man's double sprint. 94 = off. 54 km/h (15 m/s) = the game's own old limit.")
  @runtimeProperty("ModSettings.min", "36.0")
  @runtimeProperty("ModSettings.max", "94.0")
  @runtimeProperty("ModSettings.step", "1.0")
  public let sprintLimitKmh: Float = 50.0;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Sprint speed")
  @runtimeProperty("ModSettings.category.order", "0")
  @runtimeProperty("ModSettings.displayName", "Sprint speed with a body (x)")
  @runtimeProperty("ModSettings.description", "Multiplies your sprint speed while you carry a body on your shoulder. 0.54 = a full-chrome sprint of 87 km/h (24.1 m/s) becomes about 47 km/h (13 m/s), then the carry limit below applies. Walking with a body is not slowed.")
  @runtimeProperty("ModSettings.min", "0.2")
  @runtimeProperty("ModSettings.max", "1.0")
  @runtimeProperty("ModSettings.step", "0.02")
  public let carryPenalty: Float = 0.54;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Sprint speed")
  @runtimeProperty("ModSettings.category.order", "0")
  @runtimeProperty("ModSettings.displayName", "Speed limit carrying a body (km/h)")
  @runtimeProperty("ModSettings.description", "Top sprint speed with a body on your shoulder, whatever the chrome. 36 = 36 km/h (10 m/s). 94 = off.")
  @runtimeProperty("ModSettings.min", "10.0")
  @runtimeProperty("ModSettings.max", "94.0")
  @runtimeProperty("ModSettings.step", "1.0")
  public let carryLimitKmh: Float = 36.0;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Sprint speed")
  @runtimeProperty("ModSettings.category.order", "0")
  @runtimeProperty("ModSettings.displayName", "Jenkins' Tendons: steady bonus")
  @runtimeProperty("ModSettings.description", "On: Jenkins' Tendons' speed bonus stays at its full value while you sprint, so it raises your top speed and the sprint build-up decides how fast you get there. Off: vanilla, a strong kick at the start of a sprint that fades within seconds and recharges while you don't sprint.")
  public let jenkinsSteady: Bool = true;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Sprint stamina")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "Sprint stamina cost (% per second)")
  @runtimeProperty("ModSettings.description", "Sprinting burns this share of your maximum stamina per second (vanilla and Dark Future: free). 3 = about 33 seconds of sprinting from full stamina. At 0 stamina you are winded. 0 = free sprint like vanilla, and never winded.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "15.0")
  @runtimeProperty("ModSettings.step", "0.5")
  public let sprintStamina: Float = 3.0;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Sprint stamina")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "Winded sprint speed (x)")
  @runtimeProperty("ModSettings.description", "Share of your sprint speed while winded (of the limited sprint if a limit is set). Sprinting costs no stamina while winded, so it comes back while you run slower. No burst while winded. With the sprint build-up on, the build-up drops with your speed and rebuilds from there once you have recovered.")
  @runtimeProperty("ModSettings.min", "0.3")
  @runtimeProperty("ModSettings.max", "1.0")
  @runtimeProperty("ModSettings.step", "0.05")
  public let windedSpeed: Float = 0.6;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Sprint stamina")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "Recover from winded at (% stamina)")
  @runtimeProperty("ModSettings.description", "Winded ends when your stamina is back at this level.")
  @runtimeProperty("ModSettings.min", "5.0")
  @runtimeProperty("ModSettings.max", "100.0")
  @runtimeProperty("ModSettings.step", "5.0")
  public let windedRecover: Float = 30.0;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Burst (double tap sprint)")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "Burst on double tap")
  @runtimeProperty("ModSettings.description", "On: double tapping sprint (Right Shift, Running Man's double sprint perk) fires an all-out burst: a forward kick like a dash, much faster, drains stamina fast, lasts as long as stamina allows (or the set seconds), no cooldown. Capped at 94 km/h (26 m/s), a wild cheetah's top speed, above the normal sprint limit. A Left Shift tap starts or ends it. Off: Running Man's normal, sustained double sprint.")
  public let burst: Bool = true;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Burst (double tap sprint)")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "Burst length (s)")
  @runtimeProperty("ModSettings.description", "0 = the burst lasts until stamina runs out (or until you tap Left Shift). Any other value ends it after that many seconds at the latest.")
  @runtimeProperty("ModSettings.dependency", "burst")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "10.0")
  @runtimeProperty("ModSettings.step", "0.5")
  public let burstSeconds: Float = 0.0;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Burst (double tap sprint)")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "Burst power (x speed)")
  @runtimeProperty("ModSettings.description", "Multiplies your double sprint speed during the burst. The 94 km/h (26 m/s) cap still applies.")
  @runtimeProperty("ModSettings.dependency", "burst")
  @runtimeProperty("ModSettings.min", "1.0")
  @runtimeProperty("ModSettings.max", "2.0")
  @runtimeProperty("ModSettings.step", "0.05")
  public let burstPower: Float = 1.35;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Burst (double tap sprint)")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "Burst top speed (km/h)")
  @runtimeProperty("ModSettings.description", "Fastest the burst gets, whatever the burst power. 94 = 94 km/h (26 m/s), the mod's cap (a wild cheetah). 70 = 70 km/h (19.4 m/s). Applies on the next frame, also during a burst.")
  @runtimeProperty("ModSettings.dependency", "burst")
  @runtimeProperty("ModSettings.min", "40.0")
  @runtimeProperty("ModSettings.max", "94.0")
  @runtimeProperty("ModSettings.step", "1.0")
  public let burstTopKmh: Float = 94.0;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Burst (double tap sprint)")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "Burst kick (m/s)")
  @runtimeProperty("ModSettings.description", "Forward push when the burst fires, like the vanilla dash, in m/s: 6 = 22 km/h. 0 = no kick.")
  @runtimeProperty("ModSettings.dependency", "burst")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "15.0")
  @runtimeProperty("ModSettings.step", "1.0")
  public let burstKick: Float = 6.0;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Burst (double tap sprint)")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "Burst sound and screen effect")
  @runtimeProperty("ModSettings.description", "Plays the vanilla dash sound, screen effect and controller rumble when the burst fires.")
  @runtimeProperty("ModSettings.dependency", "burst")
  public let burstEffects: Bool = true;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Burst (double tap sprint)")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "Burst stamina drain (% per second)")
  @runtimeProperty("ModSettings.description", "Share of your maximum stamina the burst burns per second, on top of the sprint cost. 25 = about 3.5 seconds of burst from full stamina. Running Man's stamina perk halves it, a Sandevistan at Reflexes skill 60 makes it free (Running Man's rules).")
  @runtimeProperty("ModSettings.dependency", "burst")
  @runtimeProperty("ModSettings.min", "5.0")
  @runtimeProperty("ModSettings.max", "100.0")
  @runtimeProperty("ModSettings.step", "5.0")
  public let burstStamina: Float = 25.0;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Burst (double tap sprint)")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "Stamina needed (%)")
  @runtimeProperty("ModSettings.description", "A burst only starts with at least this much stamina, and never while winded.")
  @runtimeProperty("ModSettings.dependency", "burst")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "100.0")
  @runtimeProperty("ModSettings.step", "5.0")
  public let burstMinStamina: Float = 10.0;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Burst (double tap sprint)")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "Cooldown (s)")
  @runtimeProperty("ModSettings.description", "Seconds after a burst before the next one can start. 0 = none: only stamina and the winded state hold you back.")
  @runtimeProperty("ModSettings.dependency", "burst")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "15.0")
  @runtimeProperty("ModSettings.step", "0.5")
  public let burstRecovery: Float = 0.0;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Burst (double tap sprint)")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "Double sprint stamina (% per second)")
  @runtimeProperty("ModSettings.description", "Cost of Running Man's plain double sprint when the burst is off. Replaces Running Man's own cost of 0.4 stamina per frame, which depended on the frame rate (10 = its cost at 25 fps). Its stamina perk and Sandevistan rule still apply.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "50.0")
  @runtimeProperty("ModSettings.step", "1.0")
  public let doubleSprintStamina: Float = 10.0;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Sprint build-up")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.displayName", "Sprint build-up")
  @runtimeProperty("ModSettings.description", "On: a sprint starts slower and builds up to top speed while you keep sprinting. It follows the speed you really have: jumps and slides keep it, stopping, hitting a wall or being winded loses it, and it rebuilds from the speed you still have. A burst skips the run-up. Off: full sprint speed at once.")
  public let momentum: Bool = true;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Sprint build-up")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.displayName", "Start speed (x sprint)")
  @runtimeProperty("ModSettings.description", "Share of your full sprint speed when a sprint starts from a stop. 0.50 = 50 %: 25 km/h (6.9 m/s) at the 50 km/h limit.")
  @runtimeProperty("ModSettings.dependency", "momentum")
  @runtimeProperty("ModSettings.min", "0.2")
  @runtimeProperty("ModSettings.max", "1.0")
  @runtimeProperty("ModSettings.step", "0.05")
  public let momentumStart: Float = 0.50;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Sprint build-up")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.displayName", "Seconds to full speed")
  @runtimeProperty("ModSettings.description", "How long you have to keep sprinting from a stop to reach top speed.")
  @runtimeProperty("ModSettings.dependency", "momentum")
  @runtimeProperty("ModSettings.min", "1.0")
  @runtimeProperty("ModSettings.max", "20.0")
  @runtimeProperty("ModSettings.step", "0.5")
  public let momentumSeconds: Float = 15.0;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Sprint build-up")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.displayName", "Curve (1 = even)")
  @runtimeProperty("ModSettings.description", "How the speed grows. 1 = the same gain every second. 2 = more of the gain early but still climbing to the end. 3 = like a real sprinter: about 70 % of the gain in the first third, the last few km/h come slowly. Higher = even more up front.")
  @runtimeProperty("ModSettings.dependency", "momentum")
  @runtimeProperty("ModSettings.min", "1.0")
  @runtimeProperty("ModSettings.max", "4.0")
  @runtimeProperty("ModSettings.step", "0.5")
  public let momentumCurve: Float = 2.0;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Sprint build-up")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.displayName", "Top speed after build-up (x sprint)")
  @runtimeProperty("ModSettings.description", "Speed at the end of the build-up as a share of your full sprint. 1.0 = your leg chrome's full sprint; higher = a reward for a long run.")
  @runtimeProperty("ModSettings.dependency", "momentum")
  @runtimeProperty("ModSettings.min", "1.0")
  @runtimeProperty("ModSettings.max", "1.3")
  @runtimeProperty("ModSettings.step", "0.05")
  public let momentumTop: Float = 1.0;

  @runtimeProperty("ModSettings.mod", "Chrome Stride")
  @runtimeProperty("ModSettings.category", "Debug")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.displayName", "Speed log")
  @runtimeProperty("ModSettings.description", "Once per second while sprinting, writes the measured speed, the MaxSpeed stat, stamina and burst state to the CET game log (bin\\x64\\plugins\\cyber_engine_tweaks\\gamelog.log), plus one dump of every MaxSpeed modifier per game session. For testing; leave off otherwise.")
  public let speedLog: Bool = false;

  public static func Get(gi: GameInstance) -> ref<ChromeStrideSettings> {
    return GameInstance.GetScriptableSystemsContainer(gi).Get(n"ChromeStrideSettings") as ChromeStrideSettings;
  }

  @if(ModuleExists("ModSettingsModule"))
  private func OnAttach() -> Void {
    ModSettings.RegisterListenerToClass(this);
  }

  @if(ModuleExists("ModSettingsModule"))
  private func OnDetach() -> Void {
    ModSettings.UnregisterListenerToClass(this);
  }
}

// Our Multiplier on MaxSpeed while sprinting (limit, carry penalty, build-up, burst, winded), and the burst state.
@addField(SprintEvents)
private let m_csModifier: ref<gameStatModifierData>;

@addField(SprintEvents)
private let m_csFactor: Float = 1.0;

// The full (100 %) sprint in m/s as of the last factor update: uncapped speed, held at the sprint / carry limit.
@addField(SprintEvents)
private let m_csFull: Float;

// True while a burst runs. m_csBurstLeft is the time left when the burst has a time limit, 0 when it has none.
@addField(SprintEvents)
private let m_csBurst: Bool;

@addField(SprintEvents)
private let m_csBurstLeft: Float;

@addField(SprintEvents)
private let m_csLogTimer: Float;

// The speed log dumps the MaxSpeed modifier list once per game session.
@addField(SprintEvents)
private let m_csDumped: Bool;

// True while Running Man's double tap check runs, so a fresh double tap can be told apart from its resume after a jump.
@addField(SprintEvents)
private let m_csInEvaluate: Bool;

@addMethod(SprintEvents)
private final func CS_Settings(scriptInterface: ref<StateGameScriptInterface>) -> ref<ChromeStrideSettings> {
  return ChromeStrideSettings.Get(scriptInterface.executionOwner.GetGame());
}

@addMethod(SprintEvents)
private final func CS_Now(scriptInterface: ref<StateGameScriptInterface>) -> Float {
  return EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.executionOwner.GetGame()));
}

@addMethod(SprintEvents)
private final func CS_StaminaPercent(scriptInterface: ref<StateGameScriptInterface>) -> Float {
  return GameInstance.GetStatPoolsSystem(scriptInterface.executionOwner.GetGame()).GetStatPoolValue(Cast<StatsObjectID>(scriptInterface.executionOwner.GetEntityID()), gamedataStatPoolType.Stamina, true);
}

@addMethod(SprintEvents)
private final func CS_GetFloat(stateContext: ref<StateContext>, name: CName, fallback: Float) -> Float {
  let r: StateResultFloat = stateContext.GetPermanentFloatParameter(name);
  return r.valid ? r.value : fallback;
}

@addMethod(SprintEvents)
private final func CS_IsWinded(stateContext: ref<StateContext>) -> Bool {
  let r: StateResultBool = stateContext.GetPermanentBoolParameter(n"ChromeStride_Winded");
  return r.valid && r.value;
}

// Speed log text: km/h with m/s in brackets.
@addMethod(SprintEvents)
private final func CS_Kmh(speed: Float) -> String {
  return FloatToStringPrec(speed * 3.6, 0) + " km/h (" + FloatToStringPrec(speed, 1) + " m/s)";
}

@addMethod(SprintEvents)
private final func CS_Log(settings: ref<ChromeStrideSettings>, text: String) -> Void {
  if IsDefined(settings) && settings.speedLog {
    FTLog("[ChromeStride] " + text);
  }
}

// Running Man's rules for its double sprint cost, applied to our per-second drains: free with a Sandevistan at Reflexes
// skill 60, halved (player.staminaCosts.doubleSprintReductionMultiplier) with its stamina perk. Only called while Running
// Man's second sprint is on, so its perk name exists.
@addMethod(SprintEvents)
private final func CS_DrainMult(scriptInterface: ref<StateGameScriptInterface>) -> Float {
  let owner: ref<GameObject> = scriptInterface.executionOwner;
  let pds: ref<PlayerDevelopmentSystem> = PlayerDevelopmentSystem.GetInstance(owner);
  if StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"SandevistanPlayerBuff") && pds.GetProficiencyLevel(owner, gamedataProficiencyType.ReflexesSkill) >= 60 {
    return 0.0;
  }
  let perk: Int64 = EnumValueFromName(n"gamedataNewPerkType", n"Body_Left_Perk_1_1");
  if perk >= 0l && pds.IsNewPerkBought(owner, IntEnum<gamedataNewPerkType>(perk)) > 0 {
    return TweakDBInterface.GetFloat(t"player.staminaCosts.doubleSprintReductionMultiplier", 1.0);
  }
  return 1.0;
}

@addMethod(SprintEvents)
private final func CS_SetFactor(factor: Float, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  let current: Float = IsDefined(this.m_csModifier) ? this.m_csFactor : 1.0;
  // Refresh only on a change of at least 0.4 % (relative), so the limit holds within 0.4 % without a new modifier every frame.
  if AbsF(factor - current) < 0.004 * MaxF(current, 0.1) {
    return;
  }
  let stats: ref<StatsSystem> = scriptInterface.GetStatsSystem();
  let id: StatsObjectID = Cast<StatsObjectID>(scriptInterface.ownerEntityID);
  if IsDefined(this.m_csModifier) {
    stats.RemoveModifier(id, this.m_csModifier);
    this.m_csModifier = null;
  }
  this.m_csFactor = factor;
  if AbsF(factor - 1.0) >= 0.004 {
    this.m_csModifier = RPGManager.CreateStatModifier(gamedataStatType.MaxSpeed, gameStatModifierType.Multiplier, factor);
    stats.AddModifier(id, this.m_csModifier);
  }
}

// Leaving the sprint: remove the modifier whatever its value (no dead band).
@addMethod(SprintEvents)
private final func CS_ClearFactor(scriptInterface: ref<StateGameScriptInterface>) -> Void {
  if IsDefined(this.m_csModifier) {
    scriptInterface.GetStatsSystem().RemoveModifier(Cast<StatsObjectID>(scriptInterface.ownerEntityID), this.m_csModifier);
    this.m_csModifier = null;
  }
  this.m_csFactor = 1.0;
}

// Share of the full sprint at build-up progress x (0 to 1): start + (top - start) x (1 - (1 - x)^curve). Curve 1 is
// linear; higher puts more of the gain early, the way a sprinter accelerates.
@addMethod(SprintEvents)
private final func CS_RampShare(settings: ref<ChromeStrideSettings>, x: Float) -> Float {
  let shape: Float = 1.0 - PowF(1.0 - ClampF(x, 0.0, 1.0), MaxF(1.0, settings.momentumCurve));
  return settings.momentumStart + (settings.momentumTop - settings.momentumStart) * shape;
}

// The inverse: the build-up progress at which the ramp gives this share of the full sprint.
@addMethod(SprintEvents)
private final func CS_RampProgress(settings: ref<ChromeStrideSettings>, share: Float) -> Float {
  let span: Float = settings.momentumTop - settings.momentumStart;
  if span <= 0.001 {
    return 1.0;
  }
  let u: Float = ClampF((share - settings.momentumStart) / span, 0.0, 1.0);
  return 1.0 - PowF(1.0 - u, 1.0 / MaxF(1.0, settings.momentumCurve));
}

// Jenkins' Tendons: its MaxSpeed buff has one stack (+1 %) per share of the JenkinsHelper pool, which drains while
// sprinting, a kick at the start that fades within seconds. Steady: the pool is kept full while sprinting, so the bonus is
// constant and the build-up alone shapes the sprint. Nothing happens without Jenkins' Tendons (no pool).
@addMethod(SprintEvents)
private final func CS_HoldJenkins(scriptInterface: ref<StateGameScriptInterface>) -> Void {
  let pools: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(scriptInterface.executionOwner.GetGame());
  let id: StatsObjectID = Cast<StatsObjectID>(scriptInterface.executionOwner.GetEntityID());
  if pools.IsStatPoolAdded(id, gamedataStatPoolType.JenkinsHelper) && pools.GetStatPoolValue(id, gamedataStatPoolType.JenkinsHelper, true) < 99.5 {
    pools.RequestSettingStatPoolValue(id, gamedataStatPoolType.JenkinsHelper, 100.0, scriptInterface.executionOwner, true);
  }
}

// Speed log only: the stack count of Jenkins' Tendons' buff (0 without it).
@addMethod(SprintEvents)
private final func CS_JenkinsStacks(scriptInterface: ref<StateGameScriptInterface>) -> Int32 {
  let effect: ref<StatusEffect> = StatusEffectHelper.GetStatusEffectByID(scriptInterface.executionOwner, t"BaseStatusEffect.JenkinsPlayerBuff");
  return IsDefined(effect) ? Cast<Int32>(effect.GetStackCount()) : 0;
}

// Winded starts at empty stamina and ends at the recovery level. Only with a sprint stamina cost.
@addMethod(SprintEvents)
private final func CS_UpdateWinded(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, settings: ref<ChromeStrideSettings>) -> Void {
  let winded: Bool = this.CS_IsWinded(stateContext);
  if !IsDefined(settings) || settings.sprintStamina <= 0.0 {
    if winded {
      stateContext.SetPermanentBoolParameter(n"ChromeStride_Winded", false, true);
    }
    return;
  }
  let stamina: Float = this.CS_StaminaPercent(scriptInterface);
  if !winded && stamina <= 0.5 {
    stateContext.SetPermanentBoolParameter(n"ChromeStride_Winded", true, true);
    this.CS_Log(settings, "winded (stamina empty)");
  } else {
    if winded && stamina >= settings.windedRecover {
      stateContext.SetPermanentBoolParameter(n"ChromeStride_Winded", false, true);
      // The build-up was held while winded; it rebuilds from the speed you have left.
      if settings.momentum && !this.m_csBurst && this.m_csFull > 0.1 {
        stateContext.SetPermanentFloatParameter(n"ChromeStride_Momentum", this.CS_RampProgress(settings, DefaultTransition.Get2DLinearSpeed(scriptInterface) / this.m_csFull), true);
      }
      this.CS_Log(settings, "recovered from winded");
    }
  }
}

// The factor is our one Multiplier on MaxSpeed. A burst is all-out: burst power, nothing else. Otherwise the sprint limit
// (and the carry limit) comes first, then the build-up and the winded share scale that limited sprint, and the carry
// penalty multiplies everything. Running Man's plain double sprint (burst off) ignores the limit too. The uncapped
// ("natural") speed is the stat divided by the factor we applied; if the stat sits at its cap the estimate is low for one
// update and corrects itself. The build-up's share comes from CS_RampShare.
// CS_UpdateFull returns the limit share ("base") and stores the full sprint in m/s (natural x base) for the build-up.
@addMethod(SprintEvents)
private final func CS_UpdateFull(scriptInterface: ref<StateGameScriptInterface>, settings: ref<ChromeStrideSettings>, carrying: Bool) -> Float {
  let penalty: Float = carrying ? settings.carryPenalty : 1.0;
  let current: Float = IsDefined(this.m_csModifier) ? this.m_csFactor : 1.0;
  let stat: Float = scriptInterface.GetStatsSystem().GetStatValue(Cast<StatsObjectID>(scriptInterface.ownerEntityID), gamedataStatType.MaxSpeed);
  let natural: Float = stat / MaxF(0.01, current) * penalty;
  let base: Float = 1.0;
  let limit: Float = settings.sprintLimitKmh / 3.6;
  if carrying {
    limit = MinF(limit, settings.carryLimitKmh / 3.6);
  }
  if !this.m_isInSecondSprint && limit > 0.0 && natural > 0.1 && natural > limit {
    base = limit / natural;
  }
  this.m_csFull = natural * base;
  return base;
}

@addMethod(SprintEvents)
private final func CS_ApplyFactor(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, settings: ref<ChromeStrideSettings>) -> Void {
  let factor: Float = 1.0;
  if IsDefined(settings) {
    let carrying: Bool = this.IsCarryingBody(scriptInterface);
    let penalty: Float = carrying ? settings.carryPenalty : 1.0;
    if this.m_csBurst {
      factor = settings.burstPower;
      // Burst top speed: the uncapped speed (stat / our factor, Running Man's double sprint included) times the power,
      // held at the setting. While the stat sits at its 26 m/s cap the estimate is low and converges within a few updates.
      let current: Float = IsDefined(this.m_csModifier) ? this.m_csFactor : 1.0;
      let natural: Float = scriptInterface.GetStatsSystem().GetStatValue(Cast<StatsObjectID>(scriptInterface.ownerEntityID), gamedataStatType.MaxSpeed) / MaxF(0.01, current);
      let top: Float = settings.burstTopKmh / 3.6;
      if natural > 0.1 && natural * factor > top {
        factor = top / natural;
      }
    } else {
      factor = this.CS_UpdateFull(scriptInterface, settings, carrying);
      if settings.momentum {
        factor *= this.CS_RampShare(settings, this.CS_GetFloat(stateContext, n"ChromeStride_Momentum", 0.0));
      }
      if this.CS_IsWinded(stateContext) {
        factor *= settings.windedSpeed;
      }
    }
    factor *= penalty;
  }
  this.CS_SetFactor(factor, scriptInterface);
}

// Speed log only: every MaxSpeed modifier on V once per game session, to see what adds up.
@addMethod(SprintEvents)
private final func CS_DumpModifiers(settings: ref<ChromeStrideSettings>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  let details: array<gameStatDetailedData> = scriptInterface.GetStatsSystem().GetStatDetails(Cast<StatsObjectID>(scriptInterface.ownerEntityID));
  for detail in details {
    if Equals(detail.statType, gamedataStatType.MaxSpeed) {
      this.CS_Log(settings, s"MaxSpeed stat \(detail.value), \(ArraySize(detail.modifiers)) modifiers:");
      for modifier in detail.modifiers {
        this.CS_Log(settings, s"  \(modifier.modifierType) \(modifier.value)");
      }
    }
  }
}

@addMethod(SprintEvents)
private final func CS_EndBurst(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, settings: ref<ChromeStrideSettings>, reason: String) -> Void {
  this.m_csBurst = false;
  this.m_csBurstLeft = 0.0;
  stateContext.SetPermanentFloatParameter(n"ChromeStride_BurstLeft", 0.0, true);
  stateContext.SetPermanentFloatParameter(n"ChromeStride_ReadyAt", this.CS_Now(scriptInterface) + (IsDefined(settings) ? settings.burstRecovery : 0.0), true);
  if this.m_isInSecondSprint {
    this.m_isInSecondSprint = false;
    this.RemoveMaxSpeedModifier(stateContext, scriptInterface);
  }
  stateContext.SetPermanentBoolParameter(n"RunningMan_ResumeSecondSprint", false, true);
  this.CS_Log(settings, "burst end (" + reason + ")");
}

// A double tap that does not start a burst: no second sprint, and it must not come back through Running Man's resume.
@addMethod(SprintEvents)
private final func CS_RefuseBurst(stateContext: ref<StateContext>, settings: ref<ChromeStrideSettings>, why: String) -> Void {
  this.m_isInSecondSprint = false;
  stateContext.SetPermanentBoolParameter(n"RunningMan_ResumeSecondSprint", false, true);
  this.CS_Log(settings, "double tap: no burst (" + why + ")");
}

@wrapMethod(SprintEvents)
public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);
  let settings: ref<ChromeStrideSettings> = this.CS_Settings(scriptInterface);
  if IsDefined(settings) && settings.jenkinsSteady {
    this.CS_HoldJenkins(scriptInterface);
  }
  if IsDefined(settings) && settings.momentum {
    // The build-up resumes from the speed you still have (our modifier is off between sprints, so the stat is the full
    // sprint): jumps, slides and short stops keep it, a real stop loses it. A burst resumed by Running Man skips it.
    let momentum: Float = 1.0;
    if !this.m_csBurst {
      this.CS_UpdateFull(scriptInterface, settings, this.IsCarryingBody(scriptInterface));
      momentum = 0.0;
      if this.m_csFull > 0.1 {
        // Winded (from the last sprint): the speed you have is the winded share of the build-up.
        let full: Float = this.CS_IsWinded(stateContext) ? this.m_csFull * settings.windedSpeed : this.m_csFull;
        momentum = this.CS_RampProgress(settings, DefaultTransition.Get2DLinearSpeed(scriptInterface) / MaxF(0.1, full));
      }
    }
    stateContext.SetPermanentFloatParameter(n"ChromeStride_Momentum", momentum, true);
  }
  this.m_csLogTimer = 0.0;
  this.CS_UpdateWinded(stateContext, scriptInterface, settings);
  this.CS_ApplyFactor(stateContext, scriptInterface, settings);
}

@wrapMethod(SprintEvents)
protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(timeDelta, stateContext, scriptInterface);
  let settings: ref<ChromeStrideSettings> = this.CS_Settings(scriptInterface);
  if !IsDefined(settings) {
    return;
  }
  let player: ref<PlayerPuppet> = scriptInterface.executionOwner as PlayerPuppet;
  if this.m_csBurst && this.m_csBurstLeft > 0.0 {
    this.m_csBurstLeft -= timeDelta;
    if this.m_csBurstLeft <= 0.0 {
      this.CS_EndBurst(stateContext, scriptInterface, settings, "time");
    }
  }
  if this.m_csBurst {
    PlayerStaminaHelpers.ModifyStamina(player, -settings.burstStamina * timeDelta * this.CS_DrainMult(scriptInterface), true);
    if !this.m_isInSecondSprint {
      this.CS_EndBurst(stateContext, scriptInterface, settings, "double sprint ended");
    } else {
      if this.CS_StaminaPercent(scriptInterface) <= 0.5 {
        this.CS_EndBurst(stateContext, scriptInterface, settings, "stamina empty");
      }
    }
  } else {
    if this.m_isInSecondSprint && settings.doubleSprintStamina > 0.0 {
      // Running Man's plain double sprint (burst off): our per-second cost replaces its per-frame one (YAML zeroes it).
      PlayerStaminaHelpers.ModifyStamina(player, -settings.doubleSprintStamina * timeDelta * this.CS_DrainMult(scriptInterface), true);
    }
  }
  if settings.sprintStamina > 0.0 && !this.CS_IsWinded(stateContext) && !RPGManager.HasStatFlag(scriptInterface.executionOwner, gamedataStatType.IsSprintStaminaFree) {
    PlayerStaminaHelpers.ModifyStamina(player, -settings.sprintStamina * timeDelta, true);
  }
  if settings.jenkinsSteady {
    this.CS_HoldJenkins(scriptInterface);
  }
  if settings.momentum {
    let momentum: Float = 1.0;
    if !this.m_csBurst {
      momentum = this.CS_GetFloat(stateContext, n"ChromeStride_Momentum", 0.0);
      // Winded holds the build-up (the winded share applies on top); CS_UpdateWinded rebuilds it from the real speed after.
      if !this.CS_IsWinded(stateContext) {
        let seconds: Float = MaxF(0.1, settings.momentumSeconds);
        momentum = MinF(1.0, momentum + timeDelta / seconds);
        // The build-up may run up to 1.5 s ahead of the speed you really reach (the engine accelerates at its own rate),
        // no further: running into something or being slowed costs build-up, and it rebuilds from the speed you have.
        if this.m_csFull > 0.1 {
          momentum = MinF(momentum, this.CS_RampProgress(settings, DefaultTransition.Get2DLinearSpeed(scriptInterface) / this.m_csFull) + 1.5 / seconds);
        }
      }
    }
    stateContext.SetPermanentFloatParameter(n"ChromeStride_Momentum", momentum, true);
  }
  this.CS_UpdateWinded(stateContext, scriptInterface, settings);
  this.CS_ApplyFactor(stateContext, scriptInterface, settings);
  if settings.speedLog {
    if !this.m_csDumped && this.GetInStateTime() > 2.0 {
      this.m_csDumped = true;
      this.CS_DumpModifiers(settings, scriptInterface);
    }
    this.m_csLogTimer -= timeDelta;
    if this.m_csLogTimer <= 0.0 {
      this.m_csLogTimer = 1.0;
      // 2D speed since 1.4.0 (the build-up uses it); 1.3.x logged the 3D LinearSpeed.
      let measured: Float = DefaultTransition.Get2DLinearSpeed(scriptInterface);
      let stat: Float = scriptInterface.GetStatsSystem().GetStatValue(Cast<StatsObjectID>(scriptInterface.ownerEntityID), gamedataStatType.MaxSpeed);
      let burstText: String = "no";
      if this.m_csBurst {
        burstText = this.m_csBurstLeft > 0.0 ? FloatToStringPrec(this.m_csBurstLeft, 1) + " s left" : "on, no time limit";
      }
      let rampText: String = "off";
      if settings.momentum {
        let progress: Float = this.CS_GetFloat(stateContext, n"ChromeStride_Momentum", 0.0);
        rampText = FloatToStringPrec(progress * 100.0, 0) + " % (x" + FloatToStringPrec(this.CS_RampShare(settings, progress), 2) + " of full " + this.CS_Kmh(this.m_csFull) + ")";
      }
      FTLog("[ChromeStride] sprint " + FloatToStringPrec(this.GetInStateTime(), 1) + " s: speed " + this.CS_Kmh(measured) + ", MaxSpeed stat " + this.CS_Kmh(stat) + ", factor " + FloatToStringPrec(IsDefined(this.m_csModifier) ? this.m_csFactor : 1.0, 2) + ", build-up " + rampText + ", Jenkins " + IntToString(this.CS_JenkinsStacks(scriptInterface)) + " stacks, stamina " + FloatToStringPrec(this.CS_StaminaPercent(scriptInterface), 0) + " %, double sprint " + (this.m_isInSecondSprint ? "yes" : "no") + ", burst " + burstText + ", winded " + (this.CS_IsWinded(stateContext) ? "yes" : "no") + ", carrying " + (this.IsCarryingBody(scriptInterface) ? "yes" : "no") + ", limit " + this.CS_Kmh(settings.sprintLimitKmh / 3.6));
    }
  }
}

// Every way out of the Sprint state (OnExit, OnExitToJump, OnExitToChargeJump, OnForcedExit) runs this.
@wrapMethod(SprintEvents)
private final func CleanupTwoStepSprint(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);
  let now: Float = this.CS_Now(scriptInterface);
  stateContext.SetPermanentFloatParameter(n"ChromeStride_ExitTime", now, true);
  if this.m_csBurst {
    // A burst cut short by a jump can continue on landing (Running Man resumes the double sprint). -1 = no time limit.
    stateContext.SetPermanentFloatParameter(n"ChromeStride_BurstLeft", this.m_csBurstLeft > 0.0 ? this.m_csBurstLeft : -1.0, true);
    let settings: ref<ChromeStrideSettings> = this.CS_Settings(scriptInterface);
    stateContext.SetPermanentFloatParameter(n"ChromeStride_ReadyAt", now + (IsDefined(settings) ? settings.burstRecovery : 0.0), true);
    this.m_csBurst = false;
    this.m_csBurstLeft = 0.0;
  }
  this.CS_ClearFactor(scriptInterface);
}

@wrapMethod(SprintEvents)
private final func EvaluateTwoStepSprint(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  let settings: ref<ChromeStrideSettings> = this.CS_Settings(scriptInterface);
  // With a body on the shoulder there is no all-out sprint.
  if this.IsCarryingBody(scriptInterface) {
    if this.m_csBurst {
      this.CS_EndBurst(stateContext, scriptInterface, settings, "carrying");
    } else {
      if this.m_isInSecondSprint {
        this.m_isInSecondSprint = false;
        this.RemoveMaxSpeedModifier(stateContext, scriptInterface);
      }
    }
    stateContext.SetPermanentBoolParameter(n"RunningMan_ResumeSecondSprint", false, true);
    return;
  }
  this.m_csInEvaluate = true;
  wrappedMethod(stateContext, scriptInterface);
  this.m_csInEvaluate = false;
  // Burst mode: a double tap that did not start a burst must not come back later through Running Man's resume.
  if IsDefined(settings) && settings.burst && !this.m_csBurst && !this.m_isInSecondSprint {
    stateContext.SetPermanentBoolParameter(n"RunningMan_ResumeSecondSprint", false, true);
  }
}

// Running Man starts its double sprint here, from the double tap check or from SprintEvents.OnEnter (resume after a jump).
@wrapMethod(SprintEvents)
private final func AddMaxSpeedModifier(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  if this.IsCarryingBody(scriptInterface) {
    this.m_isInSecondSprint = false;
    stateContext.SetPermanentBoolParameter(n"RunningMan_ResumeSecondSprint", false, true);
    return;
  }
  let settings: ref<ChromeStrideSettings> = this.CS_Settings(scriptInterface);
  if !IsDefined(settings) || !settings.burst {
    wrappedMethod(stateContext, scriptInterface);
    return;
  }
  let now: Float = this.CS_Now(scriptInterface);
  let burstTime: Float;
  let fresh: Bool = this.m_csInEvaluate;
  if fresh {
    // Any trigger Running Man accepts: its double tap of the sprint key, or vanilla's single tap of ToggleSprint (Left
    // Shift) after 0.1 s in the state. (1.3.0 required the multitap action; the double tap did not fire with it.)
    if this.CS_IsWinded(stateContext) {
      this.CS_RefuseBurst(stateContext, settings, "winded");
      return;
    }
    if now < this.CS_GetFloat(stateContext, n"ChromeStride_ReadyAt", 0.0) {
      this.CS_RefuseBurst(stateContext, settings, "cooldown");
      return;
    }
    if this.CS_StaminaPercent(scriptInterface) < settings.burstMinStamina {
      this.CS_RefuseBurst(stateContext, settings, "not enough stamina");
      return;
    }
    burstTime = settings.burstSeconds;
  } else {
    // Resume after a jump: only a burst that was cut short less than a second ago continues (-1 = it had no time limit).
    burstTime = this.CS_GetFloat(stateContext, n"ChromeStride_BurstLeft", 0.0);
    if burstTime == 0.0 || now - this.CS_GetFloat(stateContext, n"ChromeStride_ExitTime", -1000.0) > 1.0 {
      this.m_isInSecondSprint = false;
      stateContext.SetPermanentFloatParameter(n"ChromeStride_BurstLeft", 0.0, true);
      stateContext.SetPermanentBoolParameter(n"RunningMan_ResumeSecondSprint", false, true);
      return;
    }
    if burstTime < 0.0 {
      burstTime = 0.0;
    }
  }
  wrappedMethod(stateContext, scriptInterface);
  this.m_csBurst = true;
  this.m_csBurstLeft = burstTime;
  stateContext.SetPermanentFloatParameter(n"ChromeStride_BurstLeft", 0.0, true);
  if settings.momentum {
    // The burst skips the run-up.
    stateContext.SetPermanentFloatParameter(n"ChromeStride_Momentum", 1.0, true);
  }
  if fresh {
    if settings.burstKick > 0.0 {
      this.AddImpulseInMovingDirection(stateContext, scriptInterface, settings.burstKick);
    }
    if settings.burstEffects {
      this.PlaySound(n"lcm_dash", scriptInterface);
      GameObjectEffectHelper.StartEffectEvent(scriptInterface.executionOwner, n"dash");
      DefaultTransition.PlayRumble(scriptInterface, "medium_pulse");
    }
    this.CS_Log(settings, "burst start (" + (burstTime > 0.0 ? FloatToStringPrec(burstTime, 1) + " s" : "until stamina runs out") + ")");
  } else {
    this.CS_Log(settings, "burst resumed after a jump (" + (burstTime > 0.0 ? FloatToStringPrec(burstTime, 1) + " s left" : "no time limit") + ")");
  }
}
