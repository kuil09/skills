---
name: pomodoro-timer
description: >
  뽀모도로 테크닉 기반 집중 세션 관리 스킬. 쉘 스크립트로 타이머를 실행하고,
  AI 에이전트가 각 휴식마다 세션 회고를 진행하며, 긴 휴식에는 통합 회고를 수행합니다.
---

# 뽀모도로 타이머 스킬

## Goal

- 터미널 쉘 스크립트를 이용해 뽀모도로 타이머를 백그라운드로 실행합니다.
- 에이전트가 타이머 상태 파일을 읽어 현재 단계(집중/짧은 휴식/긴 휴식)를 인식합니다.
- **짧은 휴식(5분)** 마다 에이전트가 해당 세션의 회고를 진행합니다.
- **긴 휴식(30분)** 에는 에이전트가 4개 세션 회고를 통합하여 사이클 회고를 진행합니다.

## Workflow

1. **시작**: 사용자가 뽀모도로 시작을 요청하면 작업 목표를 확인하고 타이머를 실행합니다.
2. **루프 감시 시작**: `/loop 30s` 로 30초마다 `pomodoro-check.sh`를 실행해 타이머 전환을 감지합니다.
3. **집중 세션**: 타이머가 백그라운드에서 25분을 카운트다운. 에이전트는 침묵합니다.
4. **자동 감지 → 능동 개입**: 에이전트가 `short_break` 또는 `long_break`를 감지하면 **먼저 사용자에게 개입**합니다.
5. **세션 회고**: 에이전트가 3가지 질문으로 회고를 진행하고 `pomodoro-mark-retro.sh`로 완료 표시합니다.
6. **통합 회고**: 4번째 세션 후 에이전트가 긴 휴식을 선언하고 사이클 통합 회고 보고서를 작성합니다.

## State File

타이머는 `~/.pomodoro/state.json`에 현재 상태를 기록합니다:

```json
{
  "phase": "work | short_break | long_break | idle",
  "session": 2,
  "cycle": 1,
  "start_epoch": 1748000000,
  "end_epoch":   1748001500,
  "start_iso": "2025-05-23T10:00:00Z",
  "end_iso":   "2025-05-23T10:25:00Z",
  "updated_iso": "2025-05-23T10:12:34Z"
}
```

## Resources

- `scripts/pomodoro.sh` — 타이머 실행/상태/중지/로그 명령
- `scripts/pomodoro-check.sh` — 루프용 회고 필요 여부 감지 (RETRO_NEEDED / NO_ACTION)
- `scripts/pomodoro-mark-retro.sh` — 회고 완료 표시 (중복 개입 방지)
- `scripts/pomodoro-context.sh` — 에이전트용 상태+로그 통합 출력
- `agents/claude.md` — Claude 에이전트 행동 지침 (루프 기반 능동 개입)
- `references/pomodoro-technique.md` — 뽀모도로 테크닉 배경 지식

## Quick Start

```bash
# 타이머 시작 (백그라운드 실행)
bash community/skills/pomodoro-timer/scripts/pomodoro.sh start

# 루프 감시 시작 (에이전트가 자동으로 전환 감지)
# /loop 30s bash community/skills/pomodoro-timer/scripts/pomodoro-check.sh ...

# 회고 필요 여부 수동 확인
bash community/skills/pomodoro-timer/scripts/pomodoro-check.sh

# 회고 완료 표시 (세션 번호 필요)
bash community/skills/pomodoro-timer/scripts/pomodoro-mark-retro.sh 2

# 타이머 중지
bash community/skills/pomodoro-timer/scripts/pomodoro.sh stop
```

## Environment Variables (선택적 커스터마이징)

| 변수                           | 기본값 | 설명                    |
|-------------------------------|--------|-------------------------|
| `POMODORO_WORK_MIN`           | 25     | 집중 세션 시간 (분)     |
| `POMODORO_SHORT_BREAK_MIN`    | 5      | 짧은 휴식 시간 (분)     |
| `POMODORO_LONG_BREAK_MIN`     | 30     | 긴 휴식 시간 (분)       |
| `POMODORO_SESSIONS_BEFORE_LONG` | 4   | 긴 휴식 전 세션 수      |
| `POMODORO_STATE_DIR`          | `~/.pomodoro` | 상태 파일 저장 위치 |
