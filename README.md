# transcript-critic

A [Claude Code Skill](https://code.claude.com/docs/en/skills) that transcribes audio files or
YouTube videos using [whisper.cpp](https://github.com/ggerganov/whisper.cpp) and then generates
a structured, critical analysis of the transcript -- all from a single slash command.

Run `/transcribe` followed by a `.vtt` file, an audio file, or a URL (including YouTube and other `yt-dlp` supported sites) and Claude will handle
the rest: downloading, converting, transcribing, and producing a detailed markdown summary.

---

[Prerequisites](#prerequisites) | [Installation](#installation) | [Usage](#usage) | [How it works](#how-it-works) | [Transcript summary prompt](#transcript-summary-prompt) | [Personal Project Disclosure](#personal-project-disclosure)

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

## Installation

### 1. Install the skill

Copy `SKILL.md` into Claude Code's global skills directory:

```bash
mkdir -p ~/.claude/skills/transcribe
cp SKILL.md ~/.claude/skills/transcribe/SKILL.md
```

### 2. Configure script paths

**In `transcribe.sh`**, update the following variables at the top of
the script to match your local whisper.cpp installation:

```bash
WHISPER_ROOT="${HOME}/github.com/ggerganov/whisper.cpp"
PGM="${WHISPER_ROOT}/build/bin/whisper-cli"
MODEL="${WHISPER_ROOT}/models/ggml-medium.en.bin"
```

- `WHISPER_ROOT` must point to your whisper.cpp checkout.
- `PGM` must point to the compiled `whisper-cli` binary.
- `MODEL` must point to the GGML model file you want to use (e.g., `ggml-medium.en.bin`).

> [!Note]
> In `SKILL.md`, the paths to `transcribe.sh` and `ANALYSIS_PROMPT.md` are referenced as instructions for Claude. If you clone this repository to a location other than `~/github.com/jftuga/transcript-critic/`, update those paths in `SKILL.md` accordingly.

## Usage

Once installed, use the `/transcribe` slash command inside Claude Code:

```
/transcribe recording.m4a
/transcribe interview.mp3
/transcribe podcast.vtt
/transcribe https://www.youtube.com/watch?v=VIDEO_ID
```

Claude will:

1. **Detect the input type** (`.vtt` file, audio file, or URL).
2. **Convert or download** the audio as needed using `ffmpeg` and `yt-dlp`.
3. **Transcribe** the audio to `.txt` and `.vtt` format via `whisper.cpp`.
4. **Analyze** the transcript using the prompt template and write a structured `.md` summary.

## How it works

The skill is composed of two parts:

- **`SKILL.md`** -- The skill definition file. It tells Claude how to handle each input type,
  to invoke `transcribe.sh`, and how to produce the final analysis. Claude Code reads this
  file when the `/transcribe` command is invoked.

- **`transcribe.sh`** -- Accepts either a local audio/video file or a URL. Local, non-audio files are
  converted to MP3 via `ffmpeg`; URLs are downloaded and extracted as MP3 via `yt-dlp`. In both
  cases, `whisper-cli` is run to produce `.txt` and `.vtt` transcription files. Because `yt-dlp`
  is used, audio can be downloaded and transcribed from
  [many websites](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md) -- not just
  YouTube.

## Transcript summary prompt

The file `ANALYSIS_PROMPT.md` is the prompt template that drives the analysis
step. It instructs Claude to produce a structured markdown document with the following sections:

| Section | Description |
|---------|-------------|
| **Overview** | A concise thesis summary. |
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

