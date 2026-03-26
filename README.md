# AI Agent Skills Repository Scaffold

다양한 제작사(OpenAI, Anthropic, Google, Meta, Microsoft 등)의 AI 에이전트 스킬을 한 저장소에서 관리하기 위한 기본 스캐폴딩입니다.

## 구조

- `vendors/<vendor>/skills/`: 제작사별 스킬 저장 위치
- `community/skills/`: 커뮤니티 기여 스킬
- `templates/skill-starter/`: 새 스킬 시작 템플릿
- `scripts/new-skill.sh`: 스킬 폴더 빠른 생성 스크립트

## 설치 방법

[skills CLI](https://skills.sh)를 사용해 에이전트에 스킬을 설치합니다. Node.js(npx)만 있으면 됩니다.

### 기본 설치

```bash
# 이 저장소의 모든 스킬 설치 (대화형)
npx skills add kuil09/skills
```

### 자주 쓰는 설치 예시

```bash
# 특정 에이전트에만 설치
npx skills add kuil09/skills -a claude-code
npx skills add kuil09/skills -a claude-code -a cursor

# 특정 스킬만 설치
npx skills add kuil09/skills --skill my-skill-name

# 전역(글로벌) 설치 — 모든 프로젝트에서 사용
npx skills add kuil09/skills -g

# CI/CD 등 비대화형 설치
npx skills add kuil09/skills --all -y
```

### 설치 범위

| 범위 | 플래그 | 저장 위치 |
|------|--------|-----------|
| 프로젝트 (기본) | 없음 | `./<agent>/skills/` |
| 글로벌 | `-g` | `~/<agent>/skills/` |

> Claude Code 기준 프로젝트 경로: `.claude/skills/` / 글로벌 경로: `~/.claude/skills/`

### 설치 후 관리

```bash
# 설치된 스킬 목록 확인
npx skills list

# 업데이트 확인 및 적용
npx skills check
npx skills update

# 스킬 제거
npx skills remove my-skill-name
```

---

## 빠른 시작

```bash
./scripts/new-skill.sh openai web-search-helper
./scripts/new-skill.sh anthropic cli-troubleshooter
./scripts/new-skill.sh community prompt-auditor
```

## 규칙

- 스킬명은 소문자/숫자/하이픈(`-`)만 허용
- 각 스킬은 최소 `SKILL.md` 포함
- 필요 시 `agents/`, `references/`, `scripts/`, `assets/` 하위 폴더 추가
