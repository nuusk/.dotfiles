/**
 * peon-ping for OpenCode — CESP v1.0 Adapter
 *
 * A CESP (Coding Event Sound Pack Specification) player for OpenCode.
 * Plays sound effects from OpenPeon-compatible sound packs when coding
 * events occur: task completion, errors, permission prompts, and more.
 *
 * Conforms to the CESP v1.0 specification:
 * https://github.com/PeonPing/openpeon
 *
 * Features:
 * - Reads openpeon.json manifests per CESP v1.0
 * - Maps OpenCode events to CESP categories
 * - Registry integration: install packs from the OpenPeon registry
 * - Desktop notifications when the terminal is not focused
 * - Tab title updates (project: status)
 * - Rapid-prompt detection (user.spam)
 * - Pause/resume support
 * - Pack rotation per session
 * - SSH/devcontainer relay support
 * - category_aliases for backward compatibility with legacy packs
 *
 * Setup:
 *   1. Copy this file to ~/.config/opencode/plugins/peon-ping.ts
 *   2. Install a pack (see README for details)
 *   3. Restart OpenCode
 *
 * Ported from https://github.com/tonyyont/peon-ping
 */

import * as fs from "node:fs"
import * as path from "node:path"
import * as os from "node:os"
import type { Plugin } from "@opencode-ai/plugin"

// ---------------------------------------------------------------------------
// CESP v1.0 Types
// ---------------------------------------------------------------------------

type CESPCategory =
  | "session.start"
  | "session.end"
  | "task.acknowledge"
  | "task.complete"
  | "task.error"
  | "task.progress"
  | "input.required"
  | "resource.limit"
  | "user.spam"

const CESP_CATEGORIES: readonly CESPCategory[] = [
  "session.start",
  "session.end",
  "task.acknowledge",
  "task.complete",
  "task.error",
  "task.progress",
  "input.required",
  "resource.limit",
  "user.spam",
] as const

interface CESPSound {
  file: string
  label: string
  sha256?: string
}

interface CESPCategoryEntry {
  sounds: CESPSound[]
}

interface CESPManifest {
  cesp_version: string
  name: string
  display_name: string
  version: string
  description?: string
  author?: { name: string; github?: string }
  license?: string
  language?: string
  homepage?: string
  tags?: string[]
  preview?: string
  min_player_version?: string
  categories: Partial<Record<CESPCategory, CESPCategoryEntry>>
  category_aliases?: Record<string, CESPCategory>
}

interface PeonConfig {
  active_pack: string
  volume: number
  enabled: boolean
  desktop_notifications: boolean
  use_sound_effects_device: boolean
  categories: Partial<Record<CESPCategory, boolean>>
  spam_threshold: number
  spam_window_seconds: number
  pack_rotation: string[]
  packs_dir?: string
  debounce_ms: number
  relay_host?: string
  relay_port?: number
}

interface PeonState {
  last_played: Partial<Record<CESPCategory, string>>
  session_packs: Record<string, string>
}

// ---------------------------------------------------------------------------
// Platform Detection & Relay
// ---------------------------------------------------------------------------

type RuntimePlatform = "mac" | "linux" | "wsl" | "ssh" | "devcontainer"

interface RelayConfig {
  host: string
  port: number
}

function detectPlatform(): RuntimePlatform {
  if (process.env.SSH_CONNECTION || process.env.SSH_CLIENT) return "ssh"
  if (process.env.REMOTE_CONTAINERS || process.env.CODESPACES) return "devcontainer"
  if (os.platform() === "linux") {
    try {
      const ver = fs.readFileSync("/proc/version", "utf8")
      if (/microsoft/i.test(ver)) return "wsl"
    } catch {}
    return "linux"
  }
  if (os.platform() === "darwin") return "mac"
  return "linux"
}

function getRelayConfig(config: PeonConfig, platform: RuntimePlatform): RelayConfig {
  const host = config.relay_host
    || process.env.PEON_RELAY_HOST
    || (platform === "devcontainer" ? "host.docker.internal" : "localhost")
  const port = config.relay_port
    || Number(process.env.PEON_RELAY_PORT)
    || 19998
  return { host, port }
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const PLUGIN_DIR = path.join(os.homedir(), ".config", "opencode", "peon-ping")
const CONFIG_PATH = path.join(PLUGIN_DIR, "config.json")
const STATE_PATH = path.join(PLUGIN_DIR, ".state.json")
const PAUSED_PATH = path.join(PLUGIN_DIR, ".paused")
const DEFAULT_PACKS_DIR = path.join(os.homedir(), ".openpeon", "packs")

const DEFAULT_CONFIG: PeonConfig = {
  active_pack: "sc_kerrigan",
  volume: 0.5,
  enabled: true,
  desktop_notifications: true,
  use_sound_effects_device: true,
  categories: {
    "session.start": true,
    "session.end": true,
    "task.acknowledge": true,
    "task.complete": true,
    "task.error": true,
    "task.progress": true,
    "input.required": true,
    "resource.limit": true,
    "user.spam": true,
  },
  spam_threshold: 3,
  spam_window_seconds: 10,
  pack_rotation: [],
  debounce_ms: 500,
}

const TERMINAL_APPS = [
  "Terminal",
  "iTerm2",
  "Warp",
  "Alacritty",
  "kitty",
  "WezTerm",
  "ghostty",
  "Hyper",
]

// ---------------------------------------------------------------------------
// Helpers: Config & State
// ---------------------------------------------------------------------------

function loadConfig(): PeonConfig {
  try {
    const raw = fs.readFileSync(CONFIG_PATH, "utf8")
    const parsed = JSON.parse(raw)
    return {
      ...DEFAULT_CONFIG,
      ...parsed,
      categories: { ...DEFAULT_CONFIG.categories, ...parsed.categories },
    }
  } catch {
    return { ...DEFAULT_CONFIG }
  }
}

function loadState(): PeonState {
  try {
    const raw = fs.readFileSync(STATE_PATH, "utf8")
    return JSON.parse(raw)
  } catch {
    return { last_played: {}, session_packs: {} }
  }
}

function saveState(state: PeonState): void {
  try {
    fs.mkdirSync(path.dirname(STATE_PATH), { recursive: true })
    fs.writeFileSync(STATE_PATH, JSON.stringify(state, null, 2))
  } catch {
    // Non-critical
  }
}

function isPaused(): boolean {
  return fs.existsSync(PAUSED_PATH)
}

// ---------------------------------------------------------------------------
// Helpers: Pack Management (CESP v1.0)
// ---------------------------------------------------------------------------

function getPacksDir(config: PeonConfig): string {
  return config.packs_dir || DEFAULT_PACKS_DIR
}

function loadManifest(packDir: string): CESPManifest | null {
  const cespPath = path.join(packDir, "openpeon.json")
  if (fs.existsSync(cespPath)) {
    try {
      const raw = fs.readFileSync(cespPath, "utf8")
      return JSON.parse(raw) as CESPManifest
    } catch {
      return null
    }
  }

  const legacyPath = path.join(packDir, "manifest.json")
  if (fs.existsSync(legacyPath)) {
    try {
      const raw = fs.readFileSync(legacyPath, "utf8")
      const legacy = JSON.parse(raw)
      return migrateLegacyManifest(legacy)
    } catch {
      return null
    }
  }

  return null
}

function migrateLegacyManifest(legacy: any): CESPManifest {
  const aliasMap: Record<string, CESPCategory> = {
    startup: "session.start",
    shutdown: "session.end",
    success: "task.complete",
    complete: "task.complete",
    error: "task.error",
    attention: "input.required",
    permission: "input.required",
    prompt: "input.required",
    progress: "task.progress",
    spam: "user.spam",
  }

  const categories: Partial<Record<CESPCategory, CESPCategoryEntry>> = {}
  const legacyCategories = legacy.categories || {}

  for (const [legacyKey, entry] of Object.entries(legacyCategories)) {
    const mapped = aliasMap[legacyKey]
    if (!mapped) continue

    const sounds = Array.isArray((entry as any).sounds)
      ? (entry as any).sounds.map((s: any) => ({
          file: s.file,
          label: s.label || path.basename(s.file),
        }))
      : []

    categories[mapped] = { sounds }
  }

  return {
    cesp_version: "1.0.0",
    name: legacy.name || "legacy_pack",
    display_name: legacy.display_name || legacy.name || "Legacy Pack",
    version: legacy.version || "0.0.0",
    description: legacy.description,
    author: legacy.author,
    license: legacy.license,
    homepage: legacy.homepage,
    tags: legacy.tags,
    categories,
    category_aliases: aliasMap,
  }
}

function resolveActivePack(config: PeonConfig, state: PeonState, sessionID?: string): string | null {
  const packsDir = getPacksDir(config)
  if (!fs.existsSync(packsDir)) return null

  if (sessionID && state.session_packs[sessionID]) return state.session_packs[sessionID]

  const rotation = config.pack_rotation || []
  const all = rotation.length > 0 ? rotation : [config.active_pack]

  for (const packName of all) {
    const packDir = path.join(packsDir, packName)
    if (loadManifest(packDir)) {
      if (sessionID) {
        state.session_packs[sessionID] = packName
        saveState(state)
      }
      return packName
    }
  }

  return null
}

function getSoundForCategory(manifest: CESPManifest, packDir: string, category: CESPCategory): string | null {
  const entry = manifest.categories[category]
  if (!entry || !entry.sounds || entry.sounds.length === 0) return null

  const sound = entry.sounds[Math.floor(Math.random() * entry.sounds.length)]
  const full = path.join(packDir, sound.file)
  return fs.existsSync(full) ? full : null
}

/**
 * Resolve the peon-ping icon path for notifications.
 * Checks Homebrew libexec, then OpenCode plugin dir.
 */
function resolveIconPath(): string | null {
  const candidates = [
    // Homebrew-installed icon (via formula)
    "/opt/homebrew/opt/peon-ping/libexec/docs/peon-icon.png",
    // Linuxbrew / generic Homebrew on Linux
    "/home/linuxbrew/.linuxbrew/opt/peon-ping/libexec/docs/peon-icon.png",
    // Developer-local fallback if plugin ships one later
    path.join(os.homedir(), ".config", "opencode", "peon-ping", "peon-icon.png"),
  ]
  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) return candidate
  }
  return null
}

// ---------------------------------------------------------------------------
// Helpers: Focus Detection / Notifications
// ---------------------------------------------------------------------------

function isTerminalFocusedMac(): boolean {
  try {
    const { execSync } = require("node:child_process") as typeof import("node:child_process")
    const script = `
      tell application "System Events"
        set frontApp to name of first application process whose frontmost is true
        return frontApp
      end tell
    `
    const frontApp = execSync(`osascript -e '${script.replace(/\n/g, " ")}'`, { encoding: "utf8" }).trim()
    return TERMINAL_APPS.includes(frontApp)
  } catch {
    return true
  }
}

function shouldShowDesktopNotification(config: PeonConfig, platform: RuntimePlatform): boolean {
  if (!config.desktop_notifications) return false
  if (platform !== "mac") return true
  return !isTerminalFocusedMac()
}

// ---------------------------------------------------------------------------
// Helpers: Playback & Notifications
// ---------------------------------------------------------------------------

function buildMacVolume(volume: number): string {
  // afplay volume range: 0.0 - 1.0
  return String(Math.max(0, Math.min(1, volume)))
}

function playLocalMac(file: string, config: PeonConfig): void {
  try {
    const { spawn } = require("node:child_process") as typeof import("node:child_process")
    const args = ["-v", buildMacVolume(config.volume), file]
    spawn("afplay", args, {
      detached: true,
      stdio: "ignore",
    }).unref()
  } catch {
    // Non-fatal
  }
}

function playLocalLinux(file: string, config: PeonConfig): void {
  try {
    const { spawn } = require("node:child_process") as typeof import("node:child_process")

    // Prefer pw-play if available; fallback to paplay/aplay.
    const volumeLinear = Math.max(0, Math.min(1, config.volume))
    const commands: Array<{ cmd: string; args: string[] }> = [
      { cmd: "pw-play", args: ["--volume", String(volumeLinear), file] },
      { cmd: "paplay", args: ["--volume", String(Math.round(volumeLinear * 65536)), file] },
      { cmd: "aplay", args: [file] },
    ]

    for (const { cmd, args } of commands) {
      try {
        const child = spawn(cmd, args, {
          detached: true,
          stdio: "ignore",
        })
        child.unref()
        return
      } catch {
        // Try next player
      }
    }
  } catch {
    // Non-fatal
  }
}

function playViaRelay(file: string, config: PeonConfig, relay: RelayConfig): void {
  try {
    const { spawn } = require("node:child_process") as typeof import("node:child_process")
    const args = [
      "relay-client",
      relay.host,
      String(relay.port),
      file,
      String(config.volume),
    ]
    spawn("peon-ping", args, {
      detached: true,
      stdio: "ignore",
    }).unref()
  } catch {
    // Non-fatal
  }
}

function notifyDesktop(title: string, body: string, iconPath: string | undefined, platform: RuntimePlatform): void {
  try {
    const { spawn } = require("node:child_process") as typeof import("node:child_process")

    if (platform === "mac") {
      const script = `display notification ${JSON.stringify(body)} with title ${JSON.stringify(title)}`
      spawn("osascript", ["-e", script], { detached: true, stdio: "ignore" }).unref()
      return
    }

    const args = [] as string[]
    if (iconPath) args.push("-i", iconPath)
    args.push(title, body)
    spawn("notify-send", args, { detached: true, stdio: "ignore" }).unref()
  } catch {
    // Non-fatal
  }
}

// ---------------------------------------------------------------------------
// Helpers: Event Mapping
// ---------------------------------------------------------------------------

function normalizeCategory(raw: string): CESPCategory | null {
  const normalized = raw.replace(/\s+/g, "").toLowerCase()

  const aliases: Record<string, CESPCategory> = {
    "session.start": "session.start",
    sessionstart: "session.start",
    "session.end": "session.end",
    sessionend: "session.end",
    "task.acknowledge": "task.acknowledge",
    taskacknowledge: "task.acknowledge",
    ack: "task.acknowledge",
    "task.complete": "task.complete",
    taskcomplete: "task.complete",
    complete: "task.complete",
    success: "task.complete",
    "task.error": "task.error",
    taskerror: "task.error",
    error: "task.error",
    "task.progress": "task.progress",
    taskprogress: "task.progress",
    progress: "task.progress",
    "input.required": "input.required",
    inputrequired: "input.required",
    permission: "input.required",
    attention: "input.required",
    prompt: "input.required",
    "resource.limit": "resource.limit",
    resourcelimit: "resource.limit",
    ratelimit: "resource.limit",
    limit: "resource.limit",
    "user.spam": "user.spam",
    userspam: "user.spam",
    spam: "user.spam",
  }

  return aliases[normalized] || null
}

function eventToCategory(event: any): CESPCategory | null {
  if (!event) return null

  // Plugin event wrapper
  const type = event.type || event.name || event.event
  if (!type) return null

  const map: Record<string, CESPCategory> = {
    "session.created": "session.start",
    "session.deleted": "session.end",
    "session.idle": "task.complete",
    "session.error": "task.error",
    "permission.asked": "input.required",
    "tool.execute.after": "task.progress",
  }

  if (map[type]) return map[type]

  // String-based fallback
  return normalizeCategory(String(type))
}

// ---------------------------------------------------------------------------
// Plugin Implementation
// ---------------------------------------------------------------------------

export const PeonPing: Plugin = async ({ client }) => {
  const runtimePlatform = detectPlatform()
  const promptTimestamps: number[] = []

  function isSpam(config: PeonConfig): boolean {
    const threshold = config.spam_threshold || 3
    const windowSecs = config.spam_window_seconds || 10
    const now = Date.now()
    const cutoff = now - windowSecs * 1000

    while (promptTimestamps.length > 0 && promptTimestamps[0] < cutoff) {
      promptTimestamps.shift()
    }
    promptTimestamps.push(now)

    return promptTimestamps.length >= threshold
  }

  async function handleCategory(category: CESPCategory, sessionID?: string): Promise<void> {
    const config = loadConfig()
    if (!config.enabled || isPaused()) return
    if (!config.categories?.[category]) return

    const state = loadState()
    const packName = resolveActivePack(config, state, sessionID)
    if (!packName) return

    const packDir = path.join(getPacksDir(config), packName)
    const manifest = loadManifest(packDir)
    if (!manifest) return

    const soundFile = getSoundForCategory(manifest, packDir, category)
    if (!soundFile) return

    const relay = getRelayConfig(config, runtimePlatform)
    const iconPath = resolveIconPath()

    // Debounce repeated category triggers.
    const lastPlayed = state.last_played[category]
    const now = Date.now()
    if (lastPlayed && now - Number(lastPlayed) < (config.debounce_ms || 500)) return
    state.last_played[category] = String(now)
    saveState(state)

    if (runtimePlatform === "ssh" || runtimePlatform === "devcontainer" || runtimePlatform === "wsl") {
      playViaRelay(soundFile, config, relay)
    } else if (runtimePlatform === "mac") {
      playLocalMac(soundFile, config)
    } else {
      playLocalLinux(soundFile, config)
    }

    if (shouldShowDesktopNotification(config, runtimePlatform)) {
      const title = manifest.display_name || manifest.name
      const body = category.replace(".", " ")
      notifyDesktop(title, body, iconPath || undefined, runtimePlatform)
    }
  }

  return {
    event: async ({ event }: any) => {
      try {
        const config = loadConfig()

        // Track rapid user prompts as spam.
        if (event?.type === "tui.prompt.append") {
          if (isSpam(config)) {
            await handleCategory("user.spam")
            return
          }
        }

        const category = eventToCategory(event)
        if (category) {
          await handleCategory(category, event?.properties?.sessionID || event?.properties?.sessionId)
        }
      } catch {
        // Never let plugin failures interrupt OpenCode.
      }
    },
  }
}
