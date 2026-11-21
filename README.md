# transcript-critic

A [Claude Code Skill](https://code.claude.com/docs/en/skills) that transcribes audio files or
YouTube videos using [whisper.cpp](https://github.com/ggerganov/whisper.cpp) and then generates
a structured, critical analysis of the transcript -- all from a single slash command.

Run `/transcribe` followed by a `.vtt` file, an audio file, or a URL (including YouTube and other `yt-dlp` supported sites) and Claude will handle
the rest: downloading, converting, transcribing, and producing a detailed markdown summary.

---

[Prerequisites](#prerequisites) | [Installation](#installation) | [Usage](#usage) | [How it works](#how-it-works) | [Transcript summary prompt](#transcript-summary-prompt) | [Permissions](#permissions) | [Personal Project Disclosure](#personal-project-disclosure)

---

## Disclaimer

This software was developed with the assistance of AI (Anthropic Claude). It is
provided "as is", without warranty of any kind, express or implied. **Use at your
own risk.** The author assumes no liability for any damages arising from its use.


## Prerequisites

| Tool | Purpose |
|------|---------|
| [whisper.cpp](https://github.com/ggerganov/whisper.cpp) | Local speech-to-text transcription engine |
| [ffmpeg](https://ffmpeg.org/) | Audio format conversion |
| [yt-dlp](https://github.com/yt-dlp/yt-dlp) | Downloading audio from YouTube and other sites |
| [Claude Code](https://code.claude.com/) | CLI for Claude that supports custom skills |
| [Python 3](https://www.python.org/) | Used by the install script to update Claude Code settings |

## Installation

### 1. Install the skill

Run the install script from the root of this repository:

```bash
./install.sh
```

This will:
- Copy `SKILL.md`, `ANALYSIS_PROMPT.md` and `transcribe.sh` into Claude Code's global skills
  directory (`~/.claude/skills/transcribe/`). The skill only references these installed copies,
  so the repository can be cloned anywhere.
- Add permission rules to `~/.claude/settings.json` so that `/transcribe` can read
  `ANALYSIS_PROMPT.md` and run `transcribe.sh` without prompting. A backup of the previous
  settings is saved to `~/.claude/settings.json.bak`.

Re-run `./install.sh` after pulling updates to refresh the installed files.

> [!Note]
> If you prefer to install manually, copy the three files to `~/.claude/skills/transcribe/`
> and add the permission rules shown in the [Permissions](#permissions) section to the
> `permissions.allow` array in `~/.claude/settings.json`.

### 2. Configure whisper.cpp

`transcribe.sh` looks for whisper.cpp in `~/github.com/ggerganov/whisper.cpp` by default.
If yours is elsewhere, or you want a different model or language, set these environment
variables (for example in your shell profile):

| Variable | Default | Purpose |
|----------|---------|---------|
| `WHISPER_ROOT` | `~/github.com/ggerganov/whisper.cpp` | Your whisper.cpp checkout |
| `WHISPER_CLI` | `$WHISPER_ROOT/build/bin/whisper-cli` | The compiled `whisper-cli` binary |
| `WHISPER_MODEL` | `$WHISPER_ROOT/models/ggml-medium.en.bin` | The GGML model file |
| `WHISPER_LANGUAGE` | `en` | Spoken language code (e.g. `pt`), or `auto` to detect it |

> [!Note]
> Models ending in `.en` (such as the default `ggml-medium.en.bin`) only transcribe English.
> For other languages, download a multilingual model (e.g. `ggml-medium.bin`) and set
> `WHISPER_MODEL` and `WHISPER_LANGUAGE` accordingly. The script refuses to run an
> English-only model with a non-English language.

## Usage

Once installed, use the `/transcribe` slash command inside Claude Code:

```
/transcribe recording.m4a
/transcribe interview.mp3
/transcribe podcast.vtt
/transcribe https://www.youtube.com/watch?v=VIDEO_ID
/transcribe https://example.com/episode.mp3
```

Claude will:

1. **Detect the input type** (`.vtt` file, audio file, or URL).
2. **Convert or download** the audio as needed using `ffmpeg` and `yt-dlp`.
3. **Transcribe** the audio to `.txt` and `.vtt` format via `whisper.cpp`.
4. **Analyze** the transcript using the prompt template and write a structured `.md` summary.

## How it works

The project is composed of the following files:

- **`SKILL.md`** -- The skill definition file. It tells Claude how to handle each input type,
  to invoke `transcribe.sh`, and how to produce the final analysis. Claude Code reads this
  file when the `/transcribe` command is invoked.

- **`transcribe.sh`** -- Accepts either a local audio/video file or a URL (including direct links
  to `.mp3` files). Local, non-MP3 files are converted to MP3 via `ffmpeg`; URLs are downloaded
  and extracted as MP3 via `yt-dlp`, which reports the exact path of the file it created. In both
  cases, `whisper-cli` is run to produce `.txt` and `.vtt` transcription files. Empty lines are
  also stripped from the `.vtt` output to reduce token usage during analysis. All progress output
  goes to stderr; on success the script prints only the absolute path of the `.vtt` file on
  stdout, which is what the skill uses. Because `yt-dlp`
  is used, audio can be downloaded and transcribed from
  [many websites](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md) -- not just
  YouTube.

- **`ANALYSIS_PROMPT.md`** -- The prompt template that drives the analysis step. See
  [Transcript summary prompt](#transcript-summary-prompt) for details.

- **`install.sh`** -- Copies `SKILL.md`, `ANALYSIS_PROMPT.md` and `transcribe.sh` into Claude
  Code's global skills directory and calls `add_permission.py` to configure the required
  permission rules.

- **`add_permission.py`** -- Adds permission rules to `~/.claude/settings.json`, creating
  the file if it does not exist or merging into existing settings. Existing settings are
  backed up to `settings.json.bak` before being changed, and the file is left untouched if it
  is not valid JSON. Note that the file is re-serialised, so custom formatting is not kept.

## Transcript summary prompt

The file `ANALYSIS_PROMPT.md` is the prompt template that drives the analysis
step. It instructs Claude to produce a structured markdown document with the following sections:

| Section | Description |
|---------|-------------|
| **Overview** | A concise thesis summary. |
| **Source Material** | Link or path to the original source. |
| **Key Terms and Concepts** | Definitions anchored to first-mention timestamps. |
| **Detailed Summary** | Section-by-section breakdown with timestamp ranges. |
| **Scripture References** | Included only when the content is theological. |
| **Evidentiary Notes** | Categorizes each claim by its type of support (anecdotal, appeal to authority, logical argument, or cited source). |
| **Logical Fallacies** | Identifies reasoning errors using standard fallacy types. |
| **Questions and Underdeveloped Areas** | Flags ambiguities and gaps. |

This prompt is effective because it enforces objectivity because Claude is explicitly told to analyze
based solely on the transcript content without injecting prior knowledge about the speaker or
topic. It requires timestamp citations throughout, grounding every observation in a specific
moment. The evidentiary notes and logical fallacy sections push the analysis beyond simple
summarization into critical evaluation, categorizing claims by the strength of their supporting
evidence and surfacing reasoning errors. The result is an analysis that is structured,
verifiable, and avoids the uncritical paraphrasing that plagues most AI-generated summaries.

## Permissions

Because `/transcribe` is a global skill that runs from any directory, its permission
rules must live in the **global** Claude Code settings file (`~/.claude/settings.json`),
not in a project-level `.claude/settings.json`.

The `install.sh` script automatically adds the required rules. If you need to add them
manually, ensure your `~/.claude/settings.json` contains:

```json
{
  "permissions": {
    "allow": [
      "Read(~/.claude/skills/transcribe/**)",
      "Bash(~/.claude/skills/transcribe/transcribe.sh:*)"
    ]
  }
}
```

The `Read` rule allows Claude to read `ANALYSIS_PROMPT.md`, and the `Bash` rule allows it to
run `transcribe.sh` without prompting. Empty-line removal from `.vtt` files is handled directly
by `transcribe.sh`, so no other Bash permission is needed.

> [!Note]
> Earlier versions added `Read(~/github.com/jftuga/transcript-critic/**)`. That rule is no
> longer needed and can be removed from your settings.

## Personal Project Disclosure

This program is my own original idea, conceived and developed entirely:

* On my own personal time, outside of work hours
* For my own personal benefit and use
* On my personally owned equipment
* Without using any employer resources, proprietary information, or trade secrets
* Without any connection to my employer's business, products, or services
* Independent of any duties or responsibilities of my employment

This project does not relate to my employer's actual or demonstrably
anticipated research, development, or business activities. No
confidential or proprietary information from any employer was used
in its creation.

